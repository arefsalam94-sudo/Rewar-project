import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Initializes Firebase once at startup, without letting a missing/incomplete
/// Firebase configuration crash the whole app.
///
/// Until the Firebase project is created and `google-services.json` /
/// `GoogleService-Info.plist` are added (see `FIREBASE_SETUP.md`),
/// [initializeApp] throws. We catch that, record it in [isReady], and let the
/// app keep running so the UI is still viewable — every screen that needs the
/// backend checks [isReady] and shows a real error instead of pretending.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _ready = false;
  static Object? _error;

  /// True once Firebase initialized successfully.
  static bool get isReady => _ready;

  /// Why initialization failed, if it did (for logging, not for the user).
  static Object? get error => _error;

  static Future<void> ensureInitialized() async {
    if (_ready) return;
    try {
      await Firebase.initializeApp();
      _ready = true;
      _error = null;
    } catch (e, s) {
      _ready = false;
      _error = e;
      debugPrint(
        'Firebase not initialized — backend features are unavailable.\n'
        'Finish the steps in FIREBASE_SETUP.md.\n$e\n$s',
      );
    }
  }
}
