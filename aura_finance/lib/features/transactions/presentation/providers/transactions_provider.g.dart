// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Transactions)
final transactionsProvider = TransactionsProvider._();

final class TransactionsProvider
    extends $NotifierProvider<Transactions, List<Transaction>> {
  TransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionsHash();

  @$internal
  @override
  Transactions create() => Transactions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Transaction> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Transaction>>(value),
    );
  }
}

String _$transactionsHash() => r'6ad37f798f534de43c8ff0a6b52b8ab2f6efffb9';

abstract class _$Transactions extends $Notifier<List<Transaction>> {
  List<Transaction> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Transaction>, List<Transaction>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Transaction>, List<Transaction>>,
              List<Transaction>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
