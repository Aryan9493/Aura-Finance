import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/animated_wrapper.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../providers/insights_provider.dart';

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
        title: Text(
          'Insights',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(isDark, screenWidth),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildToggle(ref, timeframe, isDark),
                  const SizedBox(height: 24),
                  
                  // Summary Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedWrapper(
                          key: ValueKey('summary_1_$timeframe'),
                          delay: const Duration(milliseconds: 100),
                          child: _SummaryCard(
                            label: isWeekly ? 'This Week' : 'This Month',
                            amount: isWeekly ? 1240.50 : 5420.80,
                            percent: isWeekly ? 12 : 18,
                            isIncrease: true,
                            isDark: isDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnimatedWrapper(
                          key: ValueKey('summary_2_$timeframe'),
                          delay: const Duration(milliseconds: 200),
                          child: _SummaryCard(
                            label: isWeekly ? 'Last Week' : 'Last Month',
                            amount: isWeekly ? 1100.00 : 4580.00,
                            percent: isWeekly ? 8 : 5,
                            isIncrease: false,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  AnimatedWrapper(
                    key: ValueKey('header_cat_$timeframe'),
                    delay: const Duration(milliseconds: 300),
                    child: const SectionHeader(title: 'Top Category'),
                  ),
                  const SizedBox(height: 12),
                  AnimatedWrapper(
                    key: ValueKey('card_cat_$timeframe'),
                    delay: const Duration(milliseconds: 400),
                    child: _CategoryAnalysisCard(isWeekly: isWeekly),
                  ),
                  const SizedBox(height: 24),

                  AnimatedWrapper(
                    key: ValueKey('header_trend_$timeframe'),
                    delay: const Duration(milliseconds: 500),
                    child: const SectionHeader(title: 'Trend Comparison'),
                  ),
                  const SizedBox(height: 12),
                  AnimatedWrapper(
                    key: ValueKey('chart_trend_$timeframe'),
                    delay: const Duration(milliseconds: 600),
                    child: _TrendChart(isDark: isDark, isWeekly: isWeekly),
                  ),
                  const SizedBox(height: 24),

                  AnimatedWrapper(
                    key: ValueKey('header_ai_$timeframe'),
                    delay: const Duration(milliseconds: 700),
                    child: const SectionHeader(title: 'Aura AI Insights'),
                  ),
                  const SizedBox(height: 12),
                  AnimatedWrapper(
                    key: ValueKey('card_ai_$timeframe'),
                    delay: const Duration(milliseconds: 800),
                    child: _SmartAIInsightCard(isWeekly: isWeekly),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(WidgetRef ref, InsightsTimeframe timeframe, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
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
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
                  : [const Color(0xFFF0F2F5), const Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -150,
          right: -50,
          child: Container(
            width: screenWidth * 1.0,
            height: screenWidth * 1.0,
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6C63FF).withValues(alpha: isDark ? 0.1 : 0.05)),
          ),
        ),
        BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(isIncrease ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 14, color: color),
              const SizedBox(width: 4),
              Text('$percent%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isWeekly ? const Color(0xFF00C9A7).withValues(alpha: 0.15) : const Color(0xFF6C63FF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(isWeekly ? Icons.shopping_bag_rounded : Icons.home_rounded, color: isWeekly ? const Color(0xFF00C9A7) : const Color(0xFF6C63FF), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWeekly ? 'Shopping' : 'Housing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                Text(isWeekly ? '42% of total spending' : '35% of total budget', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(isWeekly ? '\$521.20' : '\$1,890.00', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text('Top category', style: TextStyle(fontSize: 10, color: isWeekly ? const Color(0xFF00C9A7) : const Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
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
      child: SizedBox(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final labels = isWeekly ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] : ['W1', 'W2', 'W3', 'W4'];
                      if (value.toInt() >= labels.length) return const Text('');
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(labels[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 10)),
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
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y1, color: const Color(0xFF6C63FF), width: 8, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: y2, color: const Color(0xFF6C63FF).withValues(alpha: 0.3), width: 8, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }
}

class _SmartAIInsightCard extends StatelessWidget {
  final bool isWeekly;
  const _SmartAIInsightCard({required this.isWeekly});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWeekly ? [const Color(0xFF6C63FF), const Color(0xFF4A90E2)] : [const Color(0xFF00C9A7), const Color(0xFF4A90E2)],
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: (isWeekly ? const Color(0xFF6C63FF) : const Color(0xFF00C9A7)).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(bottom: -20, right: -20, child: Icon(Icons.auto_awesome_rounded, size: 100, color: Colors.white.withValues(alpha: 0.1))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.insights_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('AI Savings Guide', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInsightText(isWeekly ? 'You spent 12% more on Food this week.' : 'Housing is your biggest expense this month.'),
                const SizedBox(height: 8),
                _buildInsightText(isWeekly ? 'Your shopping habits are higher than last month.' : 'You saved \$240 on coffee this month!'),
                const SizedBox(height: 8),
                _buildInsightText(isWeekly ? 'Tip: Save \$50 by skipping one takeout meal.' : 'Tip: Rent is due in 3 days. Ensure \$1,800 is ready.'),
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
        const Text('• ', style: TextStyle(color: Colors.white70, fontSize: 16)),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4))),
      ],
    );
  }
}
