enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

class DownloadTask {
  final String id;
  final String url;
  final String fileName;
  final String? filePath;
  final DownloadStatus status;
  final int downloadedBytes;
  final int totalBytes;
  final double progress;
  final String? errorMessage;

  const DownloadTask({
    required this.id,
    required this.url,
    required this.fileName,
    this.filePath,
    this.status = DownloadStatus.pending,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.progress = 0,
    this.errorMessage,
  });

  DownloadTask copyWith({
    String? filePath,
    DownloadStatus? status,
    int? downloadedBytes,
    int? totalBytes,
    double? progress,
    String? errorMessage,
  }) {
    return DownloadTask(
      id: id,
      url: url,
      fileName: fileName,
      filePath: filePath ?? this.filePath,
      status: status ?? this.status,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}