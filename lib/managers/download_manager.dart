import 'dart:async';

import '../models/download_task.dart';
import '../services/download_service.dart';
import '../services/file_open_service.dart';
import '../services/notification_service.dart';

class DownloadManager {
  final DownloadService downloadService;
  final NotificationService notificationService;
  final FileOpenService fileOpenService;

  final Map<String, DownloadTask> tasks = {};

  final StreamController<DownloadTask> taskController =
  StreamController<DownloadTask>.broadcast();

  DownloadManager({
    DownloadService? downloadService,
    NotificationService? notificationService,
    FileOpenService? fileOpenService,
  })  : downloadService = downloadService ?? DownloadService(),
        notificationService =
            notificationService ?? NotificationService(),
        fileOpenService = fileOpenService ?? FileOpenService();

  Stream<DownloadTask> get taskStream => taskController.stream;

  Future<void> initialize() async {
    await notificationService.initialize(
      onNotificationTap: handleNotificationTap,
    );
  }

  DownloadTask? getTask(String id) {
    return tasks[id];
  }

  List<DownloadTask> get allTasks {
    return List.unmodifiable(tasks.values);
  }

  Future<DownloadTask> startDownload({
    required String url,
    required String fileName,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final notificationId = getNotificationId(id);

    var task = DownloadTask(
      id: id,
      url: url,
      fileName: fileName,
      status: DownloadStatus.downloading,
    );

    tasks[id] = task;
    taskController.add(task);

    try {
      final filePath = await downloadService.downloadFile(
        url: url,
        fileName: fileName,
        onProgress: (receivedBytes, totalBytes) {
          final progress = totalBytes > 0
              ? receivedBytes / totalBytes
              : 0.0;

          final percentage = (progress * 100).round();

          task = task.copyWith(
            downloadedBytes: receivedBytes,
            totalBytes: totalBytes,
            progress: progress,
            status: DownloadStatus.downloading,
          );

          tasks[id] = task;
          taskController.add(task);

          if (percentage < 100) {
            notificationService.showDownloadProgress(
              notificationId: notificationId,
              taskId: id,
              fileName: fileName,
              progress: percentage,
            );
          }
        },
      );

      task = task.copyWith(
        filePath: filePath,
        downloadedBytes: task.totalBytes,
        progress: 1.0,
        status: DownloadStatus.completed,
      );

      tasks[id] = task;
      taskController.add(task);

      await notificationService.showDownloadCompleted(
        notificationId: notificationId,
        taskId: id,
        fileName: fileName,
      );

      return task;
    } catch (error) {
      task = task.copyWith(
        status: DownloadStatus.failed,
        errorMessage: error.toString(),
      );

      tasks[id] = task;
      taskController.add(task);

      await notificationService.showDownloadFailed(
        notificationId: notificationId,
        taskId: id,
        fileName: fileName,
      );

      rethrow;
    }
  }

  Future<void> handleNotificationTap(String taskId) async {
    final task = tasks[taskId];

    if (task == null) {
      return;
    }

    if (task.status != DownloadStatus.completed) {
      return;
    }

    if (task.filePath == null) {
      return;
    }

    await fileOpenService.openFile(task.filePath!);
  }

  Future<void> openDownload(String taskId) async {
    final task = tasks[taskId];

    if (task == null || task.filePath == null) {
      return;
    }

    await fileOpenService.openFile(task.filePath!);
  }

  int getNotificationId(String taskId) {
    final value = int.tryParse(taskId);

    if (value == null) {
      return taskId.hashCode.abs();
    }

    return value % 2147483647;
  }

  void removeTask(String id) {
    tasks.remove(id);
  }

  void clearCompleted() {
    tasks.removeWhere(
          (id, task) => task.status == DownloadStatus.completed,
    );
  }

  Future<void> dispose() async {
    await taskController.close();
  }
}