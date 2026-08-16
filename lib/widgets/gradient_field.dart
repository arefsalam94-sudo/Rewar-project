import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Text input filled with the brand gradient, per `DESIGN light.md`:
///
/// > *Card Fill: Cards use a 20% opacity version of the brand gradient
/// > (#E1F4E5 to #187C64).*
/// > *Edge Definition: a subtle 1px white inner border (20% opacity).*
/// > *Backdrop Blur: every card and modal must have blur(20px).*
///
/// Translucent on purpose — the background photo reads through it, which is
/// what the Reset Password mockup shows.
///
/// Distinct from Login's frosted-white `_GlassField`, which stays as it is by
/// explicit decision. Corner radius is the design file's 12px for inputs, not
/// the rounder corners drawn in the mockup.
class GradientField extends StatelessWidget {
  const GradientField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.suffix,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.prefix,
    this.dark,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  /// Used by the picker-backed fields (date of birth, gender): the field
  /// shows the chosen value but is never typed into directly.
  final bool readOnly;
  final VoidCallback? onTap;

  /// Extra leading widget between the icon and the text, e.g. the country
  /// dialling-code selector on the phone field.
  final Widget? prefix;

  /// "Moonlit" treatment from `DESIGN dark.md`: emerald glass instead of the
  /// mint→green gradient, with Luminous Mint as the focus colour.
  final bool? dark;

  /// `DESIGN light.md` → Shapes → "Search Inputs: 12px corner radius".
  static const double radius = 14;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = dark ?? colorScheme.brightness == Brightness.dark;

    OutlineInputBorder borderWith(Color color, double width) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: color, width: width),
        );

    final tint =
        (isDark ? AppColors.darkGlassTintBase : AppColors.lightGlassTintBase)
            .withValues(
              alpha: isDark
                  ? AppColors.darkGlassTintOpacity
                  : AppColors.lightGlassTintOpacity,
            );
    final fill = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.alphaBlend(Colors.white.withValues(alpha: 0.16), tint),
        Color.alphaBlend(Colors.white.withValues(alpha: 0.03), tint),
      ],
    );

    final accent = isDark
        ? AppColors.darkSelectionAccent
        : AppColors.lightSelectionAccent;
    final edge = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.75);

    // Inset shadow colors per DESIGN_SYSTEM.md section 8.3 and theme tokens
    final insetShadowColor = isDark
        ? AppColors.darkGlassInnerShadowColor
        : AppColors.lightGlassInnerShadowColor;
    final insetShadowOpacity = isDark
        ? AppColors.darkGlassInnerShadowOpacity
        : AppColors.lightGlassInnerShadowOpacity;
    final insetHighlightColor = isDark
        ? AppColors.darkGlassInnerHighlightColor
        : AppColors.lightGlassInnerHighlightColor;
    final insetHighlightOpacity = isDark ? 0.08 : 0.08;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppColors.glassBlurMiddleL2,
          sigmaY: AppColors.glassBlurMiddleL2,
        ),
        child: _RecessedGlassField(
          borderRadius: radius,
          insetShadowColor: insetShadowColor,
          insetShadowOpacity: insetShadowOpacity,
          insetHighlightColor: insetHighlightColor,
          insetHighlightOpacity: insetHighlightOpacity,
          fill: fill,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            textInputAction: textInputAction,
            onFieldSubmitted: onFieldSubmitted,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            onTap: onTap,
            // Picker-backed fields shouldn't look like they take typing.
            showCursor: !readOnly,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                // DESIGN dark.md: placeholder text is white at 60-70% —
                // visibly dimmer than entered text, but still legible.
                color: isDark
                    ? AppColors.darkOnSurfaceSecondary.withValues(
                        alpha: AppColors.darkHintOpacity,
                      )
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                fontSize: 16,
              ),
              prefixIcon: (prefixIcon == null && prefix == null)
                  ? null
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 18,
                        end: 12,
                      ),
                      // The prefix cluster (icon plus, on the phone field, the
                      // country selector) has to share the row with the text
                      // being typed. Scaling it down when it doesn't fit keeps
                      // it whole and readable; without this it overflows on a
                      // narrow screen once the system font is enlarged.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (prefixIcon != null)
                              Icon(prefixIcon, color: accent, size: 22),
                            if (prefix != null) ...[
                              const SizedBox(width: 10),
                              prefix!,
                            ],
                          ],
                        ),
                      ),
                    ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
              suffixIcon: suffix,
              // Matches the 56dp field height used across the app.
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              enabledBorder: borderWith(edge, 1.2),
              border: borderWith(edge, 1.2),
              focusedBorder: borderWith(accent, 1.6),
              errorBorder: borderWith(colorScheme.error, 1.4),
              focusedErrorBorder: borderWith(colorScheme.error, 1.6),
              errorStyle: TextStyle(
                color: colorScheme.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps a recessed glass input field with inset shadows and highlights
/// to create the "recessed into the parent glass surface" effect per
/// DESIGN_SYSTEM.md section 8.
///
/// Uses custom painting to add inset shadows and inner highlights since
/// Flutter's built-in decoration does not support inset box-shadows.
class _RecessedGlassField extends StatelessWidget {
  const _RecessedGlassField({
    required this.child,
    required this.borderRadius,
    required this.insetShadowColor,
    required this.insetShadowOpacity,
    required this.insetHighlightColor,
    required this.insetHighlightOpacity,
    required this.fill,
  });

  final Widget child;
  final double borderRadius;
  final Color insetShadowColor;
  final double insetShadowOpacity;
  final Color insetHighlightColor;
  final double insetHighlightOpacity;
  final LinearGradient fill;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RecessedGlassFieldPainter(
        borderRadius: borderRadius,
        insetShadowColor: insetShadowColor,
        insetShadowOpacity: insetShadowOpacity,
        insetHighlightColor: insetHighlightColor,
        insetHighlightOpacity: insetHighlightOpacity,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: fill,
        ),
        child: child,
      ),
    );
  }
}

class _RecessedGlassFieldPainter extends CustomPainter {
  _RecessedGlassFieldPainter({
    required this.borderRadius,
    required this.insetShadowColor,
    required this.insetShadowOpacity,
    required this.insetHighlightColor,
    required this.insetHighlightOpacity,
  });

  final double borderRadius;
  final Color insetShadowColor;
  final double insetShadowOpacity;
  final Color insetHighlightColor;
  final double insetHighlightOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw recessed effect: inset shadow at bottom/left, highlight at top/right
    // Per DESIGN_SYSTEM.md 8.3: inset shadow offset 0,2 with blur 10-12, opacity 0.16-0.20

    final rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    // Inset shadow (bottom/inner edge) — creates depth
    final shadowPaint = Paint()
      ..color = insetShadowColor.withValues(alpha: insetShadowOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11);

    // Draw shadow offset from bottom-left
    canvas.saveLayer(rRect.outerRect, Paint());
    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRRect(rRect)
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
            Radius.circular(borderRadius - 2),
          ),
        ),
      shadowPaint,
    );
    canvas.restore();

    // Inner highlight (top/outer edge) — shows light reflection
    // Optional per DESIGN_SYSTEM.md but helps sell the effect
    final highlightPaint = Paint()
      ..color = insetHighlightColor.withValues(alpha: insetHighlightOpacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final highlightPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3),
          Radius.circular(borderRadius - 1.5),
        ),
      );

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(_RecessedGlassFieldPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.insetShadowOpacity != insetShadowOpacity ||
        oldDelegate.insetHighlightOpacity != insetHighlightOpacity;
  }
}
