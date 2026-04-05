import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'insights_provider.g.dart';

enum InsightsTimeframe { weekly, monthly }

@riverpod
class InsightsTimeframeNotifier extends _$InsightsTimeframeNotifier {
  @override
  InsightsTimeframe build() {
    return InsightsTimeframe.weekly;
  }

  void setTimeframe(InsightsTimeframe timeframe) {
    state = timeframe;
  }
}
