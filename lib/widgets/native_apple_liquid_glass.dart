import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// The iOS host bridge for Apple's system Liquid Glass material.
///
/// Availability is reported by native code so an iOS version string never has
/// to be parsed in Dart. All unsupported platforms keep their Flutter renderer.
class NativeAppleLiquidGlass {
  NativeAppleLiquidGlass._();

  static const MethodChannel _channel = MethodChannel(
    'kurdistan_paradise/native_liquid_glass',
  );

  static final Future<bool> availability = _readAvailability();

  static bool get canBeRequested =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static Future<bool> _readAvailability() async {
    if (!canBeRequested) return false;
    try {
      return await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

/// A non-interactive native UIKit layer. Flutter continues to own content,
/// semantics, focus, validation, and gestures above this physical glass.
class NativeAppleLiquidGlassSurface extends StatelessWidget {
  const NativeAppleLiquidGlassSurface({
    super.key,
    required this.child,
    required this.shapeName,
    required this.borderRadius,
    required this.isDark,
    required this.interactive,
    this.tint,
  });

  static const String viewType =
      'kurdistan_paradise/native_liquid_glass_surface';

  final Widget child;
  final String shapeName;
  final double borderRadius;
  final bool isDark;
  final bool interactive;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final tintColor = tint;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: UiKitView(
            viewType: viewType,
            hitTestBehavior: PlatformViewHitTestBehavior.transparent,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: <String, Object?>{
              'shape': shapeName,
              'borderRadius': borderRadius,
              'isDark': isDark,
              'interactive': interactive,
              if (tintColor != null) 'tintArgb': tintColor.toARGB32(),
            },
          ),
        ),
        child,
      ],
    );
  }
}
