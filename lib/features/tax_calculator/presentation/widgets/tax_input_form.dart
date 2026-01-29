import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tax_calculator_provider.dart';
import 'package:finance_app/core/theme/app_colors.dart';

class TaxInputForm extends ConsumerWidget {
  const TaxInputForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputs = ref.watch(taxInputsProvider);
    final notifier = ref.read(taxInputsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Personal & Employment'),
          _FormCard(
            child: Column(
              children: [
                _MoneyInput(
                  label: 'Monthly Gross Salary',
                  value: inputs.monthlyGrossSalary,
                  onChanged: notifier.updateGrossSalary,
                  tooltip: 'Total earnings before any deductions',
                ),
                _MoneyInput(
                  label: 'Monthly Basic Salary',
                  value: inputs.monthlyBasicSalary,
                  onChanged: notifier.updateBasicSalary,
                  tooltip: 'Usually 60-70% of gross salary',
                ),
                _SwitchInput(
                  label: 'Married Status',
                  value: inputs.isMarried,
                  onChanged: notifier.updateMaritalStatus,
                  activeLabel: 'Married',
                  inactiveLabel: 'Single',
                ),
                _SwitchInput(
                  label: 'Enrolled in SSF',
                  value: inputs.isEnrolledInSSF,
                  onChanged: notifier.updateSSFStatus,
                  activeLabel: 'Yes',
                  inactiveLabel: 'No',
                ),
                _SwitchInput(
                  label: 'Female Tax Rebate',
                  value: inputs.hasFemaleTaxRebate,
                  onChanged: notifier.updateFemaleRebate,
                  activeLabel: 'Yes',
                  inactiveLabel: 'No',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Monthly / Annual Deductions'),
          _FormCard(
            child: Column(
              children: [
                _MoneyInput(
                  label: 'Monthly CIT Contribution',
                  value: inputs.monthlyCITContribution,
                  onChanged: notifier.updateCIT,
                  tooltip: 'Citizen Investment Trust contribution',
                ),
                _MoneyInput(
                  label: 'Monthly SSF Contribution',
                  value: inputs.monthlySSFContribution,
                  onChanged: notifier.updateSSF,
                  tooltip: 'Social Security Fund contribution',
                ),
                _MoneyInput(
                  label: 'Annual Life Insurance',
                  value: inputs.annualLifeInsurance,
                  onChanged: notifier.updateLifeInsurance,
                  tooltip: 'Maximum deduction: Rs. 40,000 combined',
                ),
                _MoneyInput(
                  label: 'Annual Health Insurance',
                  value: inputs.annualHealthInsurance,
                  onChanged: notifier.updateHealthInsurance,
                ),
                _MoneyInput(
                  label: 'Annual Incentives (Festive, Leave, etc.)',
                  value: inputs.annualIncentives,
                  onChanged: notifier.updateIncentives,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

class _MoneyInput extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;
  final String? tooltip;

  const _MoneyInput({
    required this.label,
    required this.value,
    required this.onChanged,
    this.tooltip,
  });

  @override
  State<_MoneyInput> createState() => _MoneyInputState();
}

class _MoneyInputState extends State<_MoneyInput> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value == 0 ? '' : widget.value.toStringAsFixed(0),
    );
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(_MoneyInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && widget.value != double.tryParse(_controller.text)) {
      _controller.text = widget.value == 0 ? '' : widget.value.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              if (widget.tooltip != null) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: widget.tooltip!,
                  child: Icon(Icons.info_outline_rounded, size: 14, color: Colors.grey[500]),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isFocused 
                  ? (isDark ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.05))
                  : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isFocused ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: Container(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Text(
                    'Rs.',
                    style: TextStyle(
                      color: _isFocused ? AppColors.primary : Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
              onChanged: (val) {
                final doubleValue = double.tryParse(val.replaceAll(',', '')) ?? 0;
                widget.onChanged(doubleValue);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchInput extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;
  final String activeLabel;
  final String inactiveLabel;

  const _SwitchInput({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeLabel,
    required this.inactiveLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                Text(
                  value ? activeLabel : inactiveLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: value ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ],
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
