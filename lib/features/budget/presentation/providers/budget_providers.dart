import 'package:finance_app/features/budget/data/models/budget_models.dart';
import 'package:finance_app/features/budget/domain/engine/budget_engine.dart';
import 'package:finance_app/features/budget/domain/services/budget_sync_service.dart';
import 'package:finance_app/features/transactions/data/providers/transaction_provider.dart';
import 'package:finance_app/features/transactions/data/providers/category_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive/hive.dart';
import 'dart:math';

part 'budget_providers.g.dart';

@riverpod
class BudgetQuestionnaireState extends _$BudgetQuestionnaireState {
  Box<BudgetQuestionnaire> get _box => Hive.box<BudgetQuestionnaire>('budget_questionnaire');

  @override
  BudgetQuestionnaire build() {
    return _box.get('current') ?? BudgetQuestionnaire(
      primaryIncome: 0,
      secondaryIncome: 0,
      incomeFrequency: 'monthly',
      fixedExpenses: {},
      variableExpenses: {},
      savesMoney: false,
      desiredSavings: 0,
      emergencyFundGoalMonths: 3,
      investsMoney: false,
      preferredInvestments: [],
      riskPreference: 'Medium',
      priorityOrder: ['Saving', 'Investing', 'Spending', 'Debt'],
      lifestyleFlexibility: 'Medium',
    );
  }

  void _persist(BudgetQuestionnaire questionnaire) {
    _box.put('current', questionnaire);
    state = questionnaire;
  }

  void updateIncome({double? primary, double? secondary, String? frequency}) {
    _persist(BudgetQuestionnaire(
      primaryIncome: primary ?? state.primaryIncome,
      secondaryIncome: secondary ?? state.secondaryIncome,
      incomeFrequency: frequency ?? state.incomeFrequency,
      fixedExpenses: state.fixedExpenses,
      variableExpenses: state.variableExpenses,
      savesMoney: state.savesMoney,
      desiredSavings: state.desiredSavings,
      emergencyFundGoalMonths: state.emergencyFundGoalMonths,
      investsMoney: state.investsMoney,
      preferredInvestments: state.preferredInvestments,
      riskPreference: state.riskPreference,
      priorityOrder: state.priorityOrder,
      lifestyleFlexibility: state.lifestyleFlexibility,
    ));
  }

  void updateFixedExpenses(Map<String, double> expenses) {
    _persist(BudgetQuestionnaire(
      primaryIncome: state.primaryIncome,
      secondaryIncome: state.secondaryIncome,
      incomeFrequency: state.incomeFrequency,
      fixedExpenses: expenses,
      variableExpenses: state.variableExpenses,
      savesMoney: state.savesMoney,
      desiredSavings: state.desiredSavings,
      emergencyFundGoalMonths: state.emergencyFundGoalMonths,
      investsMoney: state.investsMoney,
      preferredInvestments: state.preferredInvestments,
      riskPreference: state.riskPreference,
      priorityOrder: state.priorityOrder,
      lifestyleFlexibility: state.lifestyleFlexibility,
    ));
  }

  void updateVariableExpenses(Map<String, double> expenses) {
    _persist(BudgetQuestionnaire(
      primaryIncome: state.primaryIncome,
      secondaryIncome: state.secondaryIncome,
      incomeFrequency: state.incomeFrequency,
      fixedExpenses: state.fixedExpenses,
      variableExpenses: expenses,
      savesMoney: state.savesMoney,
      desiredSavings: state.desiredSavings,
      emergencyFundGoalMonths: state.emergencyFundGoalMonths,
      investsMoney: state.investsMoney,
      preferredInvestments: state.preferredInvestments,
      riskPreference: state.riskPreference,
      priorityOrder: state.priorityOrder,
      lifestyleFlexibility: state.lifestyleFlexibility,
    ));
  }

  void updatePreferences({
    bool? saves,
    double? savings,
    int? emergencyMonths,
    bool? invests,
    List<String>? investments,
    String? risk,
    List<String>? priorities,
    String? flexibility,
  }) {
    _persist(BudgetQuestionnaire(
      primaryIncome: state.primaryIncome,
      secondaryIncome: state.secondaryIncome,
      incomeFrequency: state.incomeFrequency,
      fixedExpenses: state.fixedExpenses,
      variableExpenses: state.variableExpenses,
      savesMoney: saves ?? state.savesMoney,
      desiredSavings: savings ?? state.desiredSavings,
      emergencyFundGoalMonths: emergencyMonths ?? state.emergencyFundGoalMonths,
      investsMoney: invests ?? state.investsMoney,
      preferredInvestments: investments ?? state.preferredInvestments,
      riskPreference: risk ?? state.riskPreference,
      priorityOrder: priorities ?? state.priorityOrder,
      lifestyleFlexibility: flexibility ?? state.lifestyleFlexibility,
    ));
  }
}

@riverpod
double effectiveIncome(EffectiveIncomeRef ref) {
  final questionnaire = ref.watch(budgetQuestionnaireStateProvider);
  final actualIncomeAsync = ref.watch(currentMonthIncomeProvider);
  
  return actualIncomeAsync.maybeWhen(
    data: (actualIncome) => max(questionnaire.totalIncome, actualIncome),
    orElse: () => questionnaire.totalIncome,
  );
}

@riverpod
List<BudgetPlan> generatedBudgetPlans(GeneratedBudgetPlansRef ref) {
  final questionnaire = ref.watch(budgetQuestionnaireStateProvider);
  final totalEffectiveIncome = ref.watch(effectiveIncomeProvider);
  
  final adaptiveInput = BudgetQuestionnaire(
    primaryIncome: totalEffectiveIncome,
    secondaryIncome: 0,
    incomeFrequency: questionnaire.incomeFrequency,
    fixedExpenses: questionnaire.fixedExpenses,
    variableExpenses: questionnaire.variableExpenses,
    savesMoney: questionnaire.savesMoney,
    desiredSavings: questionnaire.desiredSavings,
    emergencyFundGoalMonths: questionnaire.emergencyFundGoalMonths,
    investsMoney: questionnaire.investsMoney,
    preferredInvestments: questionnaire.preferredInvestments,
    riskPreference: questionnaire.riskPreference,
    priorityOrder: questionnaire.priorityOrder,
    lifestyleFlexibility: questionnaire.lifestyleFlexibility,
  );

  return BudgetEngine.generatePlans(adaptiveInput);
}

@riverpod
void autoSyncCategories(AutoSyncCategoriesRef ref) {
  final activePlan = ref.watch(activeBudgetPlanProvider);
  if (activePlan == null) return;
  
  final questionnaire = ref.read(budgetQuestionnaireStateProvider);
  
  ref.listen(activeBudgetPlanProvider, (previous, next) async {
    if (next == null) return;
    
    // Simple equality check to avoid redundant updates
    if (previous != null && _mapEquals(previous.allocations, next.allocations)) {
      return;
    }

    final categories = await ref.read(categoriesListProvider.future);
    final updatedCategories = BudgetSyncService.calculateUpdatedLimits(
      plan: next,
      questionnaire: questionnaire,
      categories: categories,
    );
    
    final notifier = ref.read(categoriesListProvider.notifier);
    for (var cat in updatedCategories) {
       // Only update if the limit actually changed
       final current = categories.firstWhere((c) => c.id == cat.id);
       if (current.budgetLimit != cat.budgetLimit) {
         await notifier.updateCategory(cat);
       }
    }
  }, fireImmediately: true);
}

bool _mapEquals(Map<String, double> a, Map<String, double> b) {
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (b[key] != a[key]) return false;
  }
  return true;
}

@riverpod
class ActiveBudgetPlan extends _$ActiveBudgetPlan {
  Box<BudgetPlan> get _box => Hive.box<BudgetPlan>('active_budget_plan');

  @override
  BudgetPlan? build() {
    final active = _box.get('current');
    if (active == null) return null;

    // Accuracy Check: Ensure the active plan reflects the LATEST generated allocations
    // This handles cases where user changed income/EMIs in the questionnaire
    final generatedPlans = ref.watch(generatedBudgetPlansProvider);
    if (generatedPlans.isEmpty) return active;

    // Find the plan with the same ID in current generation
    try {
      final latestMatch = generatedPlans.firstWhere((p) => p.id == active.id);
      
      // If allocations changed (due to engine update or input change), update the state
      // but only if there's a significant difference to avoid infinite loops
      // Actually, Riverpod handles equality for us if we return the new object.
      return latestMatch;
    } catch (_) {
      // If the old active plan ID no longer exists, stick with stored (or could clear)
      return active;
    }
  }

  void selectPlan(BudgetPlan plan) {
    _box.put('current', plan);
    state = plan;
  }

  void clearPlan() {
    _box.delete('current');
    state = null;
  }
}
