import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// One file to download: where from, its size and its SHA-256 (hex).
class ModelDownloadFile {
  const new({
    required this.name,
    required this.url,
    required this.bytes,
    required this.sha256,
  });

  /// File name inside the download directory.
  final String name;
  final String url;
  final int bytes;
  final String sha256;
}

/// The GLM-OCR files (MIT licence), from ggml-org/GLM-OCR-GGUF pinned to one
/// commit so the files never change under the app. 1.43 GB in all.
const glmOcrDownloadFiles = [
  ModelDownloadFile(
    name: 'GLM-OCR-Q8_0.gguf',
    url: '$_glmOcrRepo/GLM-OCR-Q8_0.gguf',
    bytes: 950433408,
    sha256: '45bc244a6446aff850521dc41f18bc8d7105ad5f0c2c8c28af04e7cc4f4d50b1',
  ),
  ModelDownloadFile(
    name: 'mmproj-GLM-OCR-Q8_0.gguf',
    url: '$_glmOcrRepo/mmproj-GLM-OCR-Q8_0.gguf',
    bytes: 484403648,
    sha256: '9c4b58e33e316ed142eb5dcb41abec3844d3e6e5dc361ffb782c3fa9d175141f',
  ),
];

const _glmOcrRepo =
    'https://huggingface.co/ggml-org/GLM-OCR-GGUF/resolve/'
    '65a42de1148dbed2297e922b5dbc7d9b70c36578';

/// Bytes downloaded so far, over all files.
typedef DownloadProgress = ({int received, int total});

enum ModelDownloadError {
  /// No connection, or the server answered with an error.
  network,

  /// The file arrived, but not the one expected (size or checksum).
  corrupt,

  /// The file could not be written, usually a full disk.
  storage,
}

class ModelDownloadException implements Exception {
  const new(this.error, [this.cause]);

  final ModelDownloadError error;
  final Object? cause;

  @override
  String toString() => 'ModelDownloadException($error, $cause)';
}

/// Downloads model files into a directory, resuming where a cancelled or
/// interrupted download stopped. Each file is written as `<name>.part` and
/// renamed only once its checksum matches, so a file with its final name is
/// always complete.
class ModelDownloader {
  new(
    this.files, {
    HttpClient Function()? httpClient,
    this.stallTimeout = const Duration(seconds: 30),
  }) : _httpClient = httpClient ?? HttpClient.new;

  final List<ModelDownloadFile> files;

  /// A connection that sends nothing for this long is a network error, so
  /// a download never hangs on a dead network.
  final Duration stallTimeout;
  final HttpClient Function() _httpClient;

  int get totalBytes => files.fold(0, (sum, file) => sum + file.bytes);

  /// Whether every file is in [directory] with its final name and size.
  Future<bool> installed(String directory) async {
    for (final file in files) {
      final target = File(p.join(directory, file.name));
      if (!target.existsSync() || await target.length() != file.bytes) {
        return false;
      }
    }
    return true;
  }

  /// Bytes already in [directory], finished files and partial ones: what a
  /// [download] would not fetch again.
  Future<int> downloadedBytes(String directory) async {
    var bytes = 0;
    for (final file in files) {
      final target = File(p.join(directory, file.name));
      final part = File('${target.path}.part');
      if (target.existsSync()) {
        bytes += await target.length();
      } else if (part.existsSync()) {
        bytes += await part.length();
      }
    }
    return bytes;
  }

  /// Removes the files, partial downloads included.
  Future<void> delete(String directory) async {
    for (final file in files) {
      final target = File(p.join(directory, file.name));
      for (final f in [target, File('${target.path}.part')]) {
        if (f.existsSync()) await f.delete();
      }
    }
  }

  /// Downloads the missing files into [directory]. Cancelling the
  /// subscription stops the download and keeps what arrived for the next
  /// call. Errors are [ModelDownloadException]s.
  Stream<DownloadProgress> download(String directory) async* {
    await Directory(directory).create(recursive: true);
    final client = _httpClient()..connectionTimeout = stallTimeout;
    try {
      var done = 0;
      for (final file in files) {
        final target = File(p.join(directory, file.name));
        if (target.existsSync() && await target.length() == file.bytes) {
          done += file.bytes;
          yield (received: done, total: totalBytes);
          continue;
        }
        await for (final received in _downloadFile(client, file, target)) {
          yield (received: done + received, total: totalBytes);
        }
        done += file.bytes;
      }
    } on ModelDownloadException {
      rethrow;
    } on FileSystemException catch (error) {
      throw ModelDownloadException(ModelDownloadError.storage, error);
    } on Object catch (error) {
      // SocketException, HttpException, TLS errors, timeouts...
      throw ModelDownloadException(ModelDownloadError.network, error);
    } finally {
      client.close(force: true);
    }
  }

  /// Bytes of [file] received so far, as they arrive (about every MB).
  Stream<int> _downloadFile(
    HttpClient client,
    ModelDownloadFile file,
    File target,
  ) async* {
    final part = File('${target.path}.part');
    var have = part.existsSync() ? await part.length() : 0;
    if (have > file.bytes) {
      await part.delete();
      have = 0;
    }

    final hash = _Sha256();
    if (have > 0) {
      await part.openRead().forEach(hash.add);
    }
    yield have;

    if (have < file.bytes) {
      final response = await _get(client, Uri.parse(file.url), from: have);
      if (have > 0 && response.statusCode == HttpStatus.ok) {
        // The server ignored the range: start over.
        have = 0;
        hash.reset();
      } else if (response.statusCode != HttpStatus.ok &&
          response.statusCode != HttpStatus.partialContent) {
        await response.drain<void>();
        throw ModelDownloadException(
          ModelDownloadError.network,
          'HTTP ${response.statusCode}',
        );
      }

      final sink = part.openWrite(
        mode: have > 0 ? FileMode.append : FileMode.write,
      );
      try {
        var reported = have;
        await for (final chunk in response.timeout(stallTimeout)) {
          sink.add(chunk);
          hash.add(chunk);
          have += chunk.length;
          if (have > file.bytes) break;
          if (have - reported >= 1 << 20) {
            reported = have;
            yield have;
          }
        }
      } finally {
        await sink.close();
      }
    }

    if (have != file.bytes || hash.hex() != file.sha256) {
      await part.delete();
      throw ModelDownloadException(
        ModelDownloadError.corrupt,
        '${file.name}: $have bytes',
      );
    }
    await part.rename(target.path);
    yield have;
  }

  /// GET from byte [from] on, following redirects by hand: Hugging Face
  /// redirects to its CDN, and the range must reach it too.
  Future<HttpClientResponse> _get(
    HttpClient client,
    Uri url, {
    required int from,
  }) async {
    var uri = url;
    for (var hop = 0; hop < 5; hop++) {
      final request = await client.getUrl(uri)
        ..followRedirects = false;
      if (from > 0) {
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=$from-');
      }
      final response = await request.close();
      final location = response.headers.value(HttpHeaders.locationHeader);
      if (!response.isRedirect || location == null) return response;
      await response.drain<void>();
      uri = uri.resolve(location);
    }
    throw const ModelDownloadException(
      ModelDownloadError.network,
      'too many redirects',
    );
  }
}

/// Incremental SHA-256 that can start over.
class _Sha256 {
  new() {
    reset();
  }

  late _DigestSink _digest;
  late ByteConversionSink _input;

  void reset() {
    _digest = _DigestSink();
    _input = sha256.startChunkedConversion(_digest);
  }

  void add(List<int> bytes) => _input.add(bytes);

  String hex() {
    _input.close();
    return _digest.value.toString();
  }
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
