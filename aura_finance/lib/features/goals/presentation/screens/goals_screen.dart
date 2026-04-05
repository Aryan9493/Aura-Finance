import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/animated_wrapper.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/goal.dart';
import '../providers/goals_provider.dart';

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
            child: goals.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 180),
                    itemCount: goals.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: SectionHeader(title: 'Active Progress'),
                        );
                      }
                      final goal = goals[index - 1];
                      return AnimatedWrapper(
                        delay: Duration(milliseconds: 100 * index),
                        child: _GoalCard(goal: goal),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 85),
        child: _AddGoalButton(),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag_outlined, size: 80, color: isDark ? Colors.white24 : Colors.black12),
          const SizedBox(height: 16),
          Text(
            'No goals set yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            'Dream it, track it, achieve it!',
            style: TextStyle(fontSize: 16, color: isDark ? Colors.white38 : Colors.black38),
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
          top: -100,
          left: -50,
          child: Container(
            width: screenWidth * 0.9,
            height: screenWidth * 0.9,
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(goal.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(color: const Color(0xFFFF5E5E), borderRadius: BorderRadius.circular(20)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        onDismissed: (_) => ref.read(goalsProvider.notifier).removeGoal(goal.id),
        child: GestureDetector(
          onTap: () => _showTopUpDialog(context, ref),
          onLongPress: () => _showGoalForm(context, ref, goal: goal),
          child: CustomCard(
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${goal.percent}%', style: const TextStyle(color: Color(0xFF00C9A7), fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Saved: \$${goal.currentAmount.toInt()} / \$${goal.targetAmount.toInt()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Deadline: ${DateFormat('MMM dd').format(goal.deadline)}',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProgressBar(isDark),
                const SizedBox(height: 12),
                Text(
                  _getMotivationalText(goal.percent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00C9A7).withValues(alpha: 0.8)),
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
      height: 10,
      width: double.infinity,
      decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
      child: LayoutBuilder(
        builder: (context, constraints) => AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.easeOutCubic,
          width: constraints.maxWidth * goal.progress,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00C9A7), Color(0xFF6C63FF)]),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: const Color(0xFF00C9A7).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
        ),
      ),
    );
  }

  String _getMotivationalText(int percent) {
    if (percent >= 100) return 'Goal Achieved! You did it! 🎉';
    if (percent >= 80) return 'Almost there! Just a final push! 💪';
    if (percent >= 50) return 'You are ${percent}% closer to your goal!';
    return 'Great start! Keep saving consistently! 💸';
  }

  void _showTopUpDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Savings'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(prefixText: '\$ ', hintText: 'Enter amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null) ref.read(goalsProvider.notifier).addProgress(goal.id, amount);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _AddGoalButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF00C9A7), Color(0xFF68E1FD)]),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: const Color(0xFF00C9A7).withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4)),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showGoalForm(context, ref),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
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
          color: isDark ? const Color(0xFF1A1438) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.black12, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(widget.goal == null ? 'Create New Goal' : 'Edit Goal', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  _buildTextField(_titleController, 'Goal Name (e.g. Dream Car)', Icons.flag_outlined, isDark),
                  const SizedBox(height: 16),
                  _buildTextField(_targetController, 'Target Amount', Icons.monetization_on_outlined, isDark, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildDatePicker(isDark),
                  const SizedBox(height: 32),
                  _buildSaveButton(ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isDark, {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: Colors.grey), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16)),
      ),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: _deadline, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)));
        if (d != null) setState(() => _deadline = d);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [const Icon(Icons.calendar_today_rounded, color: Colors.grey, size: 20), const SizedBox(width: 16), Text('Deadline: ${DateFormat('MMM dd, yyyy').format(_deadline)}')]),
      ),
    );
  }

  Widget _buildSaveButton(WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (_titleController.text.isEmpty || _targetController.text.isEmpty) return;
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
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF00C9A7), Color(0xFF6C63FF)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF00C9A7).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        alignment: Alignment.center,
        child: Text(widget.goal == null ? 'Launch Goal 🚀' : 'Keep Growing', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
