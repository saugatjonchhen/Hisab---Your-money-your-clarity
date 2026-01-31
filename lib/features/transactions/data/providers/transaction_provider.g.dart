// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionRepositoryHash() =>
    r'c2847b825170bbc3b692461530c126430d879de0';

/// See also [transactionRepository].
@ProviderFor(transactionRepository)
final transactionRepositoryProvider =
    AutoDisposeProvider<TransactionRepository>.internal(
  transactionRepository,
  name: r'transactionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TransactionRepositoryRef
    = AutoDisposeProviderRef<TransactionRepository>;
String _$totalBalanceHash() => r'dff0056fac3b95be3c34fe938f8eb354e8bae4b6';

/// See also [totalBalance].
@ProviderFor(totalBalance)
final totalBalanceProvider = AutoDisposeFutureProvider<double>.internal(
  totalBalance,
  name: r'totalBalanceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalBalanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalBalanceRef = AutoDisposeFutureProviderRef<double>;
String _$totalWealthHash() => r'78ec161cbe323428ebfc5316c468687dbf2a9c8c';

/// See also [totalWealth].
@ProviderFor(totalWealth)
final totalWealthProvider = AutoDisposeFutureProvider<double>.internal(
  totalWealth,
  name: r'totalWealthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalWealthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalWealthRef = AutoDisposeFutureProviderRef<double>;
String _$totalSavingsHash() => r'596546d394a5a5342ca5a0ba6fc6e09f7edc7ce9';

/// See also [totalSavings].
@ProviderFor(totalSavings)
final totalSavingsProvider = AutoDisposeFutureProvider<double>.internal(
  totalSavings,
  name: r'totalSavingsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalSavingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalSavingsRef = AutoDisposeFutureProviderRef<double>;
String _$totalInvestmentHash() => r'392d1825af0dcb8725a5019e7da1f1589dbd496a';

/// See also [totalInvestment].
@ProviderFor(totalInvestment)
final totalInvestmentProvider = AutoDisposeFutureProvider<double>.internal(
  totalInvestment,
  name: r'totalInvestmentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalInvestmentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalInvestmentRef = AutoDisposeFutureProviderRef<double>;
String _$totalIncomeHash() => r'1ea9fff2b43569a31d51e12ed6a080283bde7ee1';

/// See also [totalIncome].
@ProviderFor(totalIncome)
final totalIncomeProvider = AutoDisposeFutureProvider<double>.internal(
  totalIncome,
  name: r'totalIncomeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalIncomeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalIncomeRef = AutoDisposeFutureProviderRef<double>;
String _$currentMonthIncomeHash() =>
    r'de13627017bb09d17d7e39acd8cd57e810045530';

/// See also [currentMonthIncome].
@ProviderFor(currentMonthIncome)
final currentMonthIncomeProvider = AutoDisposeFutureProvider<double>.internal(
  currentMonthIncome,
  name: r'currentMonthIncomeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentMonthIncomeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentMonthIncomeRef = AutoDisposeFutureProviderRef<double>;
String _$totalExpenseHash() => r'9bd0f82dac2762daab63d3292ab7aa427e97f6d2';

/// See also [totalExpense].
@ProviderFor(totalExpense)
final totalExpenseProvider = AutoDisposeFutureProvider<double>.internal(
  totalExpense,
  name: r'totalExpenseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalExpenseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalExpenseRef = AutoDisposeFutureProviderRef<double>;
String _$transactionsListHash() => r'3b42ec4815c7412a4e9d2cd69acbe0b895cb7d11';

/// See also [TransactionsList].
@ProviderFor(TransactionsList)
final transactionsListProvider = AutoDisposeAsyncNotifierProvider<
    TransactionsList, List<TransactionModel>>.internal(
  TransactionsList.new,
  name: r'transactionsListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionsList = AutoDisposeAsyncNotifier<List<TransactionModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
