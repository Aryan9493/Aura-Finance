import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/goal.dart';
import '../providers/goals_provider.dart';
import '../../../../core/services/haptic_service.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Savings Goals',
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
            child: goals.isEmpty
                ? _buildEmptyState(isDark)
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 200),
                      itemCount: goals.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const AnimationConfiguration.staggeredList(
                            position: 0,
                            duration: Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: SectionHeader(title: 'Active Progress'),
                                ),
                              ),
                            ),
                          );
                        }
                        final goal = goals[index - 1];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _GoalCard(goal: goal),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: _AddGoalButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stars_rounded, size: 64, color: isDark ? Colors.white24 : Colors.black12),
          ),
          const SizedBox(height: 24),
          Text(
            'No goals set yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            'Visualize your dreams and track your\nprogress on the path to financial freedom.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: isDark ? Colors.white38 : Colors.black38, height: 1.5),
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
                  : [const Color(0xFFF8F9FD), const Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: screenWidth * 1.0,
            height: screenWidth * 1.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00C9A7).withValues(alpha: isDark ? 0.08 : 0.04),
            ),
          ),
        ),
        BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
      ],
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Dismissible(
        key: Key(goal.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(color: const Color(0xFFFF5E5E), borderRadius: BorderRadius.circular(24)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32),
        ),
        confirmDismiss: (_) async {
          HapticService.medium();
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: const Text('Remove Goal?'),
              content: const Text('Are you sure you want to stop tracking this goal?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Not now')),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Remove', style: TextStyle(color: Color(0xFFFF5E5E), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) {
          ref.read(goalsProvider.notifier).removeGoal(goal.id);
          HapticService.success();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goal removed'), behavior: SnackBarBehavior.floating));
        },
        child: GestureDetector(
          onTap: () {
            HapticService.light();
            _showTopUpDialog(context, ref);
          },
          onLongPress: () {
            HapticService.medium();
            _showGoalForm(context, ref, goal: goal);
          },
          child: CustomCard(
            borderRadius: 28,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C9A7).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${goal.percent}%',
                        style: const TextStyle(color: Color(0xFF00C9A7), fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : Colors.grey.shade700, fontWeight: FontWeight.w500),
                          children: [
                            const TextSpan(text: 'Saved '),
                            TextSpan(
                              text: '\$${goal.currentAmount.toInt()}',
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' of \$${goal.targetAmount.toInt()}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('MMM dd').format(goal.deadline),
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildProgressBar(isDark),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 14, color: const Color(0xFF00C9A7).withValues(alpha: 0.8)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _getMotivationalText(goal.percent),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF00C9A7).withValues(alpha: 0.9)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(10)),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutExpo,
              width: constraints.maxWidth * goal.progress,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00C9A7), Color(0xFF6C63FF)]),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00C9A7).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
            ),
            if (goal.progress > 0)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container().animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms, color: Colors.white12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getMotivationalText(int percent) {
    if (percent >= 100) return 'Goal Completed! Amazing work! ✨';
    if (percent >= 90) return 'Almost there! You can do this! 🚀';
    if (percent >= 75) return 'Breaking through! Keep pushing! 💪';
    if (percent >= 50) return 'Halfway there! Keep that momentum! 🔥';
    if (percent >= 25) return 'Great progress! One step at a time. 💸';
    return 'The journey begins! Your future self thanks you. 🌱';
  }

  void _showTopUpDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Add Savings'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          decoration: const InputDecoration(prefixText: '\$ ', hintText: '0.00', border: InputBorder.none),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null) {
                ref.read(goalsProvider.notifier).addProgress(goal.id, amount);
                HapticService.success();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Savings updated!'), behavior: SnackBarBehavior.floating));
              }
            },
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _AddGoalButton extends StatefulWidget {
  @override
  State<_AddGoalButton> createState() => _AddGoalButtonState();
}

class _AddGoalButtonState extends State<_AddGoalButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => GestureDetector(
        onTapDown: (_) {
          HapticService.light();
          setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _showGoalForm(context, ref);
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C9A7), Color(0xFF68E1FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C9A7).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.stars_rounded, color: Colors.white, size: 36),
          ),
        ),
      ),
    );
  }
}

void _showGoalForm(BuildContext context, WidgetRef ref, {Goal? goal}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (context) => _GoalForm(goal: goal),
  );
}

class _GoalForm extends ConsumerStatefulWidget {
  final Goal? goal;
  const _GoalForm({this.goal});

  @override
  ConsumerState<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends ConsumerState<_GoalForm> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _titleController.text = widget.goal!.title;
      _targetController.text = widget.goal!.targetAmount.toString();
      _deadline = widget.goal!.deadline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141221) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, -10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Text(widget.goal == null ? 'Dream New Goal' : 'Refine Your Goal', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  _buildTextField(_titleController, 'Goal Title (e.g. Dream Apartment)', Icons.auto_awesome_outlined, isDark),
                  const SizedBox(height: 16),
                  _buildTextField(_targetController, 'Target Amount', Icons.monetization_on_rounded, isDark, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 16),
                  _buildDatePicker(isDark),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    text: widget.goal == null ? 'Launch Your Journey 🚀' : 'Save Adjustments',
                    onTap: () => _handleSave(ref, context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave(WidgetRef ref, BuildContext context) {
    if (_titleController.text.isEmpty || _targetController.text.isEmpty) {
      HapticService.error();
      return;
    }
    final newGoal = Goal(
      id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      targetAmount: double.parse(_targetController.text),
      currentAmount: widget.goal?.currentAmount ?? 0,
      deadline: _deadline,
    );
    if (widget.goal == null) {
      ref.read(goalsProvider.notifier).addGoal(newGoal);
    } else {
      ref.read(goalsProvider.notifier).updateGoal(newGoal);
    }
    HapticService.success();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.goal == null ? 'New goal launched!' : 'Goal updated!'), 
        backgroundColor: const Color(0xFF00C9A7),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isDark, {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(18)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return GestureDetector(
      onTap: () async {
        HapticService.light();
        final d = await showDatePicker(
          context: context,
          initialDate: _deadline,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: Color(0xFF00C9A7), onPrimary: Colors.white, surface: Color(0xFF1A1438)),
            ),
            child: child!,
          ),
        );
        if (d != null) setState(() => _deadline = d);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(18)),
        child: Row(children: [const Icon(Icons.calendar_today_rounded, color: Colors.grey, size: 24), const SizedBox(width: 16), Text('Ends on ${DateFormat('MMMM dd, yyyy').format(_deadline)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))]),
      ),
    );
  }
}
