import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tax_calculator_provider.dart';
import '../widgets/tax_input_form.dart';
import '../widgets/tax_result_view.dart';
import 'tax_config_list_page.dart';
import 'package:finance_app/core/services/analytics_service.dart';

class TaxCalculatorPage extends StatelessWidget {
  const TaxCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tax Calculator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaxConfigListPage()),
              );
            },
            tooltip: 'Manage Configs',
          ),
          Consumer(
            builder: (context, ref, child) {
              return IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => ref.read(taxInputsProvider.notifier).reset(),
                tooltip: 'Reset Inputs',
              );
            },
          ),
          const SizedBox(width: AppValues.gapSmall),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppValues.paddingLarge),
        child: Column(
          children: [
            const _ConfigSelector(),
            const TaxInputForm(),
            const SizedBox(height: AppValues.gapMedium),
            const TaxResultView(),
          ],
        ),
      ),
    );
  }
}

class _ConfigSelector extends ConsumerWidget {
  const _ConfigSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configsAsync = ref.watch(taxConfigurationsProvider);
    final selectedId = ref.watch(selectedTaxConfigIdProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppValues.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppValues.paddingSmall, bottom: AppValues.gapSmall),
            child: Text(
              'TAX CONFIGURATION',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          configsAsync.when(
            data: (configs) => Container(
              padding: const EdgeInsets.symmetric(horizontal: AppValues.paddingMedium),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(AppValues.borderRadius),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: configs.any((c) => c.id == selectedId) ? selectedId : configs.firstOrNull?.id,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                  onChanged: (id) {
                    if (id != null) {
                      ref.read(selectedTaxConfigIdProvider.notifier).state = id;
                      final configName = configs.firstWhere((c) => c.id == id).name;
                      AnalyticsService().logTaxCalculated(configuration: configName);
                    }
                  },
                  items: configs.map((config) {
                    return DropdownMenuItem(
                      value: config.id,
                      child: Text(
                        config.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            loading: () => const Center(child: LinearProgressIndicator()),
            error: (_, __) => const Text('Error loading configurations'),
          ),
        ],
      ),
    );
  }
}
