import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  final Dio dio;

  DownloadService({
    Dio? dio,
  }) : dio = dio ?? Dio();

  Future<String> downloadFile({
    required String url,
    required String fileName,
    required void Function(int receivedBytes, int totalBytes) onProgress,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';

    await dio.download(
      url,
      filePath,
      onReceiveProgress: onProgress,
    );

    return filePath;
  }
}