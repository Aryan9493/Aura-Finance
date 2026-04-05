// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuraAssistant)
final auraAssistantProvider = AuraAssistantProvider._();

final class AuraAssistantProvider
    extends $NotifierProvider<AuraAssistant, AssistantMessage?> {
  AuraAssistantProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auraAssistantProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auraAssistantHash();

  @$internal
  @override
  AuraAssistant create() => AuraAssistant();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssistantMessage? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssistantMessage?>(value),
    );
  }
}

String _$auraAssistantHash() => r'26e67c650784fdb7543b03d8420615e33da2a5d0';

abstract class _$AuraAssistant extends $Notifier<AssistantMessage?> {
  AssistantMessage? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AssistantMessage?, AssistantMessage?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AssistantMessage?, AssistantMessage?>,
              AssistantMessage?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
