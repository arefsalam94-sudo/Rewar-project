/// What kind of catalog entry a [FeaturedItem] points at.
///
/// The featured carousel deliberately mixes types — a nature spot, a rental
/// company, a flight and a tour can all be highlighted side by side — so the
/// slide has to carry its own type rather than being inferred from the
/// collection it came from.
enum FeaturedType {
  natureSpot('nature_spot'),
  hotel('hotel'),
  car('car'),
  tour('tour'),
  flight('flight');

  const FeaturedType(this.id);

  /// The value stored in Firestore (`featured.type`) and in
  /// `favorites.itemType`.
  final String id;

  static FeaturedType? fromId(Object? id) {
    for (final type in FeaturedType.values) {
      if (type.id == id) return type;
    }
    return null;
  }
}

/// One slide of the home screen's featured carousel, from `featured/{id}`.
///
/// Title and subtitle are **locale maps** (`{en, ku, ar}`) rather than plain
/// strings: the app runs in three languages and switching language must not
/// require a second read. A missing locale falls back to English, so a slide
/// is never blank — the same fallback rule `legal_documents` uses.
class FeaturedItem {
  const FeaturedItem({
    required this.id,
    required this.type,
    required this.referenceId,
    required this.titles,
    required this.subtitles,
    this.imageUrl,
    this.imageAsset,
    this.rating,
    this.order = 0,
  });

  final String id;
  final FeaturedType type;

  /// Id of the document in the type's own collection, so tapping Explore can
  /// open the right detail screen once those screens exist.
  final String referenceId;

  final Map<String, String> titles;
  final Map<String, String> subtitles;

  /// Firebase Storage download URL for the slide photo.
  final String? imageUrl;

  /// Bundled asset used instead of [imageUrl] in preview mode, before any
  /// real image has been uploaded. Never set on a document read from
  /// Firestore.
  final String? imageAsset;

  /// 0–5, shown as a star pill. Null hides the pill rather than drawing a
  /// zero — an unrated item is not a badly rated one.
  final double? rating;

  /// Ascending display order, chosen by the admin panel.
  final int order;

  String title(String languageCode) => _localized(titles, languageCode);

  String subtitle(String languageCode) => _localized(subtitles, languageCode);

  static String _localized(Map<String, String> values, String languageCode) =>
      values[languageCode] ?? values['en'] ?? '';

  /// Builds an item from a Firestore document, or null if the document is
  /// missing the fields the card cannot be drawn without.
  ///
  /// Returning null rather than throwing keeps one malformed document from
  /// emptying the whole carousel — the service skips it and shows the rest.
  static FeaturedItem? fromMap(String id, Map<String, dynamic>? data) {
    if (data == null) return null;

    final type = FeaturedType.fromId(data['type']);
    if (type == null) return null;

    final titles = _localeMap(data['title']);
    if (titles.isEmpty) return null;

    final referenceId = data['referenceId'];
    if (referenceId is! String || referenceId.isEmpty) return null;

    final rating = data['rating'];
    final order = data['order'];

    return FeaturedItem(
      id: id,
      type: type,
      referenceId: referenceId,
      titles: titles,
      subtitles: _localeMap(data['subtitle']),
      imageUrl: data['imageUrl'] is String ? data['imageUrl'] as String : null,
      rating: rating is num ? rating.toDouble().clamp(0.0, 5.0) : null,
      order: order is num ? order.toInt() : 0,
    );
  }

  static Map<String, String> _localeMap(Object? raw) {
    if (raw is! Map) return const {};
    final result = <String, String>{};
    raw.forEach((key, value) {
      if (key is String && value is String && value.isNotEmpty) {
        result[key] = value;
      }
    });
    return result;
  }
}
