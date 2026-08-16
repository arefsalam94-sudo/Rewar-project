import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/legal_document.dart';
import 'firebase_bootstrap.dart';

/// Loads versioned legal text from `legal_documents`.
///
/// Public read, admin-only write (see `firestore.rules`) — a user has to be
/// able to read the Terms before they have an account.
///
/// Before Firebase exists, preview mode serves the bundled copy from
/// [bundledAsset]. That asset is the **single source of truth**: it is the
/// same file `tool/seed_legal_documents.js` reads and writes to Firestore, so
/// the wording the app shows and the wording that gets seeded cannot drift.
/// Preview mode also parses it with the very same [LegalDocument.fromMap] used
/// on live Firestore data, so a malformed document fails in development rather
/// than in production.
class LegalDocumentService {
  LegalDocumentService({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  static const String collection = 'legal_documents';

  /// The bundled copy of every document in [collection], keyed by document id.
  static const String bundledAsset = 'assets/legal/legal_documents.json';

  /// Consent is recorded against this document's `version` in
  /// `users.termsVersion`. Matches `PolicyTopic.terms.docId`, which a test
  /// pins — two different Terms documents would let a user accept one wording
  /// and read another.
  static const String termsDocId = 'terms_of_service';

  /// The document behind the Policy hub's "Privacy Policy" row. Matches
  /// `PolicyTopic.privacy.docId`, which a test pins.
  static const String privacyDocId = 'privacy_policy';

  static bool get isPreviewMode => kDebugMode && !FirebaseBootstrap.isReady;

  /// Fetches the Terms of Service for [languageCode].
  Future<LegalDocument> fetchTerms(String languageCode) =>
      fetchDocument(termsDocId, languageCode);

  /// Fetches the Privacy Policy for [languageCode].
  Future<LegalDocument> fetchPrivacyPolicy(String languageCode) =>
      fetchDocument(privacyDocId, languageCode);

  /// Fetches `legal_documents/[docId]` for [languageCode].
  ///
  /// Throws on failure rather than silently falling back to the bundled text:
  /// consent must be recorded against the *current* wording, so the screen
  /// shows an error with a retry instead of quietly showing something else.
  /// The one exception is preview mode, where Firebase doesn't exist yet.
  Future<LegalDocument> fetchDocument(String docId, String languageCode) async {
    if (isPreviewMode) {
      debugPrint(
        'PREVIEW MODE: serving the bundled copy of $docId. '
        'Seed $collection/$docId in Firestore for the real one.',
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return bundled(docId, languageCode);
    }
    if (!FirebaseBootstrap.isReady) {
      throw StateError('Firebase is not configured — see FIREBASE_SETUP.md');
    }

    final snapshot = await _firestore.collection(collection).doc(docId).get();
    if (!snapshot.exists) {
      throw StateError('$collection/$docId has not been seeded');
    }
    final document = LegalDocument.fromMap(snapshot.data(), languageCode);
    if (document == null) {
      throw StateError('$collection/$docId is malformed');
    }
    return document;
  }

  /// The bundled copy of [docId] in [languageCode], read from [bundledAsset].
  ///
  /// Throws if the id is unknown or the entry is malformed — a silent empty
  /// legal page is worse than a loud failure, and this only ever runs in
  /// preview mode, where a developer is watching.
  static Future<LegalDocument> bundled(
    String docId,
    String languageCode,
  ) async {
    final all = await bundledDocuments();
    final raw = all[docId];
    if (raw == null) {
      throw StateError(
        '$docId is not in $bundledAsset — add it there, not in Dart, so the '
        'seed script picks it up too.',
      );
    }
    final document = LegalDocument.fromMap(raw, languageCode);
    if (document == null) {
      throw StateError('$docId in $bundledAsset is malformed');
    }
    return document;
  }

  /// The `version` of the bundled [docId] — what consent is recorded against
  /// while preview mode is serving the bundled text.
  static Future<int> bundledVersionOf(String docId) async =>
      (await bundled(docId, 'en')).version;

  /// Every bundled document, keyed by id, with the `_comment` block stripped.
  ///
  /// Cached after the first read — the asset is a few hundred KB of text and
  /// nothing in it changes at runtime.
  static Future<Map<String, Map<String, dynamic>>> bundledDocuments() async {
    final cached = _cache;
    if (cached != null) return cached;

    // `rootBundle.loadString` hands UTF-8 decoding to a background isolate
    // once the file passes 50KB, and this asset is well past that. That
    // isolate's result never arrives under a widget test's fake clock, so the
    // screen would hang on its spinner forever in every test. Loading the
    // bytes and decoding them here keeps the whole thing on one isolate.
    final bytes = await rootBundle.load(bundledAsset);
    final decoded =
        jsonDecode(
              utf8.decode(
                bytes.buffer.asUint8List(
                  bytes.offsetInBytes,
                  bytes.lengthInBytes,
                ),
              ),
            )
            as Map<String, dynamic>;
    final documents = <String, Map<String, dynamic>>{
      for (final entry in decoded.entries)
        // `_comment` documents the file for whoever edits it next; it is not
        // a legal document.
        if (!entry.key.startsWith('_') && entry.value is Map)
          entry.key: Map<String, dynamic>.from(entry.value as Map),
    };
    return _cache = documents;
  }

  static Map<String, Map<String, dynamic>>? _cache;

  /// Drops the cached asset. Only useful in tests.
  @visibleForTesting
  static void resetCache() => _cache = null;
}
