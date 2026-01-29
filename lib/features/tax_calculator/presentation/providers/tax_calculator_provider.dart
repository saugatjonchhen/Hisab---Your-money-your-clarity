import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/tax_calculator_models.dart';
import '../../domain/services/tax_calculation_service.dart';
import '../../data/repositories/tax_config_repository.dart';

final taxConfigRepositoryProvider = Provider((ref) => TaxConfigRepository());

final taxConfigurationsProvider = AsyncNotifierProvider<TaxConfigurationsNotifier, List<TaxConfiguration>>(() {
  return TaxConfigurationsNotifier();
});

class TaxConfigurationsNotifier extends AsyncNotifier<List<TaxConfiguration>> {
  @override
  Future<List<TaxConfiguration>> build() async {
    return ref.read(taxConfigRepositoryProvider).getAllConfigs();
  }

  Future<void> addConfig(TaxConfiguration config) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(taxConfigRepositoryProvider).saveConfig(config);
      return ref.read(taxConfigRepositoryProvider).getAllConfigs();
    });
  }

  Future<void> deleteConfig(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(taxConfigRepositoryProvider).deleteConfig(id);
      return ref.read(taxConfigRepositoryProvider).getAllConfigs();
    });
  }
}

final selectedTaxConfigIdProvider = StateProvider<String>((ref) {
  return 'nepal_fy_2081_82';
});

final selectedTaxConfigProvider = Provider<TaxConfiguration?>((ref) {
  final configsAsync = ref.watch(taxConfigurationsProvider);
  final selectedId = ref.watch(selectedTaxConfigIdProvider);
  
  return configsAsync.when(
    data: (configs) => configs.firstWhere((c) => c.id == selectedId, orElse: () => configs.first),
    loading: () => null,
    error: (_, __) => null,
  );
});

final taxInputsProvider = StateNotifierProvider<TaxInputsNotifier, TaxInputs>((ref) {
  return TaxInputsNotifier();
});

class TaxInputsNotifier extends StateNotifier<TaxInputs> {
  TaxInputsNotifier() : super(TaxInputs());

  void updateGrossSalary(double value) => state = state.copyWith(monthlyGrossSalary: value);
  void updateBasicSalary(double value) => state = state.copyWith(monthlyBasicSalary: value);
  void updateMaritalStatus(bool isMarried) => state = state.copyWith(isMarried: isMarried);
  void updateSSFStatus(bool isEnrolled) => state = state.copyWith(isEnrolledInSSF: isEnrolled);
  void updateFemaleRebate(bool hasRebate) => state = state.copyWith(hasFemaleTaxRebate: hasRebate);
  void updateCIT(double value) => state = state.copyWith(monthlyCITContribution: value);
  void updateSSF(double value) => state = state.copyWith(monthlySSFContribution: value);
  void updateLifeInsurance(double value) => state = state.copyWith(annualLifeInsurance: value);
  void updateHealthInsurance(double value) => state = state.copyWith(annualHealthInsurance: value);
  void updateIncentives(double value) => state = state.copyWith(annualIncentives: value);
  
  void reset() => state = TaxInputs();
}

final taxResultProvider = Provider<TaxCalculationResult?>((ref) {
  final inputs = ref.watch(taxInputsProvider);
  final config = ref.watch(selectedTaxConfigProvider);
  
  if (config == null) return null;
  
  return TaxCalculationService.calculate(inputs, config);
});
