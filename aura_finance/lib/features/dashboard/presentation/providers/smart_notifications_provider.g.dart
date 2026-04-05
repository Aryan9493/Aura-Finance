// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SmartNotifications)
final smartNotificationsProvider = SmartNotificationsProvider._();

final class SmartNotificationsProvider
    extends $NotifierProvider<SmartNotifications, List<SmartNotification>> {
  SmartNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'smartNotificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$smartNotificationsHash();

  @$internal
  @override
  SmartNotifications create() => SmartNotifications();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SmartNotification> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SmartNotification>>(value),
    );
  }
}

String _$smartNotificationsHash() =>
    r'0596ec755fbd2f3f8a19ca26f21394ce4866b337';

abstract class _$SmartNotifications extends $Notifier<List<SmartNotification>> {
  List<SmartNotification> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<List<SmartNotification>, List<SmartNotification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SmartNotification>, List<SmartNotification>>,
              List<SmartNotification>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
