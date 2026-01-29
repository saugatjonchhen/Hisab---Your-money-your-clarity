import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/notifications/data/models/notification_model.dart';
import 'package:finance_app/features/notifications/data/repositories/notification_repository.dart';
import 'package:finance_app/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:finance_app/features/transactions/presentation/pages/all_transactions_page.dart';
import 'package:finance_app/features/budget/presentation/pages/budget_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Notifications',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => ref.read(notificationRepositoryProvider).clearAll(),
                child: const Text('Clear All'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          notificationsAsync.when(
            data: (notifications) {
              if (notifications.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No notifications yet', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(AppValues.horizontalPadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notification = notifications[index];
                      return _NotificationItem(notification: notification);
                    },
                    childCount: notifications.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: notification.isRead 
          ? Theme.of(context).cardTheme.color
          : AppColors.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notification.isRead 
              ? Colors.transparent 
              : AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _handleTap(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getColor().withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcon(), color: _getColor(), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMM d, h:mm a').format(notification.timestamp),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.budgetAlert:
        return Icons.warning_amber_rounded;
      case NotificationType.recurringPayment:
        return Icons.repeat_rounded;
      case NotificationType.dailyReminder:
        return Icons.event_note_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  Color _getColor() {
    switch (notification.type) {
      case NotificationType.budgetAlert:
        return Colors.orange;
      case NotificationType.recurringPayment:
        return AppColors.secondary;
      case NotificationType.dailyReminder:
        return AppColors.primary;
      case NotificationType.general:
        return Colors.blue;
    }
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    // Mark as read
    ref.read(notificationRepositoryProvider).markAsRead(notification.id);

    // Navigate
    switch (notification.type) {
      case NotificationType.budgetAlert:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BudgetPage()),
        );
        break;
      case NotificationType.recurringPayment:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AllTransactionsPage()),
        );
        break;
      case NotificationType.dailyReminder:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTransactionPage()),
        );
        break;
      case NotificationType.general:
        // Do nothing for general for now
        break;
    }
  }
}
