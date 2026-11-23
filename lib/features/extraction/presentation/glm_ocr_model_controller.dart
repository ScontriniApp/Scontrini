import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scontrini/features/extraction/data/extraction_providers.dart';
import 'package:scontrini/features/extraction/data/model_downloader.dart';

/// Whether GLM-OCR's model is on the phone, as Settings shows it.
sealed class GlmOcrModelState {
  const new();
}

class GlmOcrModelChecking extends GlmOcrModelState {
  const new();
}

/// Not installed; [downloaded] bytes of an earlier download are kept and a
/// new download resumes from there.
class GlmOcrModelMissing extends GlmOcrModelState {
  const new({required this.downloaded, required this.total});

  final int downloaded;
  final int total;
}

class GlmOcrModelDownloading extends GlmOcrModelState {
  const new({required this.received, required this.total});

  final int received;
  final int total;
}

class GlmOcrModelInstalled extends GlmOcrModelState {
  const new({required this.bytes});

  final int bytes;
}

class GlmOcrModelFailed extends GlmOcrModelState {
  const new(this.error, {required this.downloaded, required this.total});

  final ModelDownloadError error;
  final int downloaded;
  final int total;
}

/// Downloads and deletes GLM-OCR's files. Kept alive, so a download goes on
/// while the user leaves Settings; once it ends, photos are read with
/// GLM-OCR (see `glmOcrProvider`).
final glmOcrModelProvider =
    NotifierProvider<GlmOcrModelController, GlmOcrModelState>(
      GlmOcrModelController.new,
    );

class GlmOcrModelController extends Notifier<GlmOcrModelState> {
  StreamSubscription<DownloadProgress>? _download;

  ModelDownloader get _downloader => ref.read(glmOcrDownloaderProvider);
  Future<String> get _directory => ref.read(glmOcrModelDirectoryProvider);

  @override
  GlmOcrModelState build() {
    ref.onDispose(() => _download?.cancel());
    unawaited(_refresh());
    return const GlmOcrModelChecking();
  }

  Future<void> _refresh() async {
    final total = _downloader.totalBytes;
    bool installed;
    int downloaded;
    try {
      final directory = await _directory;
      installed = await _downloader.installed(directory);
      downloaded = await _downloader.downloadedBytes(directory);
    } on Object catch (error, stack) {
      // No app folder (a widget test without path_provider): not installed.
      developer.log(
        'GLM-OCR model check failed',
        name: 'extraction',
        error: error,
        stackTrace: stack,
      );
      installed = false;
      downloaded = 0;
    }
    if (!ref.mounted || _download != null) return;
    state = installed
        ? GlmOcrModelInstalled(bytes: total)
        : GlmOcrModelMissing(downloaded: downloaded, total: total);
  }

  /// Starts (or resumes) the download.
  Future<void> download() async {
    if (_download != null) return;
    final total = _downloader.totalBytes;
    final directory = await _directory;
    if (!ref.mounted || _download != null) return;
    state = GlmOcrModelDownloading(received: 0, total: total);
    _download = _downloader
        .download(directory)
        .listen(
          (progress) => state = GlmOcrModelDownloading(
            received: progress.received,
            total: progress.total,
          ),
          onError: (Object error, StackTrace stack) async {
            _download = null;
            developer.log(
              'GLM-OCR download failed',
              name: 'extraction',
              error: error,
              stackTrace: stack,
            );
            final downloaded = await _downloader.downloadedBytes(directory);
            if (!ref.mounted) return;
            state = GlmOcrModelFailed(
              error is ModelDownloadException
                  ? error.error
                  : ModelDownloadError.network,
              downloaded: downloaded,
              total: total,
            );
          },
          onDone: () {
            _download = null;
            ref.invalidate(glmOcrProvider);
            state = GlmOcrModelInstalled(bytes: total);
          },
          cancelOnError: true,
        );
  }

  /// Stops the download; what arrived is kept for the next one.
  Future<void> cancel() async {
    final download = _download;
    if (download == null) return;
    await download.cancel();
    _download = null;
    await _refresh();
  }

  /// Removes the model: photos go back to ML Kit.
  Future<void> delete() async {
    await cancel();
    await (await ref.read(glmOcrProvider))?.close();
    await _downloader.delete(await _directory);
    ref.invalidate(glmOcrProvider);
    await _refresh();
  }
}
