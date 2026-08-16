import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../theme/app_colors.dart';

/// Shapes supported by [AppLiquidGlass].
enum AppLiquidGlassShape { roundedRectangle, pill, circle }

/// App-owned quality vocabulary. Package types stay private to this file.
enum AppLiquidGlassQuality { standard, premium }

/// The single project entry point for shader-rendered liquid glass.
///
/// This deliberately delegates refraction, lensing, rim light, chromatic
/// aberration and specular lighting to `liquid_glass_widgets`. It contains no
/// BackdropFilter-based imitation.
class AppLiquidGlass extends StatelessWidget {
  const AppLiquidGlass({
    super.key,
    required this.child,
    this.shape = AppLiquidGlassShape.roundedRectangle,
    this.borderRadius = 28,
    this.padding = EdgeInsets.zero,
    this.dark,
    this.selected = false,
    this.tint,
    this.quality = AppLiquidGlassQuality.standard,
    this.interactive = false,
    this.onTap,
  });

  final Widget child;
  final AppLiquidGlassShape shape;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool? dark;
  final bool selected;
  final Color? tint;
  final AppLiquidGlassQuality quality;
  final bool interactive;
  final VoidCallback? onTap;

  LiquidShape get _liquidShape {
    return switch (shape) {
      AppLiquidGlassShape.roundedRectangle => LiquidRoundedRectangle(
        borderRadius: borderRadius,
      ),
      AppLiquidGlassShape.pill => const LiquidRoundedSuperellipse(
        borderRadius: 1000,
      ),
      AppLiquidGlassShape.circle => const LiquidOval(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = dark ?? Theme.of(context).brightness == Brightness.dark;
    final effectiveTint = tint ?? Colors.white;
    final effectiveQuality = quality == AppLiquidGlassQuality.premium
        ? GlassQuality.premium
        : GlassQuality.standard;

    final settings = LiquidGlassSettings(
      // A low-alpha neutral tint keeps the photographed backdrop clearly
      // visible. The package shader supplies the optical depth, not a fill.
      glassColor: effectiveTint.withValues(alpha: isDark ? 0.028 : 0.045),
      thickness: quality == AppLiquidGlassQuality.premium ? 30 : 22,
      blur: quality == AppLiquidGlassQuality.premium ? 2.2 : 1.6,
      chromaticAberration: quality == AppLiquidGlassQuality.premium
          ? 0.018
          : 0.010,
      lightAngle: -math.pi / 3.6,
      lightIntensity: isDark ? 0.92 : 0.82,
      ambientStrength: isDark ? 0.16 : 0.12,
      ambientRim: isDark ? 0.22 : 0.17,
      fresnelStrength: 1.22,
      refractiveIndex: quality == AppLiquidGlassQuality.premium ? 1.18 : 1.14,
      saturation: 1.12,
      glowIntensity: interactive ? 0.28 : 0.12,
      specularSharpness: GlassSpecularSharpness.sharp,
      shadowElevation: isDark ? 0.55 : 0.9,
    );

    Widget content = Padding(padding: padding, child: child);
    if (selected) {
      content = CustomPaint(
        foregroundPainter: _SelectionStrokePainter(
          shape: shape,
          radius: borderRadius,
          color: AppColors.selectionAccent(
            context,
          ).withValues(alpha: AppColors.selectionStrokeOpacity),
          width: AppColors.selectionStrokeWidth,
        ),
        child: content,
      );
    }

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: _materialShape,
          child: content,
        ),
      );
    }

    return AdaptiveGlass(
      shape: _liquidShape,
      settings: settings,
      quality: effectiveQuality,
      useOwnLayer: true,
      clipBehavior: Clip.antiAlias,
      allowElevation: interactive || onTap != null,
      isInteractive: interactive || onTap != null,
      glowIntensity: interactive || onTap != null ? 0.18 : 0,
      child: content,
    );
  }

  ShapeBorder get _materialShape {
    return switch (shape) {
      AppLiquidGlassShape.circle => const CircleBorder(),
      AppLiquidGlassShape.pill => const StadiumBorder(),
      AppLiquidGlassShape.roundedRectangle => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    };
  }
}

/// Only paints the theme accent that communicates selection. The liquid-glass
/// rim itself remains entirely shader-rendered by the package.
class _SelectionStrokePainter extends CustomPainter {
  const _SelectionStrokePainter({
    required this.shape,
    required this.radius,
    required this.color,
    required this.width,
  });

  final AppLiquidGlassShape shape;
  final double radius;
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final rect = (Offset.zero & size).deflate(width / 2);
    switch (shape) {
      case AppLiquidGlassShape.circle:
        canvas.drawOval(rect, paint);
      case AppLiquidGlassShape.pill:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(size.shortestSide / 2)),
          paint,
        );
      case AppLiquidGlassShape.roundedRectangle:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(radius)),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(_SelectionStrokePainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.radius != radius ||
      oldDelegate.color != color ||
      oldDelegate.width != width;
}
