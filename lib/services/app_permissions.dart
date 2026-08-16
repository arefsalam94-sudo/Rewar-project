import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Which OS permissions were granted after [AppPermissions.requestAll].
class PermissionResults {
  const PermissionResults({
    required this.camera,
    required this.photos,
    required this.location,
    required this.notifications,
  });

  final bool camera;
  final bool photos;
  final bool location;
  final bool notifications;

  /// The two this screen actually needs to do its job.
  bool get canPickImage => camera || photos;
}

/// Requests the app's OS permissions.
///
/// **Requested up front, on Account Setup open, by explicit decision.**
///
/// Both Apple and Google recommend requesting a permission at the moment it
/// is used, with visible context, and asking for permissions before their
/// feature is opened (the map and notifications here) is a known
/// App Store review-rejection risk and lowers grant rates for later prompts.
/// That trade-off was raised and the up-front approach was chosen anyway.
///
/// If review pushes back, the fix is small: stop calling [requestAll] on
/// screen open and call [requestForImageSource] at the point the user taps
/// upload instead — that method already exists for exactly that purpose.
class AppPermissions {
  AppPermissions._();

  /// Asks for camera, photos, location and notifications in sequence.
  ///
  /// Never throws — a denied or unavailable permission comes back as false so
  /// the screen can carry on rather than blocking the user.
  static Future<PermissionResults> requestAll() async {
    final camera = await _request(Permission.camera);
    final photos = await _requestPhotos();
    final location = await _request(Permission.locationWhenInUse);
    final notifications = await _request(Permission.notification);

    return PermissionResults(
      camera: camera,
      photos: photos,
      location: location,
      notifications: notifications,
    );
  }

  /// Requests only what a specific pick needs — the in-context alternative.
  static Future<bool> requestForImageSource({required bool fromCamera}) =>
      fromCamera ? _request(Permission.camera) : _requestPhotos();

  /// Requests notification permission when the user enables it in Settings.
  /// Disabling the app preference cannot revoke an OS permission.
  static Future<bool> requestNotifications() =>
      _request(Permission.notification);

  /// Android's storage/photos permission changed shape across versions, and
  /// `Permission.photos` maps to the modern one; older devices report it as
  /// permanently denied, so fall back to `storage` there.
  static Future<bool> _requestPhotos() async {
    if (await _request(Permission.photos)) return true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _request(Permission.storage);
    }
    return false;
  }

  static Future<bool> _request(Permission permission) async {
    try {
      final status = await permission.request();
      return status.isGranted || status.isLimited;
    } catch (e) {
      // Unsupported on this platform (e.g. running the app on desktop/web).
      debugPrint('Permission ${permission.value} unavailable: $e');
      return false;
    }
  }
}
