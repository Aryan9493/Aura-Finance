import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aura_finance/core/services/haptic_service.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, 
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false, 
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                blurRadius: 30,
                spreadRadius: -5,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF1E1E2E).withValues(alpha: 0.85),
                            const Color(0xFF0D0B1A).withValues(alpha: 0.95),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.9),
                            Colors.white.withValues(alpha: 1.0),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.grid_view_rounded, 'Home', isDark),
                    _buildNavItem(1, Icons.account_balance_wallet_rounded, 'Wallet', isDark),
                    _buildNavItem(2, Icons.analytics_rounded, 'Stats', isDark),
                    _buildNavItem(3, Icons.stars_rounded, 'Goals', isDark),
                    _buildNavItem(4, Icons.settings_suggest_rounded, 'Settings', isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = navigationShell.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticService.light();
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedScale(
            scale: isSelected ? 1.0 : 0.9,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutQuart,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 14 : 10,
                vertical: isSelected ? 10 : 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF00C9A7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4)
                  )
                ] : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: isSelected ? 22 : 24, // Slightly larger icons for unselected state for better visibility
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.25)),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
