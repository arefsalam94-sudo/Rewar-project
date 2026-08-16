import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_liquid_glass.dart';

/// Two-position sliding switch between light and dark mode.
class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({
    super.key,
    required this.isDark,
    required this.onChanged,
    this.compact = false,
    this.nativeIOS26 = false,
  });

  final bool isDark;
  final ValueChanged<bool> onChanged;
  final bool compact;
  final bool nativeIOS26;

  static const double _thumbInset = 4;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 82.0 : 96.0;
    final height = compact ? 40.0 : 48.0;
    final thumbSize = height - (_thumbInset * 2);
    final thumbColor = isDark
        ? AppColors.luminousMint
        : Colors.white.withValues(alpha: 0.95);
    final activeIcon = isDark ? AppColors.darkOnPrimary : AppColors.actionNavy;
    final inactiveIcon = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : AppColors.actionNavy.withValues(alpha: 0.45);

    return Semantics(
      container: true,
      toggled: isDark,
      label: isDark ? 'Dark mode' : 'Light mode',
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: width, minHeight: 48),
        child: Center(
          child: AppLiquidGlass(
            shape: AppLiquidGlassShape.pill,
            dark: isDark,
            quality: AppLiquidGlassQuality.standard,
            interactive: true,
            nativeIOS26: nativeIOS26,
            onTap: () => onChanged(!isDark),
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: isDark
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _thumbInset,
                      ),
                      child: Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          color: thumbColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(
                          child: Icon(
                            Icons.light_mode,
                            size: compact ? 19 : 22,
                            color: isDark ? inactiveIcon : activeIcon,
                          ),
                        ),
                        Expanded(
                          child: Icon(
                            Icons.dark_mode,
                            size: compact ? 18 : 20,
                            color: isDark ? activeIcon : inactiveIcon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
