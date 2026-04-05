import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:aura_finance/core/theme/theme_provider.dart';
import 'package:aura_finance/core/widgets/custom_card.dart';
import 'package:aura_finance/core/widgets/section_header.dart';
import 'package:aura_finance/core/services/biometric_service.dart';
import 'package:aura_finance/core/services/notification_service.dart';
import 'package:aura_finance/core/services/haptic_service.dart';
import 'package:aura_finance/features/dashboard/presentation/providers/budget_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Settings',
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
          SafeArea(
            child: AnimationLimiter(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    const SectionHeader(title: 'Preferences'),
                    const SizedBox(height: 16),
                    CustomCard(
                      borderRadius: 24,
                      child: Column(
                        children: [
                          _buildSwitchTile(
                            icon: Icons.dark_mode_rounded,
                            title: 'Dark Mode',
                            value: isDark,
                            onChanged: (_) {
                              HapticService.light();
                              ref.read(themeProvider.notifier).toggleTheme();
                            },
                          ),
                          _buildDivider(isDark),
                          _buildDropdownTile(
                            icon: Icons.currency_exchange_rounded,
                            title: 'Primary Currency',
                            value: '\$',
                            options: ['\$', '₹', '€', '£'],
                            onChanged: (val) {
                              HapticService.light();
                            },
                            isDark: isDark,
                          ),
                          _buildDivider(isDark),
                          _buildSwitchTile(
                            icon: Icons.notifications_active_rounded,
                            title: 'Alerts & Tips',
                            value: true,
                            onChanged: (val) {
                              HapticService.light();
                              if (val) _testNotifications(context);
                            },
                          ),
                          _buildDivider(isDark),
                          _buildBudgetTile(context, ref, isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Security'),
                    const SizedBox(height: 16),
                    CustomCard(
                      borderRadius: 24,
                      child: Column(
                        children: [
                          _buildActionTile(
                            icon: Icons.fingerprint_rounded,
                            title: 'Biometric Lock',
                            subtitle: 'FaceID or Fingerprint',
                            onTap: () {
                              HapticService.medium();
                              _testAppLock(context);
                            },
                          ),
                          _buildDivider(isDark),
                          _buildActionTile(
                            icon: Icons.password_rounded,
                            title: 'Change App PIN',
                            subtitle: '4-digit secure access',
                            onTap: () {
                              HapticService.light();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Data Control'),
                    const SizedBox(height: 16),
                    CustomCard(
                      borderRadius: 24,
                      child: Column(
                        children: [
                          _buildActionTile(
                            icon: Icons.cloud_download_rounded,
                            title: 'Export Portfolio',
                            subtitle: 'Download as JSON/CSV',
                            onTap: () {
                              HapticService.medium();
                              _handleExport(context);
                            },
                          ),
                          _buildDivider(isDark),
                          _buildActionTile(
                            icon: Icons.delete_forever_rounded,
                            title: 'Reset Local Data',
                            subtitle: 'This cannot be undone',
                            onTap: () {
                              HapticService.error();
                            },
                            titleColor: const Color(0xFFFF5E5E),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16)
                            ),
                            child: const Icon(Icons.bolt_rounded, size: 40, color: Color(0xFF6C63FF)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'AURA FINANCE',
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black26, 
                              fontSize: 12, 
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 1.2.4 (Beta)',
                            style: TextStyle(color: isDark ? Colors.white24 : Colors.black12, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF6C63FF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: const Color(0xFF00C9A7).withValues(alpha: 0.5),
        activeThumbColor: const Color(0xFF00C9A7),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF6C63FF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w800, fontSize: 14),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: onChanged,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (titleColor ?? const Color(0xFF6C63FF)).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: titleColor ?? const Color(0xFF6C63FF), size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: titleColor)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), height: 1),
    );
  }

  Widget _buildBudgetTile(BuildContext context, WidgetRef ref, bool isDark) {
    final budgetLimit = ref.watch(budgetLimitProvider);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF6C63FF).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF6C63FF), size: 20),
      ),
      title: const Text('Monthly Budget', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: Text(
        '\$${budgetLimit.toInt()}',
        style: TextStyle(color: const Color(0xFF6C63FF), fontWeight: FontWeight.w900, fontSize: 16),
      ),
      onTap: () {
        HapticService.light();
        _showBudgetDialog(context, ref);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  void _showBudgetDialog(BuildContext context, WidgetRef ref) {
    final currentLimit = ref.read(budgetLimitProvider);
    final controller = TextEditingController(text: currentLimit.toInt().toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: '\$ ',
            hintText: 'Enter limit',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final newLimit = double.tryParse(controller.text);
              if (newLimit != null) {
                ref.read(budgetLimitProvider.notifier).setLimit(newLimit);
                HapticService.success();
              }
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _testNotifications(BuildContext context) {
    NotificationService().showNotification(
      id: 1,
      title: 'Aura Intelligence Live',
      body: 'Your smart spending alerts are now active.',
    );
  }

  Future<void> _testAppLock(BuildContext context) async {
    final available = await BiometricService().isBiometricAvailable();
    if (!available) {
      if (context.mounted) {
        HapticService.error();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification not supported on this platform.')));
      }
      return;
    }
    final authed = await BiometricService().authenticate();
    if (authed && context.mounted) {
      HapticService.success();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Identity verified! App lock is active.'), 
          backgroundColor: Color(0xFF00C9A7),
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }

  Future<void> _handleExport(BuildContext context) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing secure data archive...'),
          backgroundColor: Color(0xFF6C63FF),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      HapticService.success();
      Share.share('Aura Finance Export: Secure Portfolio Snapshot');
    }
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
          left: -100,
          child: Container(
            width: screenWidth * 1.5,
            height: screenWidth * 1.5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6C63FF).withValues(alpha: isDark ? 0.06 : 0.03)),
          ),
        ),
        BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
      ],
    );
  }
}
