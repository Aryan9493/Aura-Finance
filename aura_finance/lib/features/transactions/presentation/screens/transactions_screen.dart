import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/animated_wrapper.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transactions_provider.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Content flows behind nav bar
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Transactions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(isDark, MediaQuery.of(context).size.width),
          _TransactionsList(),
        ],
      ),
      // FAB Position adjusted to be above the floating nav bar
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 85), // Height of nav bar (65) + margin (12) + buffer
        child: _AddTransactionButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          right: -100,
          child: Container(
            width: screenWidth * 0.8,
            height: screenWidth * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF5E5E).withValues(alpha: isDark ? 0.08 : 0.03),
            ),
          ),
        ),
        BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
      ],
    );
  }
}

class _TransactionsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (transactions.isEmpty) return _buildEmptyState(isDark);

    return SafeArea(
      bottom: false,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 180), // Increased bottom padding for FAB & Nav
        itemCount: transactions.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: SectionHeader(title: 'Recent Activity'),
            );
          }
          final transaction = transactions[index - 1];
          return AnimatedWrapper(
            delay: Duration(milliseconds: 100 * index),
            child: _TransactionListItem(transaction: transaction),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 80, color: isDark ? Colors.white24 : Colors.black12),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your spending',
            style: TextStyle(fontSize: 16, color: isDark ? Colors.white38 : Colors.black38),
          ),
        ],
      ),
    );
  }
}

class _TransactionListItem extends ConsumerWidget {
  final Transaction transaction;
  const _TransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = transaction.type == TransactionType.income;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(color: const Color(0xFFFF5E5E), borderRadius: BorderRadius.circular(20)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Transaction'),
              content: const Text('Are you sure you want to delete this transaction?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete', style: TextStyle(color: Color(0xFFFF5E5E))),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) => ref.read(transactionsProvider.notifier).removeTransaction(transaction.id),
        child: GestureDetector(
          onTap: () => _showTransactionForm(context, ref, transaction: transaction),
          child: CustomCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isIncome ? const Color(0xFF10E294) : const Color(0xFF6C63FF)).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(transaction.mood ?? _getCategoryEmoji(transaction.category), style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(transaction.date),
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isIncome ? const Color(0xFF10E294) : const Color(0xFFFF5E5E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'food': return '🍔';
      case 'salary': return '💰';
      case 'transport': return '🚗';
      case 'entertainment': return '🍿';
      default: return '📦';
    }
  }
}

class _AddTransactionButton extends StatefulWidget {
  @override
  State<_AddTransactionButton> createState() => _AddTransactionButtonState();
}

class _AddTransactionButtonState extends State<_AddTransactionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) => GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _showTransactionForm(context, ref);
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}

void _showTransactionForm(BuildContext context, WidgetRef ref, {Transaction? transaction}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (context) => _TransactionForm(transaction: transaction),
  );
}

class _TransactionForm extends ConsumerStatefulWidget {
  final Transaction? transaction;
  const _TransactionForm({this.transaction});

  @override
  ConsumerState<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<_TransactionForm> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String _category = 'Food';
  String _mood = '😐';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _titleController.text = widget.transaction!.title;
      _noteController.text = widget.transaction!.note ?? '';
      _type = widget.transaction!.type;
      _category = widget.transaction!.category;
      _mood = widget.transaction!.mood ?? '😐';
      _date = widget.transaction!.date;
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
            Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: _type == TransactionType.income ? const Color(0xFF10E294) : const Color(0xFFFF5E5E),
                        ),
                        decoration: const InputDecoration(prefixText: '\$ ', hintText: '0.00', border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildToggleRow(isDark),
                    const SizedBox(height: 24),
                    _buildTextField(_titleController, 'Title', Icons.edit_outlined, isDark),
                    const SizedBox(height: 16),
                    _buildTextField(_noteController, 'Note (Optional)', Icons.notes_rounded, isDark),
                    const SizedBox(height: 16),
                    _buildDropdown(isDark),
                    const SizedBox(height: 16),
                    _buildDatePicker(isDark),
                    const SizedBox(height: 16),
                    _buildMoodSelector(isDark),
                    const SizedBox(height: 48),
                    _buildSaveButton(ref, context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(child: _buildToggleButton('Expense', TransactionType.expense)),
          Expanded(child: _buildToggleButton('Income', TransactionType.income)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, TransactionType type) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? (type == TransactionType.income ? const Color(0xFF10E294) : const Color(0xFFFF5E5E)) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isDark) {
    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: Colors.grey), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16)),
      ),
    );
  }

  Widget _buildDropdown(bool isDark) {
    final categories = ['Food', 'Salary', 'Transport', 'Entertainment', 'Misc'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          isExpanded: true,
          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (val) => setState(() => _category = val!),
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime.now());
        if (d != null) setState(() => _date = d);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [const Icon(Icons.calendar_today_rounded, color: Colors.grey, size: 20), const SizedBox(width: 16), Text(DateFormat('MMM dd, yyyy').format(_date))]),
      ),
    );
  }

  Widget _buildMoodSelector(bool isDark) {
    final moods = ['😀', '😐', '😤', '🍿', '🛍️'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('How do you feel?', style: TextStyle(fontWeight: FontWeight.w600))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: moods.map((m) => GestureDetector(
            onTap: () => setState(() => _mood = m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _mood == m ? const Color(0xFF6C63FF).withValues(alpha: 0.2) : Colors.transparent, shape: BoxShape.circle),
              child: Text(m, style: const TextStyle(fontSize: 24)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton(WidgetRef ref, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_amountController.text.isEmpty || _titleController.text.isEmpty) return;
        final newTransaction = Transaction(
          id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          amount: double.parse(_amountController.text),
          date: _date,
          category: _category,
          type: _type,
          note: _noteController.text,
          mood: _mood,
        );
        if (widget.transaction == null) {
          ref.read(transactionsProvider.notifier).addTransaction(newTransaction);
        } else {
          ref.read(transactionsProvider.notifier).updateTransaction(newTransaction);
        }
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        alignment: Alignment.center,
        child: Text(widget.transaction == null ? 'Add Transaction' : 'Save Changes', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
