import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 20)
enum NotificationType {
  @HiveField(0)
  budgetAlert,
  @HiveField(1)
  recurringPayment,
  @HiveField(2)
  dailyReminder,
  @HiveField(3)
  general
}

@HiveType(typeId: 21)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final NotificationType type;

  @HiveField(5)
  final String? payload;

  @HiveField(6)
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.payload,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'payload': payload,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      timestamp: DateTime.parse(map['timestamp']),
      type: NotificationType.values.byName(map['type']),
      payload: map['payload'],
      isRead: map['isRead'] ?? false,
    );
  }
}
