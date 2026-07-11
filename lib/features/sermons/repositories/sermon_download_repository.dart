import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class SermonDownloadRepository {
  SermonDownloadRepository({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<Directory> getDownloadDirectory() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final sermonDirectory = Directory(
      '${appDirectory.path}${Platform.pathSeparator}sermons',
    );
    if (!await sermonDirectory.exists()) {
      await sermonDirectory.create(recursive: true);
    }
    return sermonDirectory;
  }

  Future<String> getLocalPath(String sermonId) async {
    final cleanId = _sanitizeFileName(sermonId);
    if (cleanId.isEmpty) {
      throw ArgumentError('A sermon ID is required.');
    }
    final directory = await getDownloadDirectory();
    return '${directory.path}${Platform.pathSeparator}$cleanId.mp3';
  }

  Future<File?> getDownloadedFile(String sermonId) async {
    final path = await getLocalPath(sermonId);
    final file = File(path);
    if (!await file.exists()) {
      return null;
    }
    return file;
  }

  Future<bool> isDownloaded(String sermonId) async {
    return await getDownloadedFile(sermonId) != null;
  }

  Future<File> downloadAudio({
    required String sermonId,
    required String audioUrl,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final cleanUrl = audioUrl.trim();
    if (cleanUrl.isEmpty) {
      throw ArgumentError('An audio URL is required.');
    }
    final uri = Uri.tryParse(cleanUrl);
    if (uri == null || !uri.hasScheme) {
      throw ArgumentError('The sermon audio URL is invalid.');
    }
    final path = await getLocalPath(sermonId);
    final temporaryPath = '$path.part';
    final temporaryFile = File(temporaryPath);
    if (await temporaryFile.exists()) {
      await temporaryFile.delete();
    }
    try {
      await _dio.download(
        cleanUrl,
        temporaryPath,
        cancelToken: cancelToken,
        deleteOnError: true,
        onReceiveProgress: (received, total) {
          if (total <= 0) {
            return;
          }
          final progress = received / total;
          onProgress?.call(progress.clamp(0.0, 1.0));
        },
      );
      final finalFile = File(path);
      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      return temporaryFile.rename(path);
    } catch (_) {
      if (await temporaryFile.exists()) {
        await temporaryFile.delete();
      }
      rethrow;
    }
  }

  Future<void> deleteDownload(String sermonId) async {
    final file = await getDownloadedFile(sermonId);
    if (file != null) {
      await file.delete();
    }
    final path = await getLocalPath(sermonId);
    final temporaryFile = File('$path.part');
    if (await temporaryFile.exists()) {
      await temporaryFile.delete();
    }
  }

  Future<int> getDownloadedFileSize(String sermonId) async {
    final file = await getDownloadedFile(sermonId);
    if (file == null) {
      return 0;
    }
    return file.length();
  }

  Future<List<FileSystemEntity>> getAllDownloadedFiles() async {
    final directory = await getDownloadDirectory();
    final entities = await directory.list().toList();
    return entities.where((entity) {
      return entity is File && entity.path.toLowerCase().endsWith('.mp3');
    }).toList();
  }

  String _sanitizeFileName(String value) {
    return value.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }
}
