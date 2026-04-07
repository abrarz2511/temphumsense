import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'threshold_service.dart';

/// Service for handling local notifications when thresholds are exceeded.
///
/// This service manages notification channels, scheduling, and display
/// for threshold alerts on both iOS and Android platforms.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Notification channel configuration for Android
  static const AndroidNotificationChannel _alertChannel = AndroidNotificationChannel(
    'threshold_alerts',
    'Threshold Alerts',
    description: 'Notifications when sensor readings exceed safe thresholds',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create the notification channel for Android
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_alertChannel);

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Request notification permissions (required for iOS and Android 13+)
  Future<bool> requestPermissions() async {
    // Android permissions
    final androidGranted = await _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        true;

    // iOS permissions
    final iosGranted = await _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
        true;

    return androidGranted && iosGranted;
  }

  /// Show notification for temperature threshold alert
  Future<void> showTemperatureAlert({
    required double temperature,
    required double threshold,
    double? exceededBy,
  }) async {
    final title = 'Temperature Alert';
    final body = exceededBy != null
        ? 'Body temperature is ${temperature.toStringAsFixed(1)}°F, '
            'exceeding the ${threshold.toStringAsFixed(0)}°F threshold by '
            '${exceededBy.toStringAsFixed(1)}°F'
        : 'Body temperature (${temperature.toStringAsFixed(1)}°F) has exceeded '
            'the safe threshold of ${threshold.toStringAsFixed(0)}°F';

    await _showNotification(
      id: 1,
      title: title,
      body: body,
      channel: _alertChannel,
      priority: Priority.high,
    );
  }

  /// Show notification for sweat level threshold alert
  Future<void> showSweatLevelAlert({
    required double sweatLevel,
    required double threshold,
    double? exceededBy,
  }) async {
    final title = 'Sweat Level Alert';
    final body = exceededBy != null
        ? 'Sweat level is ${sweatLevel.toStringAsFixed(1)}%RH, '
            'exceeding the ${threshold.toStringAsFixed(0)}%RH threshold by '
            '${exceededBy.toStringAsFixed(1)}%RH'
        : 'Sweat level (${sweatLevel.toStringAsFixed(1)}%RH) has exceeded '
            'the safe threshold of ${threshold.toStringAsFixed(0)}%RH';

    await _showNotification(
      id: 2,
      title: title,
      body: body,
      channel: _alertChannel,
      priority: Priority.high,
    );
  }

  /// Show combined alert for both thresholds
  Future<void> showCombinedAlert(SensorThresholdStatus status) async {
    if (!status.hasAlert) return;

    final title = 'Health Alert';
    final bodyParts = <String>[];

    if (status.temperatureStatus == ThresholdResult.alert) {
      bodyParts.add('High temperature');
    }
    if (status.sweatLevelStatus == ThresholdResult.alert) {
      bodyParts.add('High sweat level');
    }

    final body = '${bodyParts.join(' and ')} exceeded safe thresholds. '
        'Please check your readings.';

    await _showNotification(
      id: 0,
      title: title,
      body: body,
      channel: _alertChannel,
      priority: Priority.max,
    );
  }

  /// Process sensor readings and trigger notifications if needed
  Future<void> processThresholdAlerts(SensorThresholdStatus status) async {
    if (!status.hasAlert) return;

    // Show individual alerts
    if (status.temperatureStatus == ThresholdResult.alert) {
      await showTemperatureAlert(
        temperature: ThresholdService.temperatureThreshold +
            (status.temperatureExceededBy ?? 0),
        threshold: ThresholdService.temperatureThreshold,
        exceededBy: status.temperatureExceededBy,
      );
    }

    if (status.sweatLevelStatus == ThresholdResult.alert) {
      await showSweatLevelAlert(
        sweatLevel: ThresholdService.sweatLevelThreshold +
            (status.sweatLevelExceededBy ?? 0),
        threshold: ThresholdService.sweatLevelThreshold,
        exceededBy: status.sweatLevelExceededBy,
      );
    }

    // Show combined alert if both thresholds exceeded
    if (status.temperatureStatus == ThresholdResult.alert &&
        status.sweatLevelStatus == ThresholdResult.alert) {
      await showCombinedAlert(status);
    }
  }

  /// Internal method to show notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required AndroidNotificationChannel channel,
    required Priority priority,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: priority,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, notificationDetails);
    debugPrint('Notification shown: $title');
  }

  /// Cancel all active notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('All notifications cancelled');
  }

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('Notification $id cancelled');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Add navigation logic here if needed
  }
}