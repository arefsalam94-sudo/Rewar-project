import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum GlassFill { sheen, brandGradient }

/// Shared liquid-glass surface used by auth cards, secondary buttons, sheets,
/// and selectable surfaces.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = EdgeInsets.zero,
    this.borderColor,
    this.borderWidth,
    this.dark,
    this.fill = GlassFill.sheen,
    this.elevated = false,
    this.lightFillOpacity,
    this.darkFillOpacity,
    this.lightBorderOpacity,
    this.darkBorderOpacity,
    this.lightBlurSigma,
    this.darkBlurSigma,
  });

  final bool elevated;
  final double? lightFillOpacity;
  final double? darkFillOpacity;
  final double? lightBorderOpacity;
  final double? darkBorderOpacity;
  final double? lightBlurSigma;
  final double? darkBlurSigma;
  final GlassFill fill;
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final double? borderWidth;
  final bool? dark;

  @override
  Widget build(BuildContext context) {
    final isDark = dark ?? Theme.of(context).brightness == Brightness.dark;
    final blur = isDark
        ? (darkBlurSigma ??
              (elevated ? AppColors.glassBlurTopL3 : AppColors.glassBlurBaseL1))
        : (lightBlurSigma ??
              (elevated
                  ? AppColors.glassBlurTopL3
                  : AppColors.glassBlurBaseL1));
    final tintColor = isDark
        ? AppColors.darkGlassTintBase
        : AppColors.lightGlassTintBase;
    final tintOpacity =
        (isDark
            ? (darkFillOpacity ?? AppColors.darkGlassTintOpacity)
            : (lightFillOpacity ?? AppColors.lightGlassTintOpacity)) +
        (elevated ? 0.02 : 0.0);
    final rimOpacity = isDark
        ? (darkBorderOpacity ?? 0.55)
        : (lightBorderOpacity ?? 0.55);
    final shadowColor = isDark
        ? AppColors.darkGlassShadowColor
        : AppColors.lightGlassShadowColor;
    final shadowOpacity = isDark
        ? AppColors.darkGlassShadowOpacity
        : AppColors.lightGlassShadowOpacity;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: shadowOpacity),
            offset: const Offset(0, AppColors.glassFloatingShadowOffsetY),
            blurRadius: AppColors.glassFloatingShadowBlurRadius,
            spreadRadius: AppColors.glassFloatingShadowSpreadRadius,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: CustomPaint(
            foregroundPainter: _GlassSurfaceOpticalPainter(
              borderRadius: borderRadius,
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: tintColor.withValues(alpha: tintOpacity),
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(
                      alpha: AppColors.glassSheenTopOpacity,
                    ),
                    Colors.white.withValues(
                      alpha: AppColors.glassSheenBottomOpacity,
                    ),
                  ],
                ),
                border: Border.all(
                  color:
                      borderColor ?? Colors.white.withValues(alpha: rimOpacity),
                  width: borderWidth ?? 1.2,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSurfaceOpticalPainter extends CustomPainter {
  _GlassSurfaceOpticalPainter({required this.borderRadius});

  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final cornerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.26)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(
      Offset(borderRadius * 0.42, borderRadius * 0.42),
      borderRadius * 0.32,
      cornerPaint,
    );
    canvas.drawCircle(
      Offset(size.width - borderRadius * 0.42, borderRadius * 0.42),
      borderRadius * 0.32,
      cornerPaint,
    );

    final innerGlowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3),
        Radius.circular(borderRadius - 1),
      ),
      innerGlowPaint,
    );
  }

  @override
  bool shouldRepaint(_GlassSurfaceOpticalPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius;
  }
}
