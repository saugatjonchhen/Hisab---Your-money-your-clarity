import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:finance_app/features/notifications/data/models/notification_model.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Skip notification setup on web - local notifications don't work on web
    if (kIsWeb) {
      debugPrint('NotificationService: Skipping init on web platform');
      return;
    }

    // Initialize timezone
    tz.initializeTimeZones();
    String timeZoneName = await FlutterTimezone.getLocalTimezone();
    
    // Handle timezone name aliases (e.g., Asia/Katmandu -> Asia/Kathmandu)
    final timezoneAliases = {
      'Asia/Katmandu': 'Asia/Kathmandu',
      'US/Eastern': 'America/New_York',
      'US/Pacific': 'America/Los_Angeles',
    };
    timeZoneName = timezoneAliases[timeZoneName] ?? timeZoneName;
    
    try {
      final location = tz.getLocation(timeZoneName);
      tz.setLocalLocation(location);
      debugPrint('NotificationService: Local location set to $timeZoneName (${location.name})');
    } catch (e) {
      debugPrint('NotificationService: Unknown timezone $timeZoneName, using UTC');
      tz.setLocalLocation(tz.UTC);
    }
    
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap if needed
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Request permissions for Android 13+
    await requestPermissions();
  }

  /// Request notification permissions explicitly
  Future<void> requestPermissions() async {
    if (kIsWeb) return;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      await androidPlugin?.requestNotificationsPermission();
      // For exact alarms or other specific android permissions
      await androidPlugin?.requestExactAlarmsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('NotificationService: Showing immediate notification "$title"');
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'main_channel_v3', // Incremented version to ensure fresh settings
      'General Alerts',
      channelDescription: 'General alerts for finance app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _notificationsPlugin.show(id, title, body, notificationDetails, payload: payload);
      await _saveNotification(title, body, payload);
    } catch (e) {
      debugPrint('NotificationService error: $e');
    }
  }

  Future<void> _saveNotification(String title, String body, String? payload) async {
    try {
      final box = Hive.box<NotificationModel>('notifications');
      NotificationType type = NotificationType.general;
      
      if (payload != null) {
        if (payload.contains('budget')) {
          type = NotificationType.budgetAlert;
        } else if (payload.contains('recurring')) {
          type = NotificationType.recurringPayment;
        } else if (payload.contains('daily')) {
          type = NotificationType.dailyReminder;
        }
      }

      final notification = NotificationModel(
        id: const Uuid().v4(),
        title: title,
        body: body,
        timestamp: DateTime.now(),
        type: type,
        payload: payload,
      );

      // Avoid duplicate daily reminders for the same day
      if (type == NotificationType.dailyReminder) {
        final existing = box.values.where((n) {
          final now = DateTime.now();
          return n.type == NotificationType.dailyReminder &&
                 n.timestamp.year == now.year &&
                 n.timestamp.month == now.month &&
                 n.timestamp.day == now.day;
        });
        if (existing.isNotEmpty) return;
      }

      await box.put(notification.id, notification);
    } catch (e) {
      debugPrint('Error saving notification to Hive: $e');
    }
  }

  /// Schedule a recurring daily notification at a specific time
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final scheduledDate = _nextInstanceOfTime(hour, minute);
    debugPrint('NotificationService: Scheduling daily reminder for $hour:$minute. Next instance: $scheduledDate');

    final notificationDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder_v4',
        'Daily Reminders',
        channelDescription: 'Reminder to log your daily expenses',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        fullScreenIntent: false,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final hasPermission = await androidPlugin?.canScheduleExactNotifications() ?? false;
      debugPrint('NotificationService: Has exact alarm permission: $hasPermission');

      if (!kIsWeb) {
        debugPrint('NotificationService: Scheduling at TZDateTime: $scheduledDate');
        // Try exact scheduling first
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
      
      // If we are on Web or scheduling succeeded, we can log it if we want.
      // For daily reminders, we don't save to history immediately because it 
      // hasn't "triggered" for the user yet. 
      // However, if the user requested it shown in list, we might want to 
      // save it when it's actually "due".
    } catch (e) {
      if (!kIsWeb) {
        debugPrint('NotificationService: Daily reminder scheduling failed. Error: $e');
        // Fallback to inexact scheduling
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
  }

  /// Show a test notification after a short delay (for verification)
  Future<void> testNotification() async {
    if (kIsWeb) {
      debugPrint('NotificationService: Test notification skipped on web');
      return;
    }

    try {
      debugPrint('NotificationService: Sending immediate test notification');
      await showNotification(
        id: 999,
        title: 'Test Notification (Immediate)',
        body: 'This confirms foreground notification delivery.',
        payload: 'test_notification',
      );
      
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
      final hasExact = await androidPlugin?.requestExactAlarmsPermission() ?? false;
      debugPrint('NotificationService: Exact alarms permitted (via request): $hasExact');

      // Schedule one for 10 seconds later
      final scheduledDate = DateTime.now().add(const Duration(seconds: 10));
      debugPrint('NotificationService: Scheduling background test for $scheduledDate');

      await scheduleNotification(
        id: 998,
        title: 'Background Test (10s later)',
        body: 'If you see this, background delivery is working correctly!',
        scheduledDate: scheduledDate,
      );
      
      debugPrint('Test notifications triggered and scheduled');
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      rethrow;
    }
  }

  /// Calculate the next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Schedule a one-time notification at a specific date and time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final notificationDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        'scheduled_alerts_v4',
        'Scheduled Alerts',
        channelDescription: 'Alerts for specific times',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final hasPermission = await androidPlugin?.canScheduleExactNotifications() ?? false;
      
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      debugPrint('NotificationService: Scheduling one-time notification for $scheduledDate');
      debugPrint('NotificationService: TZDateTime: $tzScheduledDate');
      debugPrint('NotificationService: Current time: ${DateTime.now()}');
      debugPrint('NotificationService: Current TZ time: ${tz.TZDateTime.now(tz.local)}');
      debugPrint('NotificationService: Has exact alarm permission: $hasPermission');

      if (!kIsWeb) {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tzScheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      
      // If the scheduled date is very soon (e.g. within 1 minute), 
      // we save it to the history list immediately for visibility.
      if (scheduledDate.difference(DateTime.now()).inSeconds < 60) {
        await _saveNotification(title, body, payload);
      }
    } catch (e) {
      if (!kIsWeb) {
        debugPrint('NotificationService: Exact scheduling failed, falling back to inexact. Error: $e');
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }
  
  // Note: For scheduled notifications, we don't save them to the repository yet 
  // because they haven't "happened" for the user. 
  // We should ideally save them when the notification is delivered/received.
  // For now, we'll only save immediate ones or let the logic that schedules them 
  // also handle saving if it should appear in the history immediately.

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
  
  /// Cancel a specific notification by ID
  Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
