import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loading_provider.g.dart';

@riverpod
class AppLoading extends _$AppLoading {
  @override
  bool build() {
    // Initial loading state
    _simulateLoading();
    return true;
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    state = false;
  }

  void startLoading() {
    state = true;
    _simulateLoading();
  }
}
