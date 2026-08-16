import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import 'app_liquid_glass.dart';

/// A shared shader-glass field with a real inset-depth overlay.
///
/// Light and dark modes use the same geometry. Only their shadow/highlight
/// colors vary, and focus/error strokes are painted above the depth layer.
class AppRecessedGlassField extends StatelessWidget {
  const AppRecessedGlassField({
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
    this.nativeIOS26 = false,
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
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? prefix;
  final bool? dark;
  final bool nativeIOS26;

  static const double radius = 14;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = dark ?? colorScheme.brightness == Brightness.dark;
    final accent = isDark
        ? AppColors.darkSelectionAccent
        : AppColors.lightSelectionAccent;

    OutlineInputBorder borderWith(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return AppLiquidGlass(
      borderRadius: radius,
      dark: isDark,
      quality: AppLiquidGlassQuality.standard,
      tint: isDark ? const Color(0xFF061512) : Colors.white,
      nativeIOS26: nativeIOS26,
      child: CustomPaint(
        painter: _InsetDepthPainter(
          borderRadius: radius,
          shadowColor: isDark
              ? AppColors.darkGlassInnerShadowColor
              : AppColors.lightGlassInnerShadowColor,
          shadowOpacity: isDark
              ? AppColors.darkGlassInnerShadowOpacity
              : AppColors.lightGlassInnerShadowOpacity,
          highlightColor: isDark
              ? AppColors.darkGlassInnerHighlightColor
              : AppColors.lightGlassInnerHighlightColor,
        ),
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
          showCursor: !readOnly,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
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
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            enabledBorder: borderWith(Colors.transparent, 0),
            border: borderWith(Colors.transparent, 0),
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
    );
  }
}

/// Paints opposing clipped, blurred edge bands to create physical inset depth.
class _InsetDepthPainter extends CustomPainter {
  const _InsetDepthPainter({
    required this.borderRadius,
    required this.shadowColor,
    required this.shadowOpacity,
    required this.highlightColor,
  });

  final double borderRadius;
  final Color shadowColor;
  final double shadowOpacity;
  final Color highlightColor;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      bounds,
      Radius.circular(borderRadius),
    );
    canvas.save();
    canvas.clipRRect(rrect);

    final upperDepth = Paint()
      ..color = shadowColor.withValues(alpha: shadowOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawRRect(rrect.deflate(2).shift(const Offset(0, -3)), upperDepth);

    final oppositeHighlight = Paint()
      ..color = highlightColor.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawRRect(
      rrect.deflate(2).shift(const Offset(0, 2.5)),
      oppositeHighlight,
    );

    final innerLip = Paint()
      ..color = shadowColor.withValues(alpha: shadowOpacity * 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(rrect.deflate(1.2), innerLip);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InsetDepthPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.shadowColor != shadowColor ||
      oldDelegate.shadowOpacity != shadowOpacity ||
      oldDelegate.highlightColor != highlightColor;
}
