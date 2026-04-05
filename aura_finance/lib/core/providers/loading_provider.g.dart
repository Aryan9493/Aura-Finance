// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loading_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppLoading)
final appLoadingProvider = AppLoadingProvider._();

final class AppLoadingProvider extends $NotifierProvider<AppLoading, bool> {
  AppLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLoadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLoadingHash();

  @$internal
  @override
  AppLoading create() => AppLoading();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$appLoadingHash() => r'5496bdbae730b718a1a2a14b22afca5b19eaf94c';

abstract class _$AppLoading extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
