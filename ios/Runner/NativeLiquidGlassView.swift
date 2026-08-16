import Flutter
import UIKit

final class NativeLiquidGlassViewFactory: NSObject, FlutterPlatformViewFactory {
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    NativeLiquidGlassPlatformView(frame: frame, arguments: args)
  }
}

private final class NativeLiquidGlassPlatformView: NSObject, FlutterPlatformView {
  private let rootView: UIView

  init(frame: CGRect, arguments: Any?) {
    let root = UIView(frame: frame)
    root.backgroundColor = .clear
    root.isOpaque = false
    rootView = root
    super.init()

    guard #available(iOS 26.0, *),
          let parameters = arguments as? [String: Any] else {
      return
    }

    let glassEffect = UIGlassEffect()
    glassEffect.isInteractive = parameters["interactive"] as? Bool ?? false
    if let argb = parameters["tintArgb"] as? NSNumber {
      glassEffect.tintColor = Self.color(fromArgb: argb.uint64Value)
    }

    let effectView = UIVisualEffectView(effect: glassEffect)
    effectView.frame = root.bounds
    effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    effectView.backgroundColor = .clear
    effectView.isOpaque = false

    let shape = parameters["shape"] as? String ?? "roundedRectangle"
    let radius = (parameters["borderRadius"] as? NSNumber)?.doubleValue ?? 28
    effectView.cornerConfiguration = shape == "roundedRectangle"
      ? .corners(radius: .fixed(radius))
      : .capsule()

    root.overrideUserInterfaceStyle = (parameters["isDark"] as? Bool ?? false)
      ? .dark
      : .light
    root.addSubview(effectView)
  }

  func view() -> UIView {
    rootView
  }

  @available(iOS 26.0, *)
  private static func color(fromArgb argb: UInt64) -> UIColor {
    let alpha = CGFloat((argb >> 24) & 0xff) / 255
    let red = CGFloat((argb >> 16) & 0xff) / 255
    let green = CGFloat((argb >> 8) & 0xff) / 255
    let blue = CGFloat(argb & 0xff) / 255
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
}
