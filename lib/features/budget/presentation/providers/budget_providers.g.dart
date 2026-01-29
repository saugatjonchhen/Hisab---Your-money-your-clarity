// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$effectiveIncomeHash() => r'ac483ddf097456f3e35fc15f5dee2bbf9a18f792';

/// See also [effectiveIncome].
@ProviderFor(effectiveIncome)
final effectiveIncomeProvider = AutoDisposeProvider<double>.internal(
  effectiveIncome,
  name: r'effectiveIncomeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$effectiveIncomeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EffectiveIncomeRef = AutoDisposeProviderRef<double>;
String _$generatedBudgetPlansHash() =>
    r'74f3cb8a20b226c35531b6b11fec4c9b3b8e235d';

/// See also [generatedBudgetPlans].
@ProviderFor(generatedBudgetPlans)
final generatedBudgetPlansProvider =
    AutoDisposeProvider<List<BudgetPlan>>.internal(
  generatedBudgetPlans,
  name: r'generatedBudgetPlansProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$generatedBudgetPlansHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GeneratedBudgetPlansRef = AutoDisposeProviderRef<List<BudgetPlan>>;
String _$autoSyncCategoriesHash() =>
    r'daef14c9879eb99119667fb8bf243b4c60faf2f2';

/// See also [autoSyncCategories].
@ProviderFor(autoSyncCategories)
final autoSyncCategoriesProvider = AutoDisposeProvider<void>.internal(
  autoSyncCategories,
  name: r'autoSyncCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$autoSyncCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AutoSyncCategoriesRef = AutoDisposeProviderRef<void>;
String _$budgetQuestionnaireStateHash() =>
    r'199137316788d1fa9d5ce23f5cd0c630b7012aec';

/// See also [BudgetQuestionnaireState].
@ProviderFor(BudgetQuestionnaireState)
final budgetQuestionnaireStateProvider = AutoDisposeNotifierProvider<
    BudgetQuestionnaireState, BudgetQuestionnaire>.internal(
  BudgetQuestionnaireState.new,
  name: r'budgetQuestionnaireStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetQuestionnaireStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BudgetQuestionnaireState = AutoDisposeNotifier<BudgetQuestionnaire>;
String _$activeBudgetPlanHash() => r'31be33e0339c606691f9ad8d732a4c7f4cb8cd37';

/// See also [ActiveBudgetPlan].
@ProviderFor(ActiveBudgetPlan)
final activeBudgetPlanProvider =
    AutoDisposeNotifierProvider<ActiveBudgetPlan, BudgetPlan?>.internal(
  ActiveBudgetPlan.new,
  name: r'activeBudgetPlanProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeBudgetPlanHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveBudgetPlan = AutoDisposeNotifier<BudgetPlan?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
