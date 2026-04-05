import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/section_header.dart';
import 'package:aura_finance/features/insights/presentation/providers/insights_provider.dart';
import 'package:aura_finance/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:aura_finance/features/transactions/domain/entities/transaction.dart';
import 'package:aura_finance/core/services/haptic_service.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final timeframe = ref.watch(insightsTimeframeProvider);
    final isWeekly = timeframe == InsightsTimeframe.weekly;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Insights',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(isDark, screenWidth),
          SafeArea(
            bottom: false,
            child: AnimationLimiter(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _buildToggle(ref, timeframe, isDark),
                      const SizedBox(height: 32),
                      
                      const SectionHeader(title: 'Overview'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              label: isWeekly ? 'Total Spent' : 'Monthly Usage',
                              amount: isWeekly ? 1240.50 : 5420.80,
                              percent: isWeekly ? 12 : 18,
                              isIncrease: true,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SummaryCard(
                              label: isWeekly ? 'Saved This Week' : 'Saved This Month',
                              amount: isWeekly ? 450.00 : 1850.00,
                              percent: isWeekly ? 8 : 15,
                              isIncrease: false,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      const SectionHeader(title: 'Top Category'),
                      const SizedBox(height: 12),
                      _CategoryAnalysisCard(isWeekly: isWeekly),
                      const SizedBox(height: 32),

                      const SectionHeader(title: 'Spending Trend'),
                      const SizedBox(height: 12),
                      _TrendChart(isDark: isDark, isWeekly: isWeekly),
                      const SizedBox(height: 32),

                      _buildAdvancedAnalytics(context, ref, isWeekly, isDark),
                      const SizedBox(height: 32),

                      const SectionHeader(title: 'Aura AI Advisor'),
                      const SizedBox(height: 12),
                      _SmartAIInsightCard(isWeekly: isWeekly),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(WidgetRef ref, InsightsTimeframe timeframe, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleItem('Weekly', timeframe == InsightsTimeframe.weekly, () => ref.read(insightsTimeframeProvider.notifier).setTimeframe(InsightsTimeframe.weekly))),
          Expanded(child: _toggleItem('Monthly', timeframe == InsightsTimeframe.monthly, () => ref.read(insightsTimeframeProvider.notifier).setTimeframe(InsightsTimeframe.monthly))),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticService.light();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 4))] : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade500,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedAnalytics(BuildContext context, WidgetRef ref, bool isWeekly, bool isDark) {
    final transactions = ref.watch(transactionsProvider);
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    if (expenses.isEmpty) return const SizedBox.shrink();

    // 1. Average Spending
    final totalSpent = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final daysWithData = expenses.map((t) => DateTime(t.date.year, t.date.month, t.date.day)).toSet().length;
    final avgDaily = daysWithData > 0 ? totalSpent / daysWithData : 0.0;

    // 2. Most Expensive Day
    final Map<DateTime, double> dailySpending = {};
    for (var t in expenses) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      dailySpending[day] = (dailySpending[day] ?? 0.0) + t.amount;
    }
    final mostExpensiveDay = dailySpending.entries.reduce((a, b) => a.value > b.value ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Advanced Analytics'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AnalyticsMetricCard(
                icon: Icons.speed_rounded,
                title: 'Daily Velocity',
                value: '\$${avgDaily.toStringAsFixed(0)}',
                subtitle: 'Average per day',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AnalyticsMetricCard(
                icon: Icons.event_busy_rounded,
                title: 'Peak Spending',
                value: '\$${mostExpensiveDay.value.toStringAsFixed(0)}',
                subtitle: DateFormat('MMM dd').format(mostExpensiveDay.key),
                isDark: isDark,
                accentColor: const Color(0xFFFF5E5E),
              ),
            ),
          ],
        ),
      ],
    );
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
          top: -150,
          right: -100,
          child: Container(
            width: screenWidth * 1.0,
            height: screenWidth * 1.0,
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6C63FF).withValues(alpha: isDark ? 0.08 : 0.04)),
          ),
        ),
        BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
      ],
    );
  }
}

class _AnalyticsMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool isDark;
  final Color? accentColor;

  const _AnalyticsMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isDark,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? const Color(0xFF6C63FF);
    return CustomCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87, letterSpacing: -1)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final int percent;
  final bool isIncrease;
  final bool isDark;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.percent,
    required this.isIncrease,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncrease ? const Color(0xFFFF5E5E) : const Color(0xFF10E294);
    
    return CustomCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87, letterSpacing: -1),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isIncrease ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 12, color: color),
                const SizedBox(width: 4),
                Text('$percent%', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryAnalysisCard extends StatelessWidget {
  final bool isWeekly;
  const _CategoryAnalysisCard({required this.isWeekly});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isWeekly ? const Color(0xFF00C9A7) : const Color(0xFF6C63FF)).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isWeekly ? Icons.shopping_cart_rounded : Icons.home_work_rounded, 
              color: isWeekly ? const Color(0xFF00C9A7) : const Color(0xFF6C63FF), 
              size: 28
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWeekly ? 'Shopping' : 'Home & Rent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  isWeekly ? '42% of total spending' : '35% of total budget', 
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w500)
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isWeekly ? '\$521' : '\$1.8K', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: isDark ? Colors.white : Colors.black87)
              ),
              const SizedBox(height: 4),
              Text(
                'TOP', 
                style: TextStyle(
                  fontSize: 10, 
                  color: isWeekly ? const Color(0xFF00C9A7) : const Color(0xFF6C63FF), 
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                )
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final bool isDark;
  final bool isWeekly;
  const _TrendChart({required this.isDark, required this.isWeekly});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      borderRadius: 28,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            maxY: 100,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                  '${rod.toY.toInt()}%',
                  TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    final labels = isWeekly ? ['M', 'T', 'W', 'T', 'F', 'S', 'S'] : ['W1', 'W2', 'W3', 'W4'];
                    if (value.toInt() >= labels.length) return const Text('');
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(labels[value.toInt()], style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 11, fontWeight: FontWeight.w700)),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: isWeekly ? [
              _buildBarGroup(0, 40, 30),
              _buildBarGroup(1, 60, 50),
              _buildBarGroup(2, 45, 60),
              _buildBarGroup(3, 80, 70),
              _buildBarGroup(4, 55, 65),
              _buildBarGroup(5, 90, 85),
              _buildBarGroup(6, 70, 75),
            ] : [
              _buildBarGroup(0, 80, 60),
              _buildBarGroup(1, 70, 85),
              _buildBarGroup(2, 90, 75),
              _buildBarGroup(3, 65, 50),
            ],
          ),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutQuart,
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1, 
          color: const Color(0xFF6C63FF), 
          width: 8, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
        BarChartRodData(
          toY: y2, 
          color: const Color(0xFF6C63FF).withValues(alpha: 0.3), 
          width: 8, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}

class _SmartAIInsightCard extends StatelessWidget {
  final bool isWeekly;
  const _SmartAIInsightCard({required this.isWeekly});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWeekly ? [const Color(0xFF6C63FF), const Color(0xFF4A90E2)] : [const Color(0xFF00C9A7), const Color(0xFF4A90E2)],
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (isWeekly ? const Color(0xFF6C63FF) : const Color(0xFF00C9A7)).withValues(alpha: 0.4), 
            blurRadius: 25, 
            offset: const Offset(0, 12)
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(bottom: -30, right: -20, child: Icon(Icons.auto_awesome_rounded, size: 140, color: Colors.white.withValues(alpha: 0.12))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('AURA AI ADVISOR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInsightText(isWeekly ? 'Your food expenses surged 12% this week vs. last.' : 'Housing remains your most efficient budget item.'),
                const SizedBox(height: 12),
                _buildInsightText(isWeekly ? 'Unusual shopping peak detected on Wednesday.' : 'You maintained a strong \$1,200 savings buffer.'),
                const SizedBox(height: 12),
                _buildInsightText(isWeekly ? 'Tip: Switch to bulk buying to save \$45/week.' : 'Tip: Renew your utility contract to save \$120/year.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightText(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(margin: const EdgeInsets.only(top: 6), width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white60, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, height: 1.5))),
      ],
    );
  }
}
