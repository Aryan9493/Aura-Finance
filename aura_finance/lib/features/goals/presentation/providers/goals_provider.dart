import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/goal.dart';

part 'goals_provider.g.dart';

@riverpod
class GoalsNotifier extends _$GoalsNotifier {
  @override
  List<Goal> build() {
    return [
      Goal(
        id: '1',
        title: 'Goa Trip 🌴',
        targetAmount: 50000,
        currentAmount: 32500,
        deadline: DateTime.now().add(const Duration(days: 90)),
      ),
      Goal(
        id: '2',
        title: 'New iPhone 📱',
        targetAmount: 140000,
        currentAmount: 91000,
        deadline: DateTime.now().add(const Duration(days: 180)),
      ),
    ];
  }

  void addGoal(Goal goal) {
    state = [...state, goal];
  }

  void updateGoal(Goal updatedGoal) {
    state = [
      for (final goal in state)
        if (goal.id == updatedGoal.id) updatedGoal else goal,
    ];
  }

  void removeGoal(String id) {
    state = state.where((g) => g.id != id).toList();
  }

  void addProgress(String id, double amount) {
    state = [
      for (final goal in state)
        if (goal.id == id)
          goal.copyWith(currentAmount: (goal.currentAmount + amount).clamp(0.0, goal.targetAmount))
        else
          goal,
    ];
  }
}
