import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aura_finance/core/widgets/custom_card.dart';
import 'package:aura_finance/core/services/haptic_service.dart';
import 'package:aura_finance/features/dashboard/presentation/providers/budget_provider.dart';
import 'package:aura_finance/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:aura_finance/features/transactions/domain/entities/transaction.dart';
import 'package:aura_finance/features/dashboard/presentation/providers/smart_notifications_provider.dart';

class NotificationEngine extends ConsumerWidget {
  const NotificationEngine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final budgetLimit = ref.watch(budgetLimitProvider);
    final notifications = ref.watch(smartNotificationsProvider);
    
    // Logic: Trigger behavioral notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      
      // 1. Daily over average check
      final todaySpend = transactions
          .where((t) => t.type == TransactionType.expense && t.date.day == now.day && t.date.month == now.month)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      final totalExpenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      final daysWithData = transactions.map((t) => DateTime(t.date.year, t.date.month, t.date.day)).toSet().length;
      final avgDaily = daysWithData > 0 ? totalExpenses / daysWithData : 0.0;

      if (todaySpend > avgDaily * 1.5 && todaySpend > 50) {
        ref.read(smartNotificationsProvider.notifier).addNotification(SmartNotification(
          id: 'spend_avg',
          title: 'High Spending',
          message: "You're spending more than usual today.",
          icon: Icons.trending_up_rounded,
          color: const Color(0xFFFF5E5E),
          timestamp: DateTime.now(),
        ));
      }

      // 2. Budget limit check (80%)
      final currentMonthExpenses = transactions
          .where((t) => t.type == TransactionType.expense && t.date.month == now.month && t.date.year == now.year)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      if (currentMonthExpenses >= budgetLimit * 0.8) {
        ref.read(smartNotificationsProvider.notifier).addNotification(SmartNotification(
          id: 'budget_80',
          title: 'Budget Alert',
          message: "You've used ${((currentMonthExpenses / budgetLimit) * 100).toInt()}% of your budget.",
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFFFFB74D),
          timestamp: DateTime.now(),
        ));
      }

      // 3. Streak encouragement
      ref.read(smartNotificationsProvider.notifier).addNotification(SmartNotification(
        id: 'streak_push',
        title: 'Keep it up!',
        message: "You're on a 5-day streak! Don't stop now.",
        icon: Icons.bolt_rounded,
        color: const Color(0xFF10E294),
        timestamp: DateTime.now(),
      ));
    });

    if (notifications.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final n in notifications)
          _SmartNotificationBanner(notification: n),
      ],
    );
  }
}

class _SmartNotificationBanner extends ConsumerWidget {
  final SmartNotification notification;
  const _SmartNotificationBanner({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomCard(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: notification.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(notification.icon, color: notification.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                  Text(notification.message, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                HapticService.light();
                ref.read(smartNotificationsProvider.notifier).dismissNotification(notification.id);
              },
              icon: const Icon(Icons.close_rounded, size: 18),
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ],
        ),
      ).animate().slideY(begin: -0.5, end: 0, duration: 400.ms, curve: Curves.easeOutCubic).fadeIn(duration: 400.ms),
    );
  }
}
