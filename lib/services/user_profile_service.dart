import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import 'firebase_bootstrap.dart';
import 'preview_identity.dart';

/// The currencies offered by account preferences.
///
/// Matches the `currency` values already used on `bookings` in
/// `DATA_MODEL.md` (`"USD"` | `"IQD"`).
enum AppCurrency {
  usd,
  iqd,
  eur;

  String get code => switch (this) {
    AppCurrency.usd => 'USD',
    AppCurrency.iqd => 'IQD',
    AppCurrency.eur => 'EUR',
  };

  static AppCurrency fromCode(String? code) => switch (code) {
    'IQD' => AppCurrency.iqd,
    'EUR' => AppCurrency.eur,
    _ => AppCurrency.usd,
  };
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImageUrl,
    required this.currency,
    this.hasPaymentMethod = false,
  });

  /// The user's display name — with their email, the whole of their identity
  /// in this app. There is deliberately no username: it was removed because it
  /// duplicated the display name without adding anything the user needed.
  final String name;
  final String? email;
  final String? phone;
  final String? profileImageUrl;
  final AppCurrency currency;

  /// Server-owned summary used only to choose between the empty payment
  /// state and the future saved-method state. No card details live here.
  final bool hasPaymentMethod;
}

/// Reads and updates the signed-in user's `users/{uid}` document for the
/// side drawer's profile header and Currency row.
///
/// Guests are not handled here — the drawer shows a sign-in prompt instead,
/// the same pattern [FavoritesService] uses for the Home screen's heart.
class UserProfileService {
  UserProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
  }) : _firestoreOverride = firestore,
       _authOverride = auth,
       _functionsOverride = functions;

  final FirebaseFirestore? _firestoreOverride;
  final FirebaseAuth? _authOverride;
  final FirebaseFunctions? _functionsOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseFunctions get _functions =>
      _functionsOverride ?? FirebaseFunctions.instance;

  static bool get isPreviewMode => kDebugMode && !FirebaseBootstrap.isReady;

  /// Stand-in profile so account surfaces can be reviewed before Firebase
  /// exists.
  ///
  /// Prefers whatever the user actually entered at registration
  /// ([PreviewIdentity]) and only falls back to the Settings reference
  /// screenshot's values when nobody has registered on this device. Without
  /// that preference the side drawer greeted every user as "Sara Ahmad",
  /// which is the bug this fixes.
  static UserProfile bundledProfile() {
    final identity = PreviewIdentity.current;
    if (!identity.hasName) return _referenceProfile;

    return UserProfile(
      name: identity.name!,
      email: identity.email ?? _referenceProfile.email,
      phone: identity.phone ?? _referenceProfile.phone,
      profileImageUrl: null,
      currency: AppCurrency.usd,
      hasPaymentMethod: false,
    );
  }

  /// The design-review stand-in, used only before anyone has registered.
  static const UserProfile _referenceProfile = UserProfile(
    name: 'Sara Ahmad',
    email: 'Saraahmad@gmail.com',
    phone: '+964 750 777 7777',
    profileImageUrl: null,
    currency: AppCurrency.usd,
    hasPaymentMethod: false,
  );

  /// Returns null for a guest (no signed-in user) — the caller is expected
  /// to have already checked [FirebaseBootstrap] / guest state before
  /// calling this for a real profile screen.
  Future<UserProfile?> fetchProfile() async {
    if (isPreviewMode) return bundledProfile();

    final signedIn = _auth.currentUser;
    if (signedIn == null) return null;
    // Held in a separate non-nullable local: reassigning `user` below (after
    // `reload()`) would otherwise discard the null promotion from this check,
    // and every field access after it stops compiling.
    var user = signedIn;

    try {
      try {
        await user.reload();
        user = _auth.currentUser ?? user;
        await _functions
            .httpsCallable('syncAuthIdentity')
            .call<Map<Object?, Object?>>();
      } catch (error) {
        debugPrint('Could not sync verified Auth identity: $error');
      }
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      final name = data?['name'] as String?;
      return UserProfile(
        name: (name != null && name.trim().isNotEmpty)
            ? name
            : (user.displayName ?? ''),
        email: user.email ?? data?['email'] as String?,
        phone: user.phoneNumber ?? data?['phone'] as String?,
        profileImageUrl: data?['profileImageUrl'] as String? ?? user.photoURL,
        currency: AppCurrency.fromCode(data?['preferredCurrency'] as String?),
        hasPaymentMethod: data?['hasPaymentMethod'] == true,
      );
    } catch (e) {
      // Non-fatal: Firebase Auth alone still has enough to draw a usable
      // header, better than leaving the drawer's profile section blank.
      debugPrint('Could not load the user profile: $e');
      return UserProfile(
        name: user.displayName ?? '',
        email: user.email,
        phone: user.phoneNumber,
        profileImageUrl: user.photoURL,
        currency: AppCurrency.usd,
        hasPaymentMethod: false,
      );
    }
  }

  /// `preferredCurrency` is on the client-writable allow-list in
  /// `firestore.rules`, alongside `preferredLanguage`.
  Future<void> updateCurrency(AppCurrency currency) async {
    if (isPreviewMode) {
      debugPrint(
        'PREVIEW MODE: pretending to set currency to ${currency.code}.',
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Cannot set a currency without a signed-in user');
    }

    await _firestore.collection('users').doc(uid).set({
      'preferredCurrency': currency.code,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateLanguage(String languageCode) async {
    if (isPreviewMode) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Cannot set a language without a signed-in user');
    }
    await _firestore.collection('users').doc(uid).set({
      'preferredLanguage': languageCode,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
