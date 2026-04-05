import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transactions_provider.dart';
import '../../../../core/services/haptic_service.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Transactions',
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
          _buildBackground(isDark, MediaQuery.of(context).size.width),
          const _TransactionsList(),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
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
                  : [const Color(0xFFF8F9FD), const Color(0xFFFFFFFF)],
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
  const _TransactionsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (transactions.isEmpty) return _buildEmptyState(isDark);

    return SafeArea(
      bottom: false,
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 200),
          itemCount: transactions.length + 1,
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
                      child: SectionHeader(title: 'Recent Activity'),
                    ),
                  ),
                ),
              );
            }
            final transaction = transactions[index - 1];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _TransactionListItem(transaction: transaction),
                ),
              ),
            );
          },
        ),
      ),
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
            child: Icon(Icons.account_balance_wallet_outlined, size: 64, color: isDark ? Colors.white24 : Colors.black12),
          ),
          const SizedBox(height: 24),
          Text(
            'No transactions yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your finances to see\nyour activity here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: isDark ? Colors.white38 : Colors.black38, height: 1.5),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(color: const Color(0xFFFF5E5E), borderRadius: BorderRadius.circular(24)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32),
        ),
        confirmDismiss: (direction) async {
          HapticService.medium();
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: const Text('Delete Transaction?'),
              content: const Text('This action cannot be undone. Are you sure?'),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete', style: TextStyle(color: Color(0xFFFF5E5E), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) {
          ref.read(transactionsProvider.notifier).removeTransaction(transaction.id);
          HapticService.success();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction deleted'), behavior: SnackBarBehavior.floating),
          );
        },
        child: GestureDetector(
          onTap: () {
            HapticService.light();
            _showTransactionForm(context, ref, transaction: transaction);
          },
          child: CustomCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isIncome ? const Color(0xFF10E294) : const Color(0xFF6C63FF)).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(transaction.date),
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
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
        onTapDown: (_) {
          HapticService.light();
          setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _showTransactionForm(context, ref);
        },
        onLongPress: () {
          HapticService.medium();
          setState(() => _isPressed = false);
          _showQuickAddOptions(context, ref);
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
                colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
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
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (context) => _TransactionForm(transaction: transaction),
  );
}

void _showQuickAddOptions(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (context) => _QuickAddSheet(ref: ref),
  );
}

class _QuickAddSheet extends StatelessWidget {
  final WidgetRef ref;
  const _QuickAddSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final quickOptions = [
      {'title': 'Coffee/Food', 'amount': 10.0, 'category': 'Food', 'emoji': '☕'},
      {'title': 'Uber/Fuel', 'amount': 25.0, 'category': 'Transport', 'emoji': '🚗'},
      {'title': 'Monthly Bill', 'amount': 100.0, 'category': 'Misc', 'emoji': '📜'},
      {'title': 'Cinema/Sub', 'amount': 15.0, 'category': 'Entertainment', 'emoji': '🍿'},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141221) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),
          const Text('Quick Add Expense', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 90,
            ),
            itemCount: quickOptions.length,
            itemBuilder: (context, index) {
              final opt = quickOptions[index];
              return _QuickOptionCard(
                title: opt['title'] as String,
                amount: opt['amount'] as double,
                emoji: opt['emoji'] as String,
                onTap: () {
                  final tx = Transaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: opt['title'] as String,
                    amount: opt['amount'] as double,
                    date: DateTime.now(),
                    category: opt['category'] as String,
                    type: TransactionType.expense,
                    mood: '😐',
                  );
                  ref.read(transactionsProvider.notifier).addTransaction(tx);
                  HapticService.success();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${opt['title']} added instantly!'),
                      backgroundColor: const Color(0xFF10E294),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              _showTransactionForm(context, ref);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: const Center(
                child: Text('Custom Transaction', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickOptionCard extends StatelessWidget {
  final String title;
  final double amount;
  final String emoji;
  final VoidCallback onTap;

  const _QuickOptionCard({
    required this.title,
    required this.amount,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        borderRadius: 20,
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? Colors.white70 : Colors.black54), maxLines: 1),
                  Text('\$${amount.toInt()}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: isDark ? Colors.white : Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
            Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                          color: _type == TransactionType.income ? const Color(0xFF10E294) : const Color(0xFFFF5E5E),
                        ),
                        decoration: const InputDecoration(prefixText: '\$ ', hintText: '0.00', border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildToggleRow(isDark),
                    const SizedBox(height: 24),
                    _buildTextField(_titleController, 'Description', Icons.edit_note_rounded, isDark),
                    const SizedBox(height: 16),
                    _buildTextField(_noteController, 'Note (Optional)', Icons.notes_rounded, isDark),
                    const SizedBox(height: 16),
                    _buildDropdown(isDark),
                    const SizedBox(height: 16),
                    _buildDatePicker(isDark),
                    const SizedBox(height: 24),
                    _buildMoodSelector(isDark),
                    const SizedBox(height: 48),
                    PrimaryButton(
                      text: widget.transaction == null ? 'Add Transaction' : 'Save Changes',
                      onTap: () => _handleSave(ref, context),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave(WidgetRef ref, BuildContext context) {
    if (_amountController.text.isEmpty || _titleController.text.isEmpty) {
      HapticService.error();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter title and amount')));
      return;
    }
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
    HapticService.success();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.transaction == null ? 'Transaction added!' : 'Transaction updated!'),
        backgroundColor: const Color(0xFF10E294),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildToggleRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
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
      onTap: () {
        HapticService.light();
        setState(() => _type = type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? (type == TransactionType.income ? const Color(0xFF10E294) : const Color(0xFFFF5E5E)) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected ? [BoxShadow(color: (type == TransactionType.income ? const Color(0xFF10E294) : const Color(0xFFFF5E5E)).withValues(alpha: 0.3), blurRadius: 10)] : [],
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isDark) {
    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(18)),
      child: TextField(
        controller: controller,
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

  Widget _buildDropdown(bool isDark) {
    final categories = ['Food', 'Salary', 'Transport', 'Entertainment', 'Misc'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(18)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 16),
          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (val) {
             HapticService.light();
             setState(() => _category = val!);
          },
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
          initialDate: _date,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(primary: Color(0xFF6C63FF), onPrimary: Colors.white, surface: Color(0xFF1A1438)),
            ),
            child: child!,
          ),
        );
        if (d != null) setState(() => _date = d);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(18)),
        child: Row(children: [const Icon(Icons.calendar_month_rounded, color: Colors.grey, size: 24), const SizedBox(width: 16), Text(DateFormat('EEEE, MMM dd').format(_date), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))]),
      ),
    );
  }

  Widget _buildMoodSelector(bool isDark) {
    final moods = ['😀', '😐', '😤', '🍿', '🛍️'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(left: 4, bottom: 12), child: Text('Spending Reflection', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: moods.map((m) => GestureDetector(
            onTap: () {
              HapticService.light();
              setState(() => _mood = m);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _mood == m ? const Color(0xFF6C63FF).withValues(alpha: 0.15) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: _mood == m ? const Color(0xFF6C63FF).withValues(alpha: 0.5) : Colors.transparent, width: 2),
              ),
              child: Text(m, style: const TextStyle(fontSize: 28)),
            ),
          )).toList(),
        ),
      ],
    );
  }
}
