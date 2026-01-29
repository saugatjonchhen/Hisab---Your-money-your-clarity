import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tax_calculator_provider.dart';
import 'package:finance_app/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class TaxResultView extends ConsumerWidget {
  const TaxResultView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputs = ref.watch(taxInputsProvider);
    final result = ref.watch(taxResultProvider);
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 2);

    if (result == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ResultSectionHeader(title: 'Tax Summary'),
          
          // Summary Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _SummaryCard(
                label: 'Annual Income',
                value: result.annualAssessableIncome,
                color: Colors.blueAccent,
                format: currencyFormat,
              ),
              _SummaryCard(
                label: 'Taxable Income',
                value: result.netTaxableIncome,
                color: Colors.teal,
                format: currencyFormat,
              ),
              _SummaryCard(
                label: 'Annual CIT',
                value: result.annualCIT,
                color: Colors.purpleAccent,
                format: currencyFormat,
              ),
              _SummaryCard(
                label: 'Annual SSF',
                value: result.annualSSF,
                color: Colors.indigoAccent,
                format: currencyFormat,
              ),
              _SummaryCard(
                label: 'Annual Tax',
                value: result.finalAnnualTax,
                color: Colors.redAccent,
                format: currencyFormat,
              ),
              _SummaryCard(
                label: 'Monthly TDS',
                value: result.monthlyTDS,
                color: Colors.orangeAccent,
                format: currencyFormat,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          const _ResultSectionHeader(title: 'Monthly In-Hand Salary'),
          _InHandSalaryCard(
            inputs: inputs,
            result: result,
            format: currencyFormat,
          ),

          const SizedBox(height: 24),
          const _ResultSectionHeader(title: 'Tax Slab Breakdown'),
          _SlabBreakdownList(
            result: result,
            format: currencyFormat,
          ),
        ],
      ),
    );
  }
}

class _ResultSectionHeader extends StatelessWidget {
  final String title;
  const _ResultSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final NumberFormat format;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              format.format(value),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InHandSalaryCard extends StatelessWidget {
  final dynamic inputs;
  final dynamic result;
  final NumberFormat format;

  const _InHandSalaryCard({required this.inputs, required this.result, required this.format});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Estimated Monthly Take-Home',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            format.format(result.monthlyInHandSalary),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          _InHandRow(label: 'Gross Salary', value: inputs.monthlyGrossSalary),
          _InHandRow(label: 'Monthly TDS (Tax)', value: -result.monthlyTDS),
          if (inputs.monthlyCITContribution > 0)
            _InHandRow(label: 'CIT Contribution', value: -inputs.monthlyCITContribution),
          if (inputs.monthlySSFContribution > 0)
            _InHandRow(label: 'SSF Contribution', value: -inputs.monthlySSFContribution),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Final In-Hand',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                format.format(result.monthlyInHandSalary),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InHandRow extends StatelessWidget {
  final String label;
  final double value;

  const _InHandRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          Text(
            (value >= 0 ? '+' : '-') + NumberFormat.currency(symbol: '', decimalDigits: 0).format(value.abs()),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlabBreakdownList extends StatelessWidget {
  final dynamic result;
  final NumberFormat format;

  const _SlabBreakdownList({required this.result, required this.format});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: result.slabResults.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final slab = result.slabResults[index];
          final isActive = slab.taxableAmountInSlab > 0;
          
          return ListTile(
            dense: true,
            title: Text(
              slab.slabName,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? null : Colors.grey,
              ),
            ),
            subtitle: isActive 
              ? Text('Taxable: ${format.format(slab.taxableAmountInSlab)}')
              : null,
            trailing: Text(
              format.format(slab.taxAmount),
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.redAccent : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
