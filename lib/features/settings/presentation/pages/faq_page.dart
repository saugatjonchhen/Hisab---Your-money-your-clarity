import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
      ),
      body: ListView(
        padding: AppValues.screenPadding,
        children: const [
          _FaqItem(
            question: 'How do I backup my data?',
            answer: 'Go to Settings > Data and tap "Backup Data". You can save the backup file to your device or cloud storage.',
          ),
          _FaqItem(
            question: 'How do I restore my data?',
            answer: 'Go to Settings > Data and tap "Restore Data". Select a previously created backup file to restore your transactions and settings.',
          ),
          _FaqItem(
            question: 'Can I change my currency?',
            answer: 'Yes, go to Settings > Preferences > Currency to select your preferred currency.',
          ),
          _FaqItem(
            question: 'What is a custom budget cycle?',
            answer: 'Instead of the 1st of the month, you can set your budget to start on your salary date (e.g., 25th) in Settings > Preferences > Budget Cycle.',
          ),
          _FaqItem(
            question: 'How do I delete all my data?',
            answer: 'Go to Settings > Danger Zone > Factory Reset. Warning: This cannot be undone!',
          ),
          _FaqItem(
            question: 'How do I add a recurring transaction?',
            answer: 'Go to Settings > Data > Recurring Transactions to manage your regular income or expenses.',
          ),
          _FaqItem(
            question: 'Where can I see my spending visualization?',
            answer: 'Check the Dashboard for a quick overview or the Budget tab for detailed insights.',
          ),
          _FaqItem(
            question: 'Can I customize categories?',
            answer: 'Yes, navigate to Settings > Data > Manage Categories to add or remove categories.',
          ),
          _FaqItem(
            question: 'Does the app sync with my bank?',
            answer: 'No, this is a privacy-focused offline app. All data is stored locally on your device.',
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppValues.gapSmall),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppValues.borderRadius)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.primary,
        shape: const Border(), // Remove default borders
        childrenPadding: const EdgeInsets.only(
          left: AppValues.gapMedium,
          right: AppValues.gapMedium,
          bottom: AppValues.gapMedium,
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(height: 1.5, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
