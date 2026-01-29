import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/notification_model.dart';

final notificationRepositoryProvider = Provider((ref) => NotificationRepository());

final notificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) async* {
  final box = Hive.box<NotificationModel>('notifications');
  
  // Listen to changes in the box
  yield box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  
  await for (final _ in box.watch()) {
    yield box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
});

class NotificationRepository {
  final Box<NotificationModel> _box = Hive.box<NotificationModel>('notifications');

  List<NotificationModel> getNotifications() {
    final notifications = _box.values.toList();
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  Future<void> addNotification(NotificationModel notification) async {
    await _box.put(notification.id, notification);
  }

  Future<void> markAsRead(String id) async {
    final notification = _box.get(id);
    if (notification != null) {
      notification.isRead = true;
      await notification.save();
    }
  }

  Future<void> markAllAsRead() async {
    for (final notification in _box.values) {
      if (!notification.isRead) {
        notification.isRead = true;
        await notification.save();
      }
    }
  }

  Future<void> deleteNotification(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  int getUnreadCount() {
    return _box.values.where((n) => !n.isRead).length;
  }
}
