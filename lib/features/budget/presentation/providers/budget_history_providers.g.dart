// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_history_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$budgetHistoryHash() => r'0414ed280a4193db8140c98c9302d3e91012e27b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Get budget history snapshots
///
/// Copied from [budgetHistory].
@ProviderFor(budgetHistory)
const budgetHistoryProvider = BudgetHistoryFamily();

/// Get budget history snapshots
///
/// Copied from [budgetHistory].
class BudgetHistoryFamily
    extends Family<AsyncValue<List<BudgetMonthSnapshot>>> {
  /// Get budget history snapshots
  ///
  /// Copied from [budgetHistory].
  const BudgetHistoryFamily();

  /// Get budget history snapshots
  ///
  /// Copied from [budgetHistory].
  BudgetHistoryProvider call({
    int months = 6,
  }) {
    return BudgetHistoryProvider(
      months: months,
    );
  }

  @override
  BudgetHistoryProvider getProviderOverride(
    covariant BudgetHistoryProvider provider,
  ) {
    return call(
      months: provider.months,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'budgetHistoryProvider';
}

/// Get budget history snapshots
///
/// Copied from [budgetHistory].
class BudgetHistoryProvider
    extends AutoDisposeFutureProvider<List<BudgetMonthSnapshot>> {
  /// Get budget history snapshots
  ///
  /// Copied from [budgetHistory].
  BudgetHistoryProvider({
    int months = 6,
  }) : this._internal(
          (ref) => budgetHistory(
            ref as BudgetHistoryRef,
            months: months,
          ),
          from: budgetHistoryProvider,
          name: r'budgetHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$budgetHistoryHash,
          dependencies: BudgetHistoryFamily._dependencies,
          allTransitiveDependencies:
              BudgetHistoryFamily._allTransitiveDependencies,
          months: months,
        );

  BudgetHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.months,
  }) : super.internal();

  final int months;

  @override
  Override overrideWith(
    FutureOr<List<BudgetMonthSnapshot>> Function(BudgetHistoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BudgetHistoryProvider._internal(
        (ref) => create(ref as BudgetHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        months: months,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<BudgetMonthSnapshot>> createElement() {
    return _BudgetHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetHistoryProvider && other.months == months;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, months.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BudgetHistoryRef
    on AutoDisposeFutureProviderRef<List<BudgetMonthSnapshot>> {
  /// The parameter `months` of this provider.
  int get months;
}

class _BudgetHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<BudgetMonthSnapshot>>
    with BudgetHistoryRef {
  _BudgetHistoryProviderElement(super.provider);

  @override
  int get months => (origin as BudgetHistoryProvider).months;
}

String _$yearlyBudgetSummaryHash() =>
    r'c34e3b67a9e46ba2dcf9b39c3589b3025e6c2b03';

/// Get yearly budget summary
///
/// Copied from [yearlyBudgetSummary].
@ProviderFor(yearlyBudgetSummary)
const yearlyBudgetSummaryProvider = YearlyBudgetSummaryFamily();

/// Get yearly budget summary
///
/// Copied from [yearlyBudgetSummary].
class YearlyBudgetSummaryFamily
    extends Family<AsyncValue<Map<String, double>>> {
  /// Get yearly budget summary
  ///
  /// Copied from [yearlyBudgetSummary].
  const YearlyBudgetSummaryFamily();

  /// Get yearly budget summary
  ///
  /// Copied from [yearlyBudgetSummary].
  YearlyBudgetSummaryProvider call(
    int year,
  ) {
    return YearlyBudgetSummaryProvider(
      year,
    );
  }

  @override
  YearlyBudgetSummaryProvider getProviderOverride(
    covariant YearlyBudgetSummaryProvider provider,
  ) {
    return call(
      provider.year,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'yearlyBudgetSummaryProvider';
}

/// Get yearly budget summary
///
/// Copied from [yearlyBudgetSummary].
class YearlyBudgetSummaryProvider
    extends AutoDisposeFutureProvider<Map<String, double>> {
  /// Get yearly budget summary
  ///
  /// Copied from [yearlyBudgetSummary].
  YearlyBudgetSummaryProvider(
    int year,
  ) : this._internal(
          (ref) => yearlyBudgetSummary(
            ref as YearlyBudgetSummaryRef,
            year,
          ),
          from: yearlyBudgetSummaryProvider,
          name: r'yearlyBudgetSummaryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$yearlyBudgetSummaryHash,
          dependencies: YearlyBudgetSummaryFamily._dependencies,
          allTransitiveDependencies:
              YearlyBudgetSummaryFamily._allTransitiveDependencies,
          year: year,
        );

  YearlyBudgetSummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.year,
  }) : super.internal();

  final int year;

  @override
  Override overrideWith(
    FutureOr<Map<String, double>> Function(YearlyBudgetSummaryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: YearlyBudgetSummaryProvider._internal(
        (ref) => create(ref as YearlyBudgetSummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        year: year,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, double>> createElement() {
    return _YearlyBudgetSummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is YearlyBudgetSummaryProvider && other.year == year;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin YearlyBudgetSummaryRef
    on AutoDisposeFutureProviderRef<Map<String, double>> {
  /// The parameter `year` of this provider.
  int get year;
}

class _YearlyBudgetSummaryProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, double>>
    with YearlyBudgetSummaryRef {
  _YearlyBudgetSummaryProviderElement(super.provider);

  @override
  int get year => (origin as YearlyBudgetSummaryProvider).year;
}

String _$currentBudgetPeriodHash() =>
    r'2a8305ed09ea48143601dd9d71e9fa8615ad3c81';

/// Get current budget period based on settings
///
/// Copied from [currentBudgetPeriod].
@ProviderFor(currentBudgetPeriod)
final currentBudgetPeriodProvider =
    AutoDisposeFutureProvider<BudgetPeriod>.internal(
  currentBudgetPeriod,
  name: r'currentBudgetPeriodProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentBudgetPeriodHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentBudgetPeriodRef = AutoDisposeFutureProviderRef<BudgetPeriod>;
String _$budgetSnapshotGeneratorHash() =>
    r'e3d10a065ff39cd2f21f86c4cc8398b2b765d3c9';

/// Snapshot generator - creates monthly snapshots automatically
///
/// Copied from [BudgetSnapshotGenerator].
@ProviderFor(BudgetSnapshotGenerator)
final budgetSnapshotGeneratorProvider =
    AutoDisposeAsyncNotifierProvider<BudgetSnapshotGenerator, void>.internal(
  BudgetSnapshotGenerator.new,
  name: r'budgetSnapshotGeneratorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$budgetSnapshotGeneratorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BudgetSnapshotGenerator = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
