// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recurringTransactionRepositoryHash() =>
    r'f8c2b4904d86b863ce8641c74b780935231ee5d4';

/// See also [recurringTransactionRepository].
@ProviderFor(recurringTransactionRepository)
final recurringTransactionRepositoryProvider =
    AutoDisposeProvider<RecurringTransactionRepository>.internal(
  recurringTransactionRepository,
  name: r'recurringTransactionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recurringTransactionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecurringTransactionRepositoryRef
    = AutoDisposeProviderRef<RecurringTransactionRepository>;
String _$recurringTransactionServiceHash() =>
    r'9a2313a1b7810b74a51d88f94c85d85b5d87d980';

/// See also [recurringTransactionService].
@ProviderFor(recurringTransactionService)
final recurringTransactionServiceProvider =
    AutoDisposeProvider<RecurringTransactionService>.internal(
  recurringTransactionService,
  name: r'recurringTransactionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recurringTransactionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecurringTransactionServiceRef
    = AutoDisposeProviderRef<RecurringTransactionService>;
String _$recurringTransactionsListHash() =>
    r'b015373f1449c3c71309aa70da869dce292fd102';

/// See also [RecurringTransactionsList].
@ProviderFor(RecurringTransactionsList)
final recurringTransactionsListProvider = AutoDisposeAsyncNotifierProvider<
    RecurringTransactionsList, List<RecurringTransactionModel>>.internal(
  RecurringTransactionsList.new,
  name: r'recurringTransactionsListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recurringTransactionsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecurringTransactionsList
    = AutoDisposeAsyncNotifier<List<RecurringTransactionModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
