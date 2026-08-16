import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Prototype optical liquid glass surface for the Language/Login/Register pass.
///
/// It clips all effects to the component bounds, applies a subtle matrix
/// backdrop filter only around the rim, and paints lighting over the glass
/// without touching child text/icons.
class LiquidGlassSurfaceV2 extends StatelessWidget {
  const LiquidGlassSurfaceV2({
    super.key,
    required this.child,
    this.borderRadius = 28,
    this.padding = EdgeInsets.zero,
    this.dark,
    this.selected = false,
    this.elevated = false,
    this.borderColor,
    this.borderWidth,
    this.lightTintOpacity,
    this.darkTintOpacity,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool? dark;
  final bool selected;
  final bool elevated;
  final Color? borderColor;
  final double? borderWidth;
  final double? lightTintOpacity;
  final double? darkTintOpacity;

  @override
  Widget build(BuildContext context) {
    final isDark = dark ?? Theme.of(context).brightness == Brightness.dark;
    final tint = isDark
        ? AppColors.darkGlassTintBase
        : AppColors.lightGlassTintBase;
    final tintOpacity = selected
        ? AppColors.selectionTintOpacity
        : (isDark
              ? (darkTintOpacity ?? AppColors.darkGlassTintOpacity)
              : (lightTintOpacity ?? AppColors.lightGlassTintOpacity));
    final accent = AppColors.selectionAccent(
      context,
    ).withValues(alpha: AppColors.selectionStrokeOpacity);
    final shadowColor = isDark
        ? AppColors.darkGlassShadowColor
        : AppColors.lightGlassShadowColor;
    final shadowOpacity = isDark
        ? AppColors.darkGlassShadowOpacity
        : AppColors.lightGlassShadowOpacity;
    final radius = BorderRadius.circular(borderRadius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: shadowOpacity),
            offset: const Offset(0, AppColors.glassFloatingShadowOffsetY),
            blurRadius: AppColors.glassFloatingShadowBlurRadius,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: elevated
                ? AppColors.glassBlurMiddleL2
                : AppColors.glassBlurBaseL1,
            sigmaY: elevated
                ? AppColors.glassBlurMiddleL2
                : AppColors.glassBlurBaseL1,
          ),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: tintOpacity),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.045),
                        Colors.white.withValues(alpha: 0.012),
                      ],
                      stops: const [0.0, 0.46, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned.fill(child: _RimLensLayer(borderRadius: borderRadius)),
              Positioned.fill(
                child: CustomPaint(
                  painter: _LiquidGlassPainter(
                    borderRadius: borderRadius,
                    selectedStroke: selected ? accent : borderColor,
                    selectedStrokeWidth: selected
                        ? AppColors.selectionStrokeWidth
                        : borderWidth,
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _RimLensLayer extends StatelessWidget {
  const _RimLensLayer({required this.borderRadius});

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final matrix = Matrix4.identity()
      ..setEntry(0, 0, 1.018)
      ..setEntry(1, 1, 1.018)
      ..setEntry(0, 3, -0.7)
      ..setEntry(1, 3, -0.9);

    return ClipPath(
      clipper: _RimClipper(borderRadius: borderRadius, rimWidth: 12),
      child: BackdropFilter(
        filter: ImageFilter.matrix(
          matrix.storage,
          filterQuality: FilterQuality.high,
        ),
        child: const ColoredBox(color: Colors.transparent),
      ),
    );
  }
}

class _RimClipper extends CustomClipper<Path> {
  const _RimClipper({required this.borderRadius, required this.rimWidth});

  final double borderRadius;
  final double rimWidth;

  @override
  Path getClip(Size size) {
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rimWidth,
        rimWidth,
        size.width - rimWidth * 2,
        size.height - rimWidth * 2,
      ),
      Radius.circular((borderRadius - rimWidth).clamp(0, borderRadius)),
    );

    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(outer)
      ..addRRect(inner);
  }

  @override
  bool shouldReclip(_RimClipper oldClipper) {
    return oldClipper.borderRadius != borderRadius ||
        oldClipper.rimWidth != rimWidth;
  }
}

class _LiquidGlassPainter extends CustomPainter {
  const _LiquidGlassPainter({
    required this.borderRadius,
    this.selectedStroke,
    this.selectedStrokeWidth,
  });

  final double borderRadius;
  final Color? selectedStroke;
  final double? selectedStrokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xDDFFFFFF), Color(0x66FFFFFF), Color(0x18FFFFFF)],
        stops: [0.0, 0.46, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect.deflate(0.6), rimPaint);

    final innerGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawRRect(rrect.deflate(2.2), innerGlowPaint);

    final cornerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(borderRadius * 0.55, borderRadius * 0.42),
        width: borderRadius * 1.3,
        height: borderRadius * 0.8,
      ),
      cornerPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width - borderRadius * 0.5, borderRadius * 0.42),
        width: borderRadius,
        height: borderRadius * 0.62,
      ),
      cornerPaint..color = Colors.white.withValues(alpha: 0.18),
    );

    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.055),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.62));
    final sheenPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height * 0.62),
          Radius.circular(borderRadius),
        ),
      );
    canvas.drawPath(sheenPath, sheenPaint);

    if (selectedStroke != null) {
      final selectedPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selectedStrokeWidth ?? AppColors.selectionStrokeWidth
        ..color = selectedStroke!;
      canvas.drawRRect(rrect.deflate(1), selectedPaint);
    }
  }

  @override
  bool shouldRepaint(_LiquidGlassPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.selectedStroke != selectedStroke ||
        oldDelegate.selectedStrokeWidth != selectedStrokeWidth;
  }
}
