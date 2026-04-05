// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InsightsTimeframeNotifier)
final insightsTimeframeProvider = InsightsTimeframeNotifierProvider._();

final class InsightsTimeframeNotifierProvider
    extends $NotifierProvider<InsightsTimeframeNotifier, InsightsTimeframe> {
  InsightsTimeframeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'insightsTimeframeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$insightsTimeframeNotifierHash();

  @$internal
  @override
  InsightsTimeframeNotifier create() => InsightsTimeframeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InsightsTimeframe value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InsightsTimeframe>(value),
    );
  }
}

String _$insightsTimeframeNotifierHash() =>
    r'a37f60ccbf2dda6de0aebad363fafee5bce69c96';

abstract class _$InsightsTimeframeNotifier
    extends $Notifier<InsightsTimeframe> {
  InsightsTimeframe build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<InsightsTimeframe, InsightsTimeframe>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InsightsTimeframe, InsightsTimeframe>,
              InsightsTimeframe,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
