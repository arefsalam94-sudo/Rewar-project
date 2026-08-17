import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'firebase_bootstrap.dart';
import 'user_profile_service.dart';

/// A snapshot of exchange rates, all expressed against one [base] currency.
///
/// Deliberately a value object with no I/O: conversion is pure arithmetic, and
/// a screen should be able to test it without a database.
@immutable
class CurrencyRates {
  const CurrencyRates({
    required this.base,
    required this.rates,
    this.updatedAt,
  });

  /// The currency every rate is quoted against, e.g. `USD`.
  final String base;

  /// `{ "USD": 1, "IQD": 1310, "EUR": 0.92 }` — how many units of each
  /// currency one [base] unit buys.
  final Map<String, double> rates;

  /// When the rates were last refreshed. Shown to the user as part of the
  /// disclosure, because an undated rate is worse than no rate.
  final DateTime? updatedAt;

  /// Nothing to convert with. Every conversion then returns null and callers
  /// fall back to the price in its original currency, which is always correct.
  static const CurrencyRates empty = CurrencyRates(
    base: 'USD',
    rates: <String, double>{},
  );

  bool get isEmpty => rates.isEmpty;

  bool supports(String code) => rates.containsKey(code.toUpperCase());

  /// [amount] in [from], expressed in [to] — or **null** when either currency
  /// is missing from the table.
  ///
  /// Null rather than a guess is the whole point: a wrong number on a price is
  /// worse than an honest foreign one, so an unknown currency must degrade to
  /// "show the operator's own price", never to "show something plausible".
  double? convert(num amount, {required String from, required String to}) {
    final fromCode = from.toUpperCase();
    final toCode = to.toUpperCase();
    if (fromCode == toCode) return amount.toDouble();

    final fromRate = rates[fromCode];
    final toRate = rates[toCode];
    if (fromRate == null || toRate == null) return null;
    if (fromRate <= 0) return null;

    // Cross-rate through the base: amount ÷ (units per base) × (units per base).
    return amount.toDouble() / fromRate * toRate;
  }

  static CurrencyRates fromMap(Map<String, dynamic>? data) {
    if (data == null) return empty;
    final base = data['base'];
    final raw = data['rates'];
    if (raw is! Map) return empty;

    final rates = <String, double>{};
    raw.forEach((key, value) {
      if (key is String && value is num && value > 0) {
        rates[key.toUpperCase()] = value.toDouble();
      }
    });
    if (rates.isEmpty) return empty;

    final updatedAt = data['updatedAt'];
    DateTime? when;
    if (updatedAt is DateTime) {
      when = updatedAt;
    } else if (updatedAt is String) {
      when = DateTime.tryParse(updatedAt);
    } else if (updatedAt != null) {
      try {
        final converted = (updatedAt as dynamic).toDate();
        if (converted is DateTime) when = converted;
      } catch (_) {
        // Not a Timestamp — leave the date null and let the caller say so.
      }
    }

    return CurrencyRates(
      base: base is String && base.isNotEmpty ? base.toUpperCase() : 'USD',
      rates: rates,
      updatedAt: when,
    );
  }
}

/// Reads `currency_rates/latest`, the one document behind every converted
/// price in the app.
///
/// **Indicative, not transactional.** These rates exist so a traveller can
/// compare a tour priced in USD against one priced in IQD. They are *not* what
/// a charge is settled at — a checkout must price in the operator's own
/// currency and let the payment processor do the conversion, or the app takes
/// on FX risk it has no way to hedge. Every screen that shows a converted
/// figure must mark it as approximate.
class CurrencyRatesService {
  CurrencyRatesService({FirebaseFirestore? firestore})
    : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  static const String collection = 'currency_rates';

  /// A **fixed document id**, not a query. One read, no index, and no way for
  /// a stale document to win a race with a fresh one.
  static const String latestDocumentId = 'latest';

  static bool get isPreviewMode => kDebugMode && !FirebaseBootstrap.isReady;

  /// The current rates, or [CurrencyRates.empty] when they cannot be read.
  ///
  /// **Never throws.** A missing rate table is not an error worth failing a
  /// catalog screen over — prices simply stay in the currency they were quoted
  /// in, which is what they would do anyway if the user's preference matched.
  Future<CurrencyRates> fetchLatest() async {
    if (isPreviewMode) return bundledRates;
    if (!FirebaseBootstrap.isReady) return CurrencyRates.empty;
    try {
      final snapshot = await _firestore
          .collection(collection)
          .doc(latestDocumentId)
          .get();
      return CurrencyRates.fromMap(snapshot.data());
    } catch (error) {
      debugPrint('Could not load currency rates: $error');
      return CurrencyRates.empty;
    }
  }

  /// Stand-in rates for preview mode, mirroring what
  /// `tool/seed_currency_rates.js` writes. **Keep the two in sync.**
  ///
  /// These are round illustrative numbers, not a market quote — which is
  /// exactly why every converted figure in the UI is prefixed with "≈".
  static const CurrencyRates bundledRates = CurrencyRates(
    base: 'USD',
    rates: <String, double>{'USD': 1, 'IQD': 1310, 'EUR': 0.92},
  );

  /// The symbol drawn in front of (or after) an amount.
  ///
  /// A currency with no well-known single-character symbol keeps its ISO code
  /// — "IQD 72,050" is unambiguous, and an invented glyph is not.
  static String symbolFor(String currency) => switch (currency.toUpperCase()) {
    'USD' => r'$',
    'EUR' => '€',
    _ => currency.toUpperCase(),
  };

  /// The user's chosen display currency as a plain ISO code.
  static String codeFor(AppCurrency currency) => currency.code;
}
