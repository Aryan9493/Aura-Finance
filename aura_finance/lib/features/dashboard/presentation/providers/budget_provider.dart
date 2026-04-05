import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_provider.g.dart';

@riverpod
class BudgetLimit extends _$BudgetLimit {
  @override
  double build() {
    // Default monthly budget limit
    return 1000.0;
  }

  void setLimit(double limit) {
    state = limit;
  }
}
