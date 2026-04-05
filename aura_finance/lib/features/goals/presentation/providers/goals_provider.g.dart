// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GoalsNotifier)
final goalsProvider = GoalsNotifierProvider._();

final class GoalsNotifierProvider
    extends $NotifierProvider<GoalsNotifier, List<Goal>> {
  GoalsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsNotifierHash();

  @$internal
  @override
  GoalsNotifier create() => GoalsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Goal> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Goal>>(value),
    );
  }
}

String _$goalsNotifierHash() => r'075d8fb833bf363ffe132930ddee4af8ec592923';

abstract class _$GoalsNotifier extends $Notifier<List<Goal>> {
  List<Goal> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Goal>, List<Goal>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Goal>, List<Goal>>,
              List<Goal>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
