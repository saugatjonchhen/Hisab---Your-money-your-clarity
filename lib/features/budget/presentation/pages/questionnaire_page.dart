import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/core/theme/app_values.dart';
import 'package:finance_app/features/budget/presentation/providers/budget_providers.dart';
import 'package:finance_app/features/budget/presentation/pages/plan_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestionnairePage extends ConsumerStatefulWidget {
  const QuestionnairePage({super.key});

  @override
  ConsumerState<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends ConsumerState<QuestionnairePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetQuestionnaireStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of $_totalSteps'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevStep,
              )
            : null,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            color: AppColors.secondary,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _IncomeStep(),
                _FixedExpensesStep(),
                _VariableExpensesStep(),
                _PreferencesStep(),
                _LifestyleStep(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: AppValues.screenPadding,
          child: ElevatedButton(
            onPressed: _canGoNext(state) ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.3),
            ),
            child: Text(_currentStep == _totalSteps - 1 ? 'Generate Plans' : 'Next'),
          ),
        ),
      ),
    );
  }

  bool _canGoNext(dynamic state) {
    switch (_currentStep) {
      case 0: // Income
        return state.primaryIncome > 0;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlanSelectionPage()),
      );
    }
  }

  void _prevStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

class _IncomeStep extends ConsumerStatefulWidget {
  @override
  ConsumerState<_IncomeStep> createState() => _IncomeStepState();
}

class _IncomeStepState extends ConsumerState<_IncomeStep> {
  late TextEditingController _primaryController;
  late TextEditingController _secondaryController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(budgetQuestionnaireStateProvider);
    _primaryController = TextEditingController(text: state.primaryIncome == 0 ? '' : state.primaryIncome.toString());
    _secondaryController = TextEditingController(text: state.secondaryIncome == 0 ? '' : state.secondaryIncome.toString());
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppValues.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Income', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppValues.gapSmall),
          const Text('How much do you earn each month?', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: AppValues.gapLarge),
          TextField(
            controller: _primaryController,
            decoration: InputDecoration(
              labelText: 'Primary Income (Salary/Business)',
              prefixText: 'Rs. ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppValues.borderRadius)),
            ),
            keyboardType: TextInputType.number,
            onChanged: (val) => ref.read(budgetQuestionnaireStateProvider.notifier).updateIncome(primary: double.tryParse(val) ?? 0),
          ),
          const SizedBox(height: AppValues.gapMedium),
          TextField(
            controller: _secondaryController,
            decoration: InputDecoration(
              labelText: 'Secondary Income (Freelance/Other)',
              prefixText: 'Rs. ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppValues.borderRadius)),
            ),
            keyboardType: TextInputType.number,
            onChanged: (val) => ref.read(budgetQuestionnaireStateProvider.notifier).updateIncome(secondary: double.tryParse(val) ?? 0),
          ),
        ],
      ),
    );
  }
}

class _FixedExpensesStep extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FixedExpensesStep> createState() => _FixedExpensesStepState();
}

class _FixedExpensesStepState extends ConsumerState<_FixedExpensesStep> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final state = ref.read(budgetQuestionnaireStateProvider);
    state.fixedExpenses.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value == 0 ? '' : value.toString());
    });
    // Ensure all expected keys have controllers
    ['rent', 'emi', 'utilities', 'education'].forEach((key) {
      if (!_controllers.containsKey(key)) {
        _controllers[key] = TextEditingController();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppValues.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fixed Commitments', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppValues.gapSmall),
          const Text('Your monthly "Needs" (Rent, EMI, Utilities)', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: AppValues.gapLarge),
          _buildExpenseItem('Rent / Housing', 'rent'),
          _buildExpenseItem('EMI / Loan', 'emi'),
          _buildExpenseItem('Utilities (Net/Water/Elec)', 'utilities'),
          _buildExpenseItem('Education Fees', 'education'),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppValues.gapMedium),
      child: TextField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          prefixText: 'Rs. ',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppValues.borderRadius)),
        ),
        keyboardType: TextInputType.number,
        onChanged: (val) {
          final state = ref.read(budgetQuestionnaireStateProvider);
          final expenses = Map<String, double>.from(state.fixedExpenses);
          expenses[key] = double.tryParse(val) ?? 0;
          ref.read(budgetQuestionnaireStateProvider.notifier).updateFixedExpenses(expenses);
        },
      ),
    );
  }
}

class _VariableExpensesStep extends ConsumerStatefulWidget {
  @override
  ConsumerState<_VariableExpensesStep> createState() => _VariableExpensesStepState();
}

class _VariableExpensesStepState extends ConsumerState<_VariableExpensesStep> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final state = ref.read(budgetQuestionnaireStateProvider);
    state.variableExpenses.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value == 0 ? '' : value.toString());
    });
    // Ensure all expected keys have controllers
    ['food', 'transport', 'entertainment', 'festival'].forEach((key) {
      if (!_controllers.containsKey(key)) {
        _controllers[key] = TextEditingController();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppValues.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Variable Expenses', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppValues.gapSmall),
          const Text('Your monthly "Wants" & Living costs', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: AppValues.gapLarge),
          _buildExpenseItem('Food & Groceries', 'food'),
          _buildExpenseItem('Transportation', 'transport'),
          _buildExpenseItem('Entertainment', 'entertainment'),
          _buildExpenseItem('Festivals (Avg. Monthly)', 'festival'),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppValues.gapMedium),
      child: TextField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          prefixText: 'Rs. ',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppValues.borderRadius)),
        ),
        keyboardType: TextInputType.number,
        onChanged: (val) {
          final state = ref.read(budgetQuestionnaireStateProvider);
          final expenses = Map<String, double>.from(state.variableExpenses);
          expenses[key] = double.tryParse(val) ?? 0;
          ref.read(budgetQuestionnaireStateProvider.notifier).updateVariableExpenses(expenses);
        },
      ),
    );
  }
}

class _PreferencesStep extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PreferencesStep> createState() => _PreferencesStepState();
}

class _PreferencesStepState extends ConsumerState<_PreferencesStep> {
  late TextEditingController _savingsController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(budgetQuestionnaireStateProvider);
    _savingsController = TextEditingController(text: state.desiredSavings == 0 ? '' : state.desiredSavings.toString());
  }

  @override
  void dispose() {
    _savingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetQuestionnaireStateProvider);
    return Padding(
      padding: AppValues.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Savings & Goals', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppValues.gapLarge),
          SwitchListTile(
            title: const Text('Do you currently save money?'),
            value: state.savesMoney,
            onChanged: (val) => ref.read(budgetQuestionnaireStateProvider.notifier).updatePreferences(saves: val),
          ),
          const SizedBox(height: AppValues.gapMedium),
          TextField(
            controller: _savingsController,
            decoration: InputDecoration(
              labelText: 'Desired Monthly Savings',
              prefixText: 'Rs. ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppValues.borderRadius)),
            ),
            keyboardType: TextInputType.number,
            onChanged: (val) => ref.read(budgetQuestionnaireStateProvider.notifier).updatePreferences(savings: double.tryParse(val) ?? 0),
          ),
          const Divider(height: AppValues.gapExtraLarge),
          Text('Emergency Fund Goal: ${state.emergencyFundGoalMonths} Months', style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: state.emergencyFundGoalMonths.toDouble(),
            min: 1,
            max: 12,
            divisions: 11,
            label: state.emergencyFundGoalMonths.toString(),
            onChanged: (val) => ref.read(budgetQuestionnaireStateProvider.notifier).updatePreferences(emergencyMonths: val.toInt()),
          ),
        ],
      ),
    );
  }
}

class _LifestyleStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetQuestionnaireStateProvider);
    return Padding(
      padding: AppValues.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lifestyle & Priorities', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppValues.gapLarge),
          const Text('What is most important to you?', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppValues.gapMedium),
          // Simple selection for now, could be a ReorderableList
          Wrap(
            spacing: AppValues.gapSmall,
            runSpacing: AppValues.gapSmall,
            children: ['Saving', 'Investing', 'Spending', 'Debt'].map((p) {
              final isSelected = state.priorityOrder.first == p;
              return ChoiceChip(
                label: Text(p),
                selected: isSelected,
                onSelected: (val) {
                  if (val) {
                    final newOrder = List<String>.from(state.priorityOrder);
                    newOrder.remove(p);
                    newOrder.insert(0, p);
                    ref.read(budgetQuestionnaireStateProvider.notifier).updatePreferences(priorities: newOrder);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppValues.gapExtraLarge),
          const Text('Comfort with strict limits', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppValues.gapMedium),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Low', label: Text('Low')),
              ButtonSegment(value: 'Medium', label: Text('Med')),
              ButtonSegment(value: 'High', label: Text('High')),
            ],
            selected: <String>{state.lifestyleFlexibility},
            onSelectionChanged: (val) => ref.read(budgetQuestionnaireStateProvider.notifier).updatePreferences(flexibility: val.first),
          ),
        ],
      ),
    );
  }
}
