import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The identity entered during registration, remembered **for preview mode
/// only**.
///
/// ## Why this exists
///
/// There is no Firebase project yet (`FIREBASE_SETUP.md`), so
/// `UserProfileService.isPreviewMode` is true and every account surface fell
/// back to one hard-coded stand-in profile — "Sara Ahmad". That made the side
/// drawer show a stranger's name to whoever had just registered.
///
/// This records what the user actually typed on the Register / Account Setup
/// screens so those surfaces can show *their* name, email and phone while the
/// backend is still missing.
///
/// ## What this is not
///
/// This is **not** authentication, and it is not user data in the Firestore
/// sense. It is a local echo of a form the user filled in on this device:
///
/// - It is only ever read when [UserProfileService.isPreviewMode] is true —
///   i.e. a debug build with no Firebase. The moment Firebase is configured,
///   `fetchProfile()` reads the real `users/{uid}` document and never consults
///   this again.
/// - It stores **no password and no credential**, and grants no access. A
///   name and email in local preferences is exactly what the user just typed
///   into a form on the same device.
/// - It is cleared on sign-out, so the next person to use the device does not
///   inherit the last one's details.
///
/// When real sign-in is built, delete this class along with the preview
/// account in `SECURITY.md` § 1b — both are scaffolding.
class PreviewIdentity {
  const PreviewIdentity._({this.name, this.email, this.phone});

  final String? name;
  final String? email;
  final String? phone;

  /// True once registration has recorded a name — the signal that the stored
  /// identity is worth showing instead of the built-in stand-in.
  bool get hasName => name != null && name!.trim().isNotEmpty;

  static const String _nameKey = 'preview_identity_name_v1';
  static const String _emailKey = 'preview_identity_email_v1';
  static const String _phoneKey = 'preview_identity_phone_v1';

  /// In-memory mirror, so a synchronous `bundledProfile()` can read the value
  /// without awaiting. Populated by [load] at startup and kept current by
  /// [save]; preferences remain the durable copy across restarts.
  static PreviewIdentity _current = const PreviewIdentity._();

  static PreviewIdentity get current => _current;

  /// Replaces the cached value in tests, so no test depends on the host
  /// machine's real preferences.
  @visibleForTesting
  static void debugSet({String? name, String? email, String? phone}) {
    _current = PreviewIdentity._(name: name, email: email, phone: phone);
  }

  /// Reads the stored identity into [current]. Call once during startup.
  ///
  /// A storage failure is not worth blocking launch for — it only means the
  /// built-in stand-in profile is shown, which is the old behaviour.
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _current = PreviewIdentity._(
        name: prefs.getString(_nameKey),
        email: prefs.getString(_emailKey),
        phone: prefs.getString(_phoneKey),
      );
    } on Exception catch (error) {
      debugPrint('Could not read the preview identity: $error');
    }
  }

  /// Records what the user entered. Null arguments leave the existing value
  /// alone, so Account Setup can add a phone without clearing the name.
  static Future<void> save({String? name, String? email, String? phone}) async {
    _current = PreviewIdentity._(
      name: name ?? _current.name,
      email: email ?? _current.email,
      phone: phone ?? _current.phone,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_current.name case final value?) {
        await prefs.setString(_nameKey, value);
      }
      if (_current.email case final value?) {
        await prefs.setString(_emailKey, value);
      }
      if (_current.phone case final value?) {
        await prefs.setString(_phoneKey, value);
      }
    } on Exception catch (error) {
      debugPrint('Could not save the preview identity: $error');
    }
  }

  /// Forgets the stored identity. Called on sign-out so the next user of this
  /// device does not see the previous one's details.
  static Future<void> clear() async {
    _current = const PreviewIdentity._();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_nameKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_phoneKey);
    } on Exception catch (error) {
      debugPrint('Could not clear the preview identity: $error');
    }
  }
}
