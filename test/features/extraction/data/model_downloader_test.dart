import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:scontrini/features/extraction/data/model_downloader.dart';

/// A local server with the files, behind a redirect like Hugging Face's.
class _Server {
  new _(this._server, this.contents) {
    _server.listen(_handle);
  }

  static Future<_Server> start(Map<String, Uint8List> contents) async =>
      _Server._(
        await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
        contents,
      );

  final HttpServer _server;
  final Map<String, Uint8List> contents;

  /// Range headers received for the files (`null`: none).
  final ranges = <String?>[];

  /// Ignore the Range header and always send the whole file.
  bool ignoreRange = false;

  /// Close the connection after this many bytes of a response.
  int? dropAfter;

  String url(String name) => 'http://127.0.0.1:${_server.port}/redirect/$name';

  Future<void> close() => _server.close(force: true);

  Future<void> _handle(HttpRequest request) async {
    final path = request.uri.pathSegments;
    final response = request.response;
    if (path.first == 'redirect') {
      await response.redirect(Uri.parse('/files/${path[1]}'));
      return;
    }
    final data = contents[path[1]];
    if (data == null) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      return;
    }
    final range = request.headers.value(HttpHeaders.rangeHeader);
    ranges.add(range);
    var from = 0;
    if (range != null && !ignoreRange) {
      from = int.parse(RegExp(r'bytes=(\d+)-').firstMatch(range)!.group(1)!);
      response.statusCode = HttpStatus.partialContent;
    }
    final body = data.sublist(from);
    final drop = dropAfter;
    if (drop != null && drop < body.length) {
      // Headers promise the whole body, then the connection dies.
      response.contentLength = body.length;
      final socket = await response.detachSocket();
      socket.add(body.sublist(0, drop));
      await socket.flush();
      socket.destroy();
      return;
    }
    response.add(body);
    await response.close();
  }
}

Uint8List _bytes(int length, int seed) => Uint8List.fromList([
  for (var i = 0; i < length; i++) (i * 31 + seed) % 251,
]);

void main() {
  late Directory dir;
  late _Server server;
  final model = _bytes(3 << 20, 1); // 3 MB: progress every MB
  final projector = _bytes(200000, 2);

  ModelDownloader downloader({String? modelHash}) =>
      ModelDownloader(stallTimeout: const Duration(seconds: 2), [
        ModelDownloadFile(
          name: 'model.gguf',
          url: server.url('model.gguf'),
          bytes: model.length,
          sha256: modelHash ?? sha256.convert(model).toString(),
        ),
        ModelDownloadFile(
          name: 'mmproj.gguf',
          url: server.url('mmproj.gguf'),
          bytes: projector.length,
          sha256: sha256.convert(projector).toString(),
        ),
      ]);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('model_download_');
    server = await _Server.start({
      'model.gguf': model,
      'mmproj.gguf': projector,
    });
  });

  tearDown(() async {
    await server.close();
    await dir.delete(recursive: true);
  });

  File file(String name) => File(p.join(dir.path, name));

  test('downloads every file through the redirect and checks it', () async {
    final d = downloader();
    expect(await d.installed(dir.path), isFalse);
    final progress = await d.download(dir.path).toList();

    expect(await d.installed(dir.path), isTrue);
    expect(await file('model.gguf').readAsBytes(), model);
    expect(await file('mmproj.gguf').readAsBytes(), projector);
    expect(file('model.gguf.part').existsSync(), isFalse);
    expect(progress.last, (received: d.totalBytes, total: d.totalBytes));
    final received = progress.map((p) => p.received).toList();
    expect(received, orderedEquals([...received]..sort()));
    expect(received.length, greaterThan(3));
  });

  test('installed files are not downloaded again', () async {
    final d = downloader();
    await d.download(dir.path).drain<void>();
    server.ranges.clear();
    await d.download(dir.path).drain<void>();
    expect(server.ranges, isEmpty);
  });

  test('an interrupted download resumes where it stopped', () async {
    final d = downloader();
    server.dropAfter = 1 << 20;
    await expectLater(
      d.download(dir.path).drain<void>(),
      throwsA(
        isA<ModelDownloadException>().having(
          (e) => e.error,
          'error',
          ModelDownloadError.network,
        ),
      ),
    );
    final kept = await file('model.gguf.part').length();
    expect(kept, greaterThan(0));
    expect(await d.downloadedBytes(dir.path), kept);

    server
      ..dropAfter = null
      ..ranges.clear();
    await d.download(dir.path).drain<void>();
    expect(server.ranges.first, 'bytes=$kept-');
    expect(await file('model.gguf').readAsBytes(), model);
  });

  test('a cancelled download keeps what arrived', () async {
    final d = downloader();
    final done = Completer<void>();
    late StreamSubscription<DownloadProgress> sub;
    sub = d.download(dir.path).listen((progress) async {
      if (progress.received >= 1 << 20 && !done.isCompleted) {
        done.complete();
        await sub.cancel();
      }
    });
    await done.future;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(file('model.gguf').existsSync(), isFalse);
    expect(await d.downloadedBytes(dir.path), greaterThanOrEqualTo(1 << 20));

    await d.download(dir.path).drain<void>();
    expect(await d.installed(dir.path), isTrue);
    expect(await file('model.gguf').readAsBytes(), model);
  });

  test('a server that ignores the range restarts the file', () async {
    await file('model.gguf.part').writeAsBytes(model.sublist(0, 5000));
    server.ignoreRange = true;
    await downloader().download(dir.path).drain<void>();
    expect(server.ranges.first, 'bytes=5000-');
    expect(await file('model.gguf').readAsBytes(), model);
  });

  test('a file with the wrong checksum is thrown away', () async {
    final d = downloader(modelHash: '0' * 64);
    await expectLater(
      d.download(dir.path).drain<void>(),
      throwsA(
        isA<ModelDownloadException>().having(
          (e) => e.error,
          'error',
          ModelDownloadError.corrupt,
        ),
      ),
    );
    expect(file('model.gguf').existsSync(), isFalse);
    expect(file('model.gguf.part').existsSync(), isFalse);
  });

  test('an HTTP error is a network error', () async {
    final d = ModelDownloader([
      ModelDownloadFile(
        name: 'missing.gguf',
        url: server.url('missing.gguf'),
        bytes: 10,
        sha256: '0' * 64,
      ),
    ]);
    await expectLater(
      d.download(dir.path).drain<void>(),
      throwsA(isA<ModelDownloadException>()),
    );
  });

  test('delete removes finished and partial files', () async {
    final d = downloader();
    await file('mmproj.gguf.part').writeAsBytes([1, 2, 3]);
    await file('model.gguf').writeAsBytes(model);
    await d.delete(dir.path);
    expect(dir.listSync(), isEmpty);
  });
}
