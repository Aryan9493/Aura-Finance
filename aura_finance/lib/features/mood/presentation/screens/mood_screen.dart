import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/widgets/animated_wrapper.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/section_header.dart';
import 'package:aura_finance/features/transactions/presentation/providers/transactions_provider.dart';

class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate Mood Stats
    final totalTransactions = transactions.length;
    final happyCount = transactions.where((t) => t.mood == '😀' || t.mood == '🛍️').length;
    final neutralCount = transactions.where((t) => t.mood == '😐' || t.mood == '🍿').length;
    final regretCount = transactions.where((t) => t.mood == '😤').length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mood Tracker',
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
                  const AnimatedWrapper(
                    delay: Duration(milliseconds: 100),
                    child: _BehavioralInsightCard(),
                  ),
                  const SizedBox(height: 24),
                  
                  const AnimatedWrapper(
                    delay: Duration(milliseconds: 200),
                    child: SectionHeader(title: 'Mood Breakdown'),
                  ),
                  const SizedBox(height: 12),
                  AnimatedWrapper(
                    delay: const Duration(milliseconds: 300),
                    child: _MoodSummaryRow(
                      happy: happyCount,
                      neutral: neutralCount,
                      regret: regretCount,
                      total: totalTransactions,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const AnimatedWrapper(
                    delay: Duration(milliseconds: 400),
                    child: SectionHeader(title: 'Emotional Spending Trend'),
                  ),
                  const SizedBox(height: 12),
                  AnimatedWrapper(
                    delay: const Duration(milliseconds: 500),
                    child: _MoodChart(
                      happy: happyCount.toDouble(),
                      neutral: neutralCount.toDouble(),
                      regret: regretCount.toDouble(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const AnimatedWrapper(
                    delay: Duration(milliseconds: 600),
                    child: SectionHeader(title: 'Recent Moods'),
                  ),
                  const SizedBox(height: 12),
                  if (transactions.isEmpty)
                    _buildEmptyState(isDark)
                  else
                    ...transactions.take(5).map((t) => AnimatedWrapper(
                      delay: const Duration(milliseconds: 700),
                      child: _RecentMoodItem(transactionTitle: t.title, mood: t.mood ?? '😐', amount: t.amount),
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(Icons.mood_outlined, size: 60, color: isDark ? Colors.white24 : Colors.black12),
            const SizedBox(height: 16),
            Text('No moods recorded yet', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38)),
          ],
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
          top: -100,
          right: -50,
          child: Container(
            width: screenWidth * 0.9,
            height: screenWidth * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFCC33).withValues(alpha: isDark ? 0.08 : 0.04),
            ),
          ),
        ),
        BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
      ],
    );
  }
}

class _BehavioralInsightCard extends StatelessWidget {
  const _BehavioralInsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFF9A9E).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text('Psychology Insight', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'You feel happy about 65% of your food expenses, but regret 40% of your shopping sprees.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _MoodSummaryRow extends StatelessWidget {
  final int happy;
  final int neutral;
  final int regret;
  final int total;

  const _MoodSummaryRow({required this.happy, required this.neutral, required this.regret, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _moodStatCard('Happy', '😀', happy, total, const Color(0xFF10E294)),
        const SizedBox(width: 12),
        _moodStatCard('Neutral', '😐', neutral, total, Colors.blueAccent),
        const SizedBox(width: 12),
        _moodStatCard('Regret', '😤', regret, total, const Color(0xFFFF5E5E)),
      ],
    );
  }

  Widget _moodStatCard(String label, String emoji, int count, int total, Color color) {
    final percent = total > 0 ? (count / total * 100).toInt() : 0;
    return Expanded(
      child: CustomCard(
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text('$percent%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _MoodChart extends StatelessWidget {
  final double happy;
  final double neutral;
  final double regret;

  const _MoodChart({required this.happy, required this.neutral, required this.regret});

  @override
  Widget build(BuildContext context) {
    final total = happy + neutral + regret;
    return CustomCard(
      child: SizedBox(
        height: 180,
        child: PieChart(
          PieChartData(
            sectionsSpace: 8,
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(value: happy == 0 && total == 0 ? 1 : happy, color: const Color(0xFF10E294), radius: 25, showTitle: false),
              PieChartSectionData(value: neutral, color: Colors.blueAccent, radius: 25, showTitle: false),
              PieChartSectionData(value: regret, color: const Color(0xFFFF5E5E), radius: 25, showTitle: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentMoodItem extends StatelessWidget {
  final String transactionTitle;
  final String mood;
  final double amount;

  const _RecentMoodItem({required this.transactionTitle, required this.mood, required this.amount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        child: Row(
          children: [
            Text(mood, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                transactionTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
            ),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
