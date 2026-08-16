import 'package:cloud_firestore/cloud_firestore.dart';

/// A curated place to stay near a nature spot. These are discovery links, not
/// availability or price claims; live booking data belongs to the hotel flow.
class NearbyStay {
  const NearbyStay({
    required this.id,
    required this.names,
    this.imageUrl,
    this.imageAsset,
    this.distanceKm,
    this.reviewScore,
  });

  final String id;
  final Map<String, String> names;
  final String? imageUrl;
  final String? imageAsset;
  final double? distanceKm;
  final double? reviewScore;

  String name(String languageCode) => names[languageCode] ?? names['en'] ?? '';

  static NearbyStay? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final data = Map<Object?, Object?>.from(raw);
    final id = data['id'];
    final names = _localeMap(data['name']);
    if (id is! String || id.isEmpty || names.isEmpty) return null;
    final distance = data['distanceKm'];
    final score = data['reviewScore'];
    return NearbyStay(
      id: id,
      names: names,
      imageUrl: data['imageUrl'] is String ? data['imageUrl'] as String : null,
      distanceKm: distance is num ? distance.toDouble() : null,
      reviewScore: score is num
          ? score.toDouble().clamp(0.0, 10.0).toDouble()
          : null,
    );
  }
}

/// How the Reviews & Ratings list is ordered.
///
/// Every option is applied **in the Firestore query**, not in Dart. The list
/// is paginated, so sorting a downloaded page would rank the newest ten
/// reviews and present them as the highest rated of all of them. Each option
/// has its own composite index in `firestore.indexes.json`.
enum ReviewSort {
  mostRecent(field: 'createdAt', descending: true),
  highestRated(field: 'rating', descending: true),
  lowestRated(field: 'rating', descending: false),
  mostHelpful(field: 'helpfulCount', descending: true);

  const ReviewSort({required this.field, required this.descending});

  /// The document field this option orders on.
  final String field;
  final bool descending;

  /// Whether the query needs `createdAt` as a tie-breaker after [field].
  /// `mostRecent` already orders on it, so adding it twice would be invalid.
  bool get needsCreatedAtTieBreak => this != ReviewSort.mostRecent;
}

/// The 5★/4★/3★/2★/1★ distribution drawn as bars beside the average score.
///
/// **Server-maintained**, on the `nature_spots` document — see
/// `syncNatureReviewAggregates` in `functions/index.js`. Deriving it in the
/// client from whatever page of reviews happened to be downloaded would
/// produce bars that describe ten reviews sitting next to a label reading
/// "128 reviews".
class RatingBreakdown {
  const RatingBreakdown(this.counts);

  /// Keyed 1–5. A star with no reviews is absent, not zero-padded.
  final Map<int, int> counts;

  static const RatingBreakdown empty = RatingBreakdown(<int, int>{});

  int countFor(int star) => counts[star] ?? 0;

  /// Total reviews across all five bars. Used only as the percentage
  /// denominator — the visible "N reviews" label comes from `ratingCount`, so
  /// a breakdown that has drifted can never silently change the headline
  /// number.
  int get total => counts.values.fold(0, (running, value) => running + value);

  bool get isEmpty => total == 0;

  /// This star's share of the total, 0.0–1.0. Zero when there is nothing to
  /// divide by, rather than NaN.
  double fractionFor(int star) {
    final all = total;
    if (all == 0) return 0;
    return countFor(star) / all;
  }

  static RatingBreakdown fromMap(Object? raw) {
    if (raw is! Map) return empty;
    final counts = <int, int>{};
    raw.forEach((key, value) {
      final star = key is num ? key.toInt() : int.tryParse('$key');
      if (star == null || star < 1 || star > 5) return;
      if (value is num && value > 0) counts[star] = value.toInt();
    });
    return RatingBreakdown(counts);
  }
}

/// One public visitor review from `nature_spots/{spotId}/reviews/{reviewId}`.
///
/// **The document id is the author's uid**, which is what makes one review per
/// person per place enforceable in `firestore.rules` rather than merely
/// intended. It also means a returning author edits their review instead of
/// stacking a second one on the same place.
class NatureReview {
  const NatureReview({
    required this.id,
    required this.userName,
    required this.comment,
    required this.rating,
    this.userId,
    this.avatarUrl,
    this.createdAt,
    this.helpfulCount = 0,
    this.viewerFoundHelpful = false,
  });

  final String id;
  final String? userId;
  final String userName;
  final String comment;

  /// 0.5–5.0 in half-star steps. A **double**, not an integer, because the
  /// design draws half stars — a 6.0/10 review is 3.5 stars, which an integer
  /// cannot hold. Shown as `rating * 2` out of 10.
  final double rating;

  final String? avatarUrl;
  final DateTime? createdAt;

  /// How many people marked this review helpful. **Server-owned** — written
  /// only by the `syncReviewHelpfulCount` trigger from the `votes`
  /// subcollection, never by a client.
  final int helpfulCount;

  /// Whether the signed-in viewer has voted on this review. Read per-viewer
  /// from `votes/{uid}` and held here for drawing the filled/outlined heart;
  /// it is **not** a stored field on the review.
  final bool viewerFoundHelpful;

  /// The 0–10 score this review's stars represent.
  double get scoreOutOfTen => rating * 2;

  NatureReview copyWith({int? helpfulCount, bool? viewerFoundHelpful}) =>
      NatureReview(
        id: id,
        userId: userId,
        userName: userName,
        comment: comment,
        rating: rating,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
        helpfulCount: helpfulCount ?? this.helpfulCount,
        viewerFoundHelpful: viewerFoundHelpful ?? this.viewerFoundHelpful,
      );

  /// Snaps any incoming number onto the half-star scale the UI can draw.
  ///
  /// A value the app cannot render is worse than a rounded one: 3.7 stars has
  /// no drawing, so it would silently become 3.5 or 4 somewhere further down
  /// anyway. Doing it here means one rule, in one place.
  static double normalizeRating(num raw) =>
      ((raw * 2).round() / 2).clamp(0.5, 5.0).toDouble();

  static NatureReview? fromMap(String id, Map<String, dynamic>? data) {
    if (data == null) return null;
    final userName = data['userName'];
    final comment = data['comment'];
    final rating = data['rating'];
    if (userName is! String ||
        userName.isEmpty ||
        comment is! String ||
        comment.isEmpty ||
        rating is! num) {
      return null;
    }
    final rawCreatedAt = data['createdAt'];
    final helpful = data['helpfulCount'];
    return NatureReview(
      id: id,
      userId: data['userId'] is String ? data['userId'] as String : null,
      userName: userName,
      comment: comment,
      rating: normalizeRating(rating),
      avatarUrl: data['avatarUrl'] is String
          ? data['avatarUrl'] as String
          : null,
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : null,
      helpfulCount: helpful is num ? helpful.toInt().clamp(0, 1 << 30) : 0,
    );
  }
}

/// One page of reviews plus the cursor that fetches the next one.
class NatureReviewPage {
  const NatureReviewPage({
    required this.reviews,
    required this.hasMore,
    this.cursor,
  });

  final List<NatureReview> reviews;
  final bool hasMore;

  /// Opaque paging cursor (a Firestore `DocumentSnapshot` when live, null in
  /// preview mode). Held as `Object?` so the model layer stays plain Dart.
  final Object? cursor;

  static const NatureReviewPage empty = NatureReviewPage(
    reviews: <NatureReview>[],
    hasMore: false,
  );
}

Map<String, String> _localeMap(Object? raw) {
  if (raw is! Map) return const {};
  final result = <String, String>{};
  raw.forEach((key, value) {
    if (key is String && value is String && value.isNotEmpty) {
      result[key] = value;
    }
  });
  return result;
}
