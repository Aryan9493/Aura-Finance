import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_finance/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:aura_finance/features/dashboard/presentation/providers/budget_provider.dart';
import 'package:aura_finance/features/transactions/domain/entities/transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assistant_provider.g.dart';

class AssistantMessage {
  final String text;
  final IconData icon;
  final Color color;

  AssistantMessage({required this.text, required this.icon, required this.color});
}

@riverpod
class AuraAssistant extends _$AuraAssistant {
  @override
  AssistantMessage? build() {
    return _generateMessage();
  }

  AssistantMessage? _generateMessage() {
    final transactions = ref.read(transactionsProvider);
    final budgetLimit = ref.read(budgetLimitProvider);
    final now = DateTime.now();

    // 1. Budget Near Limit (80%)
    final currentMonthExpenses = transactions
        .where((t) => t.type == TransactionType.expense && t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    if (currentMonthExpenses >= budgetLimit * 0.8) {
      return AssistantMessage(
        text: "You're at ${((currentMonthExpenses / budgetLimit) * 100).toInt()}% of your budget. Let's slow down!",
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFFFB74D),
      );
    }

    // 2. High Regret Spending
    final regretTransactions = transactions.where((t) => t.mood == '😤' || t.mood == 'Regret').length;
    if (regretTransactions > 3) {
      return AssistantMessage(
        text: "You regret $regretTransactions recent purchases. Try pausing before your next buy!",
        icon: Icons.psychology_outlined,
        color: const Color(0xFFFF5E5E),
      );
    }

    // 3. High Spending Streak
    final todaySpend = transactions
        .where((t) => t.type == TransactionType.expense && t.date.day == now.day && t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
    if (todaySpend > 100) {
      return AssistantMessage(
        text: "Daily spending is a bit high today (\$$todaySpend). Any essentials?",
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF6C63FF),
      );
    }

    // 4. Default Encouragement
    return AssistantMessage(
      text: "Great job! Your financial health looks stable today. Keep it up!",
      icon: Icons.auto_awesome_rounded,
      color: const Color(0xFF10E294),
    );
  }

  void refresh() {
    state = _generateMessage();
  }

  void dismiss() {
    state = null;
  }
}
