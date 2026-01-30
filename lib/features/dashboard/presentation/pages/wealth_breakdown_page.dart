import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:finance_app/features/transactions/presentation/pages/all_transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WealthBreakdownPage extends ConsumerWidget {
  const WealthBreakdownPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wealthAsync = ref.watch(totalWealthProvider);
    final liquidAsync = ref.watch(liquidCashProvider);
    final spendableAsync = ref.watch(filteredBalanceProvider);
    final committedAsync = ref.watch(remainingCommittedExpensesProvider);
    final breakdownAsync = ref.watch(spendingBreakdownProvider);
    final incomeAsync = ref.watch(totalIncomeProvider);

    final savingsAsync = ref.watch(totalSavingsProvider);
    final investmentAsync = ref.watch(totalInvestmentProvider);

    final settingsAsync = ref.watch(settingsProvider);
    final currencySymbol = settingsAsync.when(
      data: (s) => s.currencySymbol,
      loading: () => '\$',
      error: (_, __) => '\$',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wealth Breakdown'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppValues.horizontalPadding),
        child: Column(
          children: [
            _buildTotalAssetCard(
              context,
              wealth: wealthAsync.valueOrNull ?? 0.0,
              currencySymbol: currencySymbol,
            ),
            const SizedBox(height: AppValues.gapLarge),
            _buildAllocationSection(
              context,
              liquid: liquidAsync.valueOrNull ?? 0.0,
              savings: savingsAsync.valueOrNull ?? 0.0,
              investments: investmentAsync.valueOrNull ?? 0.0,
              currencySymbol: currencySymbol,
            ),
            const SizedBox(height: AppValues.gapLarge),
            _buildSpendableLogicCard(
              context,
              income: incomeAsync.valueOrNull ?? 0.0,
              totalReserved: breakdownAsync.valueOrNull?.totalReserved ?? 0.0,
              otherSpent: breakdownAsync.valueOrNull?.otherSpent ?? 0.0,
              spendable: spendableAsync.valueOrNull ?? 0.0,
              currencySymbol: currencySymbol,
            ),
            const SizedBox(height: AppValues.gapExtraLarge),
            _buildInfoTip(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAssetCard(BuildContext context,
      {required double wealth, required String currencySymbol}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Assets (Wealth)',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$currencySymbol${wealth.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Calculated: Income - Expenses',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationSection(
    BuildContext context, {
    required double liquid,
    required double savings,
    required double investments,
    required String currencySymbol,
  }) {
    final total = liquid + savings + investments;
    final liquidPercent = total > 0 ? liquid / total : 0.0;
    final savingsPercent = total > 0 ? savings / total : 0.0;
    final investmentsPercent = total > 0 ? investments / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Asset Allocation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 24,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardTheme.color,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                if (liquidPercent > 0)
                  Expanded(
                      flex: (liquidPercent * 100).toInt(),
                      child: Container(color: AppColors.primary)),
                if (savingsPercent > 0)
                  Expanded(
                      flex: (savingsPercent * 100).toInt(),
                      child: Container(color: AppColors.savings)),
                if (investmentsPercent > 0)
                  Expanded(
                      flex: (investmentsPercent * 100).toInt(),
                      child: Container(color: AppColors.investment)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildAllocationItem(
            context, 'Liquid Cash', liquid, AppColors.primary, currencySymbol),
        _buildAllocationItem(context, 'Total Savings', savings,
            AppColors.savings, currencySymbol),
        _buildAllocationItem(context, 'Total Investments', investments,
            AppColors.investment, currencySymbol),
      ],
    );
  }

  Widget _buildAllocationItem(BuildContext context, String title, double amount,
      Color color, String currencySymbol) {
    String? filterType;
    if (title == 'Total Savings') filterType = 'Savings';
    if (title == 'Total Investments') filterType = 'Investment';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: filterType != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AllTransactionsPage(initialFilter: filterType),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w500))),
              Text(
                '$currencySymbol${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (filterType != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: Theme.of(context).disabledColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendableLogicCard(
    BuildContext context, {
    required double income,
    required double totalReserved,
    required double otherSpent,
    required double spendable,
    required String currencySymbol,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Spending Logic',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLogicRow(context, 'Total Income', income, currencySymbol,
              isPositive: true),
          const SizedBox(height: 12),
          _buildLogicRow(context, 'Reserved for Bills (Planned)', totalReserved,
              currencySymbol,
              isPositive: false),
          const SizedBox(height: 12),
          _buildLogicRow(
              context, 'Other Expenses (Paid)', otherSpent, currencySymbol,
              isPositive: false),
          const Divider(height: 32),
          _buildLogicRow(
              context, 'True Spendable Balance', spendable, currencySymbol,
              isPositive: true, isBold: true),
        ],
      ),
    );
  }

  Widget _buildLogicRow(
      BuildContext context, String title, double amount, String currencySymbol,
      {required bool isPositive, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          '${isPositive ? "" : "-"}$currencySymbol${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold
                ? AppColors.primary
                : (isPositive ? null : Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 20, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your spendable balance aligns with your budget and ensures you don\'t touch the money needed for your plans.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
