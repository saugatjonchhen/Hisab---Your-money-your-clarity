import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DateSelector extends ConsumerWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(dashboardDateProvider);
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () {
              ref.read(dashboardDateProvider.notifier).previousDay();
            },
            color: Theme.of(context).textTheme.bodyLarge?.color,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: Theme.of(context).cardTheme.color ?? Colors.white,
                        onSurface: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                ref.read(dashboardDateProvider.notifier).setDate(pickedDate);
              }
            },
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded, 
                  size: 16, 
                  color: AppColors.primary
                ),
                const SizedBox(width: 8),
                Text(
                  isToday 
                    ? 'Today' 
                    : DateFormat('MMM d, y').format(selectedDate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: isToday
                ? null
                : () {
                    ref.read(dashboardDateProvider.notifier).nextDay();
                  },
            color: isToday ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyLarge?.color,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
