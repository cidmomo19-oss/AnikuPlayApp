import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'local_db.dart';
import 'models/download_item.dart';

class DownloadService {
  final Dio _dio;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _initializedNotifications = false;

  DownloadService({
    Dio? dio,
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  })  : _dio = dio ?? Dio(),
        _notificationsPlugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  Future<void> _initNotifications() async {
    if (_initializedNotifications) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
    _initializedNotifications = true;
  }

  Future<void> downloadEpisode({
    required int animeId,
    required String animeTitle,
    required int episodeNumber,
    required String videoUrl,
    required Function(double progress) onProgress,
  }) async {
    await _initNotifications();
    final notificationId = (animeId * 1000) + episodeNumber;

    try {
      final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final folderPath = '${dir.path}/downloads/$animeId';
      final folderDir = Directory(folderPath);
      if (!await folderDir.exists()) {
        await folderDir.create(recursive: true);
      }

      final filePath = '$folderPath/ep_$episodeNumber.mp4';

      await _notificationsPlugin.show(
        notificationId,
        'Mengunduh $animeTitle - Ep $episodeNumber',
        'Mengunduh... 0%',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'downloads_channel',
            'Unduhan Episode',
            channelDescription: 'Notifikasi progress unduhan video',
            importance: Importance.low,
            priority: Priority.low,
            showProgress: true,
            maxProgress: 100,
            progress: 0,
            onlyAlertOnce: true,
          ),
        ),
      );

      int lastReportedProgress = -1;

      await _dio.download(
        videoUrl,
        filePath,
        onReceiveProgress: (received, total) async {
          if (total != -1) {
            final progress = received / total;
            final progressPercent = (progress * 100).toInt();
            onProgress(progress);

            if (progressPercent != lastReportedProgress && progressPercent % 5 == 0) {
              lastReportedProgress = progressPercent;
              await _notificationsPlugin.show(
                notificationId,
                'Mengunduh $animeTitle - Ep $episodeNumber',
                'Mengunduh... $progressPercent%',
                NotificationDetails(
                  android: AndroidNotificationDetails(
                    'downloads_channel',
                    'Unduhan Episode',
                    importance: Importance.low,
                    priority: Priority.low,
                    showProgress: true,
                    maxProgress: 100,
                    progress: progressPercent,
                    onlyAlertOnce: true,
                  ),
                ),
              );
            }
          }
        },
      );

      final downloadItem = DownloadItem(
        animeId: animeId,
        animeTitle: animeTitle,
        episodeNumber: episodeNumber,
        filePath: filePath,
        downloadedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await LocalDb.instance.insertDownload(downloadItem);

      await _notificationsPlugin.show(
        notificationId,
        'Unduhan Selesai',
        '$animeTitle Episode $episodeNumber telah siap ditonton offline.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'downloads_channel',
            'Unduhan Episode',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      await _notificationsPlugin.show(
        notificationId,
        'Unduhan Gagal',
        'Gagal mengunduh episode $episodeNumber: ${e.toString()}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'downloads_channel',
            'Unduhan Episode',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
      rethrow;
    }
  }

  Future<void> deleteDownload(DownloadItem item) async {
    try {
      final file = File(item.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
    if (item.id != null) {
      await LocalDb.instance.deleteDownload(item.id!);
    }
  }
}
