import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/services/haptic_service.dart';
import 'package:aura_finance/features/dashboard/presentation/providers/budget_provider.dart';
import 'package:aura_finance/features/dashboard/presentation/widgets/notification_engine.dart';
import 'package:aura_finance/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:aura_finance/features/transactions/domain/entities/transaction.dart';
import 'package:aura_finance/features/dashboard/presentation/providers/assistant_provider.dart';
import 'package:aura_finance/core/widgets/skeleton_loader.dart';
import 'package:aura_finance/core/providers/loading_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: -1,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          _buildStreakBadge(isDark),
          const SizedBox(width: 12),
          _buildNotificationButton(isDark),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          _buildBackground(isDark, screenWidth),
          SafeArea(
            bottom: false,
            child: AnimationLimiter(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
                child: Consumer(
                  builder: (context, ref, child) {
                    final isLoading = ref.watch(appLoadingProvider);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isLoading)
                          const _DashboardSkeleton()
                        else
                          ...AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(child: widget),
                            ),
                            children: [
                              const NotificationEngine(),
                              const _BalanceCard(),
                              const SizedBox(height: 24),
                              const _AuraAssistantCard(),
                              const SizedBox(height: 24),
                              
                              _StreakMilestoneCard(
                                onTap: () {
                                  HapticService.success();
                                  _confettiController.play();
                                },
                              ),
                              const SizedBox(height: 32),

                              const _BudgetCard(),
                              const SizedBox(height: 24),

                              const SectionHeader(title: 'Spending Velocity'),
                              const SizedBox(height: 16),
                              _WeeklySpendingChart(isDark: isDark),
                              const SizedBox(height: 32),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const SectionHeader(title: 'Asset Allocation'),
                                  GestureDetector(
                                    onTap: () {
                                      HapticService.medium();
                                      context.goNamed('insights');
                                    },
                                    child: AnimatedScale(
                                      scale: 1.0,
                                      duration: const Duration(milliseconds: 100),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'View All',
                                          style: TextStyle(
                                            color: Color(0xFF6C63FF),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _ExpenseAllocationChart(isDark: isDark),
                              const SizedBox(height: 32),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticService.medium();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No new notifications 🔔'),
            backgroundColor: const Color(0xFF6C63FF),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 22,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                Positioned(
                  top: 10,
                  right: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5E5E),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 2.seconds, curve: Curves.easeInOut);
  }

  Widget _buildStreakBadge(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticService.light();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFCC33).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFCC33).withValues(alpha: 0.4), width: 1.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔥', style: TextStyle(fontSize: 16)),
            SizedBox(width: 6),
            Text(
              '5 DAYS',
              style: TextStyle(color: Color(0xFFFFCC33), fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .shimmer(duration: 2.seconds, color: Colors.white24)
     .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 1.seconds, curve: Curves.easeInOut);
  }

  Widget _buildBackground(bool isDark, double screenWidth) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF0D0B1A), const Color(0xFF1A1438)]
                  : [const Color(0xFFF8F9FD), const Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -200,
          left: -150,
          child: Container(
            width: screenWidth * 1.5,
            height: screenWidth * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF6C63FF).withValues(alpha: 0.1) : const Color(0xFF6C63FF).withValues(alpha: 0.04),
            ),
          ),
        ),
        BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
      ],
    );
  }
}

class _StreakMilestoneCard extends StatelessWidget {
  final VoidCallback onTap;
  const _StreakMilestoneCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00C9A7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16)
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF00C9A7), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Level Up: Gold Saver!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 4),
                  Text(
                    'You\'re doing amazing. Tap for a surprise!',
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.black45, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Icon(Icons.celebration_rounded, color: const Color(0xFF6C63FF).withValues(alpha: 0.8), size: 28),
          ],
        ),
      ).animate().shake(delay: 2.seconds, duration: 800.ms),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available Balance', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const Icon(Icons.wallet_rounded, color: Colors.white, size: 26),
            ],
          ),
          const SizedBox(height: 12),
          const _CountUpText(
            endValue: 24560.50,
            style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1.5),
          ),
          const SizedBox(height: 36),
          Row(
            children: [
              _buildMiniStat('Monthly Income', 4200.00),
              Container(width: 1, height: 35, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
              _buildMiniStat('Monthly Spent', 1240.00),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, double amount) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
          const SizedBox(height: 4),
          Text('\$${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}', 
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        ],
      ),
    );
  }
}

class _CountUpText extends StatelessWidget {
  final double endValue;
  final TextStyle style;
  const _CountUpText({required this.endValue, required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: endValue),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOutExpo,
      builder: (context, value, _) {
        final formatter = NumberFormat('#,##0.00');
        return Text('\$${formatter.format(value)}', style: style);
      },
    );
  }
}

class _WeeklySpendingChart extends StatelessWidget {
  final bool isDark;
  const _WeeklySpendingChart({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 2), FlSpot(1, 4.5), FlSpot(2, 3.8), FlSpot(3, 7.2), FlSpot(4, 5.5), FlSpot(5, 8.5), FlSpot(6, 6.8)],
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: const Color(0xFF6C63FF),
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true, 
                      gradient: LinearGradient(
                        colors: [const Color(0xFF6C63FF).withValues(alpha: 0.2), const Color(0xFF6C63FF).withValues(alpha: 0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 1000),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) => 
              Text(day, style: TextStyle(color: isDark ? Colors.white24 : Colors.black12, fontSize: 12, fontWeight: FontWeight.w900))
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class _ExpenseAllocationChart extends StatelessWidget {
  final bool isDark;
  const _ExpenseAllocationChart({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderRadius: 28,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 6,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF6C63FF), 
                    value: 45, 
                    radius: 20, 
                    showTitle: false,
                    badgeWidget: _buildBadge('🏠', const Color(0xFF6C63FF)),
                    badgePositionPercentageOffset: 1.4,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF00C9A7), 
                    value: 30, 
                    radius: 20, 
                    showTitle: false,
                    badgeWidget: _buildBadge('🍔', const Color(0xFF00C9A7)),
                    badgePositionPercentageOffset: 1.4,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFFFB74D), 
                    value: 25, 
                    radius: 20, 
                    showTitle: false,
                    badgeWidget: _buildBadge('🍿', const Color(0xFFFFB74D)),
                    badgePositionPercentageOffset: 1.4,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Total Allocation: \$4,200', 
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w700, fontSize: 13)
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10)],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 14)),
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  const _BudgetCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetLimit = ref.watch(budgetLimitProvider);
    final transactions = ref.watch(transactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final now = DateTime.now();
    final currentMonthExpenses = transactions
        .where((t) => t.type == TransactionType.expense && t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);

    final percentUsed = (currentMonthExpenses / budgetLimit).clamp(0.0, 1.1);
    final isExceeded = currentMonthExpenses > budgetLimit;
    final isWarning = currentMonthExpenses >= budgetLimit * 0.8;

    Color progressColor = const Color(0xFF10E294); // Green
    String alertText = "You're under your budget limit";
    
    if (isExceeded) {
      progressColor = const Color(0xFFFF5E5E); // Red
      alertText = "You've exceeded your budget!";
    } else if (isWarning) {
      progressColor = const Color(0xFFFFB74D); // Orange
      alertText = "You're close to your budget limit";
    }

    return CustomCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87)),
              Text('\$${budgetLimit.toInt()}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white38 : Colors.black38)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${currentMonthExpenses.toStringAsFixed(0)} used', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: progressColor)),
              Text('${(percentUsed * 100).toInt()}%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(6)),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                height: 12,
                width: (MediaQuery.of(context).size.width - 88) * (percentUsed > 1.0 ? 1.0 : percentUsed),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [progressColor, progressColor.withValues(alpha: 0.7)]),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: progressColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(isExceeded ? Icons.warning_amber_rounded : (isWarning ? Icons.info_outline_rounded : Icons.check_circle_outline_rounded), size: 16, color: progressColor),
              const SizedBox(width: 8),
              Text(alertText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: progressColor.withValues(alpha: 0.9))),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SkeletonLoader(height: 200, width: double.infinity, borderRadius: 32),
        const SizedBox(height: 24),
        const SkeletonLoader(height: 90, width: double.infinity, borderRadius: 24),
        const SizedBox(height: 32),
        const SkeletonLoader(height: 250, width: double.infinity, borderRadius: 28),
        const SizedBox(height: 32),
        const SkeletonLoader(height: 300, width: double.infinity, borderRadius: 28),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }
}

class _AuraAssistantCard extends ConsumerWidget {
  const _AuraAssistantCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(auraAssistantProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (message == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: message.color.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomCard(
        borderRadius: 28,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: message.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(message.icon, color: message.color, size: 20).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 1.seconds, curve: Curves.easeInOut),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Aura AI Assistant', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1, color: isDark ? Colors.white54 : Colors.black54))),
                IconButton(onPressed: () { HapticService.light(); ref.read(auraAssistantProvider.notifier).refresh(); }, icon: const Icon(Icons.refresh_rounded, size: 18), color: isDark ? Colors.white24 : Colors.black26),
                IconButton(onPressed: () { HapticService.medium(); ref.read(auraAssistantProvider.notifier).dismiss(); }, icon: const Icon(Icons.close_rounded, size: 18), color: isDark ? Colors.white24 : Colors.black26),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                message.text,
                key: ValueKey(message.text),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ).animate(key: ValueKey(message.text)).fadeIn(duration: 400.ms).shimmer(duration: 800.ms, color: Colors.white24).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}
