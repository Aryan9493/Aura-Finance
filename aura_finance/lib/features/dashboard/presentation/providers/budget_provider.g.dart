// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BudgetLimit)
final budgetLimitProvider = BudgetLimitProvider._();

final class BudgetLimitProvider extends $NotifierProvider<BudgetLimit, double> {
  BudgetLimitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetLimitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetLimitHash();

  @$internal
  @override
  BudgetLimit create() => BudgetLimit();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$budgetLimitHash() => r'019913dd19c11b96ce73cd5efbdf66182a81a89c';

abstract class _$BudgetLimit extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
