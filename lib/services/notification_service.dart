import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();

  static const String channelId = 'download_channel';
  static const String channelName = 'Downloads';
  static const String channelDescription =
      'Notifications for file downloads';

  Future<void> initialize({
    void Function(String taskId)? onNotificationTap,
  }) async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;

        if (payload == null || payload.isEmpty) {
          return;
        }

        onNotificationTap?.call(payload);
      },
    );

    final androidPlugin =
    notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.low,
      ),
    );
  }

  Future<void> showDownloadProgress({
    required int notificationId,
    required String taskId,
    required String fileName,
    required int progress,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      ongoing: true,
      autoCancel: false,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      id: notificationId,
      title: 'Downloading',
      body: '$fileName • $progress%',
      notificationDetails: notificationDetails,
      payload: taskId,
    );
  }

  Future<void> showDownloadCompleted({
    required int notificationId,
    required String taskId,
    required String fileName,
  }) async {
    await notifications.cancel(
      id: notificationId,
    );

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: false,
      autoCancel: true,
      showProgress: false,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      id: notificationId,
      title: 'Download completed',
      body: fileName,
      notificationDetails: notificationDetails,
      payload: taskId,
    );
  }

  Future<void> showDownloadFailed({
    required int notificationId,
    required String taskId,
    required String fileName,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: false,
      autoCancel: true,
      showProgress: false,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      id: notificationId,
      title: 'Download failed',
      body: fileName,
      notificationDetails: notificationDetails,
      payload: taskId,
    );
  }

  Future<void> cancel(int notificationId) async {
    await notifications.cancel(
      id: notificationId,
    );
  }
}