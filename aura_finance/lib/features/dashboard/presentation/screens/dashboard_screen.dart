import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/widgets/animated_wrapper.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/section_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Leverage MediaQuery for highly dynamic padding/spacing
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingHorizontal = screenWidth * 0.05; // 5% of screen width

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: paddingHorizontal),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient and Glows
          _buildBackground(isDark, screenWidth),

          // Main Content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AnimatedWrapper(
                    delay: Duration(milliseconds: 100),
                    child: _BalanceCard(),
                  ),
                  const SizedBox(height: 24),
                  
                  const AnimatedWrapper(
                    delay: Duration(milliseconds: 200),
                    child: _SmartInsightCard(),
                  ),
                  const SizedBox(height: 24),

                  const AnimatedWrapper(
                    delay: Duration(milliseconds: 300),
                    child: SectionHeader(title: 'Weekly Spending'),
                  ),
                  const SizedBox(height: 16),
                  AnimatedWrapper(
                    delay: const Duration(milliseconds: 400),
                    child: _WeeklySpendingChart(isDark: isDark),
                  ),
                  const SizedBox(height: 24),
                  
                  const AnimatedWrapper(
                    delay: Duration(milliseconds: 500),
                    child: SectionHeader(title: 'Expense Categories'),
                  ),
                  const SizedBox(height: 16),
                  AnimatedWrapper(
                    delay: const Duration(milliseconds: 600),
                    child: _ExpenseCategoryChart(isDark: isDark),
                  ),
                  const SizedBox(height: 24),
                  
                  const AnimatedWrapper(
                    delay: Duration(milliseconds: 700),
                    child: SectionHeader(title: 'Savings Goal'),
                  ),
                  const SizedBox(height: 16),
                  const AnimatedWrapper(
                    delay: Duration(milliseconds: 800),
                    child: _SavingsProgress(),
                  ),
                  // Increased padding significantly to account for floating nav bar height
                  const SizedBox(height: 140), 
                ],
              ),
            ),
          ),
        ],
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
          left: -100,
          child: Container(
            width: screenWidth * 1.2,
            height: screenWidth * 1.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF6C63FF).withValues(alpha: 0.15) : const Color(0xFF6C63FF).withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          top: 200,
          right: -150,
          child: Container(
            width: screenWidth * 1.0,
            height: screenWidth * 1.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF00C9A7).withValues(alpha: 0.1) : const Color(0xFF00C9A7).withValues(alpha: 0.05),
            ),
          ),
        ),
        // Applying blur for soft glowing shapes
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
        // Subtle glass overlay border effect
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Icon(Icons.account_balance_wallet, color: Colors.white.withValues(alpha: 0.5), size: 28),
            ],
          ),
          const SizedBox(height: 12),
          const FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _CountUpText(
              endValue: 24560.50,
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildIncomeExpenseBlock(
                  Icons.arrow_downward_rounded,
                  'Income',
                  4200.00,
                  const Color(0xFF10E294),
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIncomeExpenseBlock(
                  Icons.arrow_upward_rounded,
                  'Expense',
                  1240.00,
                  const Color(0xFFFF5E5E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseBlock(
      IconData icon, String label, double amount, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: _CountUpText(
                  endValue: amount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
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
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final formatted = '\$${value.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
        return Text(formatted, style: style);
      },
    );
  }
}

class _SmartInsightCard extends StatelessWidget {
  const _SmartInsightCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return CustomCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB74D).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFFB74D), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spending Insight',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You spent 20% more this week relative to your typical budget.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklySpendingChart extends StatelessWidget {
  final bool isDark;

  const _WeeklySpendingChart({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white54 : Colors.black54;

    return CustomCard(
      child: SizedBox(
        height: 240,
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0, right: 8.0, bottom: 8.0, left: 0.0),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  );
                },
              ),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      const FlLine(color: Color(0xFF6C63FF), strokeWidth: 2),
                      FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(radius: 5, color: Colors.white, strokeWidth: 2, strokeColor: const Color(0xFF6C63FF));
                      }),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => isDark ? const Color(0xFF2C2559) : Colors.white,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '\$${spot.y.toInt()}',
                        TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      if (value >= 0 && value < days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(days[value.toInt()],
                                style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600)),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) {
                      if (value % 20 == 0 && value != 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text('\$${value.toInt()}',
                                style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.w600)),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 20),
                    FlSpot(1, 45),
                    FlSpot(2, 35),
                    FlSpot(3, 75),
                    FlSpot(4, 52),
                    FlSpot(5, 80),
                    FlSpot(6, 60),
                  ],
                  isCurved: true,
                  color: const Color(0xFF6C63FF),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFF6C63FF),
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C63FF).withValues(alpha: 0.3),
                        const Color(0xFF6C63FF).withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 100,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseCategoryChart extends StatefulWidget {
  final bool isDark;
  const _ExpenseCategoryChart({required this.isDark});

  @override
  State<_ExpenseCategoryChart> createState() => _ExpenseCategoryChartState();
}

class _ExpenseCategoryChartState extends State<_ExpenseCategoryChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: SizedBox(
          height: 220,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    startDegreeOffset: 180,
                    sections: [
                      _buildPieSection(0, const Color(0xFF6C63FF), 40, '40%'),
                      _buildPieSection(1, const Color(0xFF00C9A7), 30, '30%'),
                      _buildPieSection(2, const Color(0xFFFFB74D), 15, '15%'),
                      _buildPieSection(3, const Color(0xFFE57373), 15, '15%'),
                    ],
                  ),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOutBack,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Housing', const Color(0xFF6C63FF), textColor, 0),
                    const SizedBox(height: 12),
                    _buildLegendItem('Food', const Color(0xFF00C9A7), textColor, 1),
                    const SizedBox(height: 12),
                    _buildLegendItem('Transport', const Color(0xFFFFB74D), textColor, 2),
                    const SizedBox(height: 12),
                    _buildLegendItem('Misc', const Color(0xFFE57373), textColor, 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PieChartSectionData _buildPieSection(int index, Color color, double value, String title) {
    final isTouched = index == touchedIndex;
    final fontSize = isTouched ? 16.0 : 12.0;
    final radius = isTouched ? 45.0 : 35.0;

    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color, Color textColor, int index) {
    final isTouched = index == touchedIndex;
    return Row(
      children: [
        AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isTouched ? 16 : 12,
            height: isTouched ? 16 : 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              color: color,
              boxShadow: isTouched ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6, spreadRadius: 1)] : [],
            )),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(title,
                style: TextStyle(
                    fontSize: isTouched ? 14 : 13, 
                    fontWeight: isTouched ? FontWeight.bold : FontWeight.w600, 
                    color: textColor)),
          ),
        ),
      ],
    );
  }
}

class _SavingsProgress extends StatelessWidget {
  const _SavingsProgress();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 0.65),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                        color: const Color(0xFF00C9A7),
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 65),
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Car Fund',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '\$6,500 saved of \$10,000',
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress text mini
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'You are right on track!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00C9A7).withValues(alpha: 0.9),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
