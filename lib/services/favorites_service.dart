import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/featured_item.dart';
import 'firebase_bootstrap.dart';

/// Reads and toggles the signed-in user's `favorites`.
///
/// Guests are not handled here at all — the home screen prompts them to sign
/// in instead. That is deliberate: `favorites` documents are keyed by
/// `userId` and the security rule requires `request.auth.uid` to match, so
/// there is no such thing as an anonymous favorite.
class FavoritesService {
  FavoritesService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestoreOverride = firestore,
      _authOverride = auth;

  final FirebaseFirestore? _firestoreOverride;
  final FirebaseAuth? _authOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  static const String collection = 'favorites';

  /// Cap on how many of the user's favorites the home screen pulls. The
  /// carousel only ever needs to know about a handful of items; the
  /// Favorites screen (Phase 8) will paginate properly.
  static const int _fetchLimit = 100;

  static bool get isPreviewMode => kDebugMode && !FirebaseBootstrap.isReady;

  String? get _uid {
    if (!FirebaseBootstrap.isReady) return null;
    return _auth.currentUser?.uid;
  }

  /// A deterministic id, so favoriting is a plain set/delete on a known
  /// document rather than a query-then-write. That also makes a double-tap
  /// idempotent instead of creating two rows for the same place.
  static String documentId({
    required String uid,
    required FeaturedType itemType,
    required String itemId,
  }) => '${uid}_${itemType.id}_$itemId';

  /// The ids (`itemId`) the current user has already favorited.
  ///
  /// Returns an empty set for guests and in preview mode — nothing is stored
  /// in either case, so nothing can be already-favorited.
  Future<Set<String>> fetchFavoriteItemIds() async {
    if (isPreviewMode) return <String>{};
    final uid = _uid;
    if (uid == null) return <String>{};

    final snapshot = await _firestore
        .collection(collection)
        .where('userId', isEqualTo: uid)
        .limit(_fetchLimit)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['itemId'])
        .whereType<String>()
        .toSet();
  }

  /// Adds or removes a favorite. Returns the new state (true = favorited).
  ///
  /// Throws [StateError] if called with no signed-in user — the caller is
  /// expected to have shown the sign-in prompt already.
  Future<bool> toggle({
    required FeaturedType itemType,
    required String itemId,
    required bool currentlyFavorite,
  }) async {
    if (isPreviewMode) {
      debugPrint(
        'PREVIEW MODE: favorite not persisted. '
        'Finish FIREBASE_SETUP.md for the real write.',
      );
      return !currentlyFavorite;
    }

    final uid = _uid;
    if (uid == null) {
      throw StateError('Cannot change favorites without a signed-in user');
    }

    final document = _firestore
        .collection(collection)
        .doc(documentId(uid: uid, itemType: itemType, itemId: itemId));

    if (currentlyFavorite) {
      await document.delete();
      return false;
    }

    await document.set({
      'userId': uid,
      'itemType': itemType.id,
      'itemId': itemId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'source': 'manual',
    });
    return true;
  }
}
