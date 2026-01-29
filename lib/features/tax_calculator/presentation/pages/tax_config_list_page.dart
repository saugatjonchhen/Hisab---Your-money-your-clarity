import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/tax_calculator_models.dart';
import '../providers/tax_calculator_provider.dart';
import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart'; // Added import
import 'tax_config_edit_page.dart';

class TaxConfigListPage extends ConsumerWidget {
  const TaxConfigListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configsAsync = ref.watch(taxConfigurationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Configurations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaxConfigEditPage()),
              );
            },
            tooltip: 'Add New Config',
          ),
        ],
      ),
      body: configsAsync.when(
        data: (configs) {
          if (configs.isEmpty) {
            return const Center(child: Text('No configurations found.'));
          }

          return ListView.separated(
            padding: AppValues.screenPadding, // Replaced hardcoded padding
            itemCount: configs.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppValues.gapMedium), // Replaced hardcoded spacing
            itemBuilder: (context, index) {
              final config = configs[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: AppValues.paddingMedium, vertical: AppValues.paddingSmall), // Replaced hardcoded padding
                  title: Text(
                    config.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    config.isDefault ? 'Standard Slabs' : 'Custom Slabs',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaxConfigEditPage(config: config),
                            ),
                          );
                        },
                      ),
                      if (!config.isDefault)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(context, ref, config),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Configuration?'),
        content: Text('Are you sure you want to delete "${config.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(taxConfigurationsProvider.notifier).deleteConfig(config.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
