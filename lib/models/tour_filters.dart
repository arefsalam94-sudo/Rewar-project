import 'tour.dart';

/// The orders the Explore Tours list can be shown in.
///
/// Both reference products lead with a sort control, because "which of these
/// forty tours" is a different question from "which tours exist". The default
/// stays [soonest] — a departure list is chronological until the user says
/// otherwise, and it is the only order that needs no data the operator might
/// have left blank.
enum TourSort {
  soonest,
  priceLowToHigh,
  priceHighToLow,
  topRated,
  nearest;

  /// Whether this order needs a device position. [TourFilters.sortedFrom]
  /// falls back to [soonest] when there is none, rather than presenting an
  /// arbitrary order as "nearest".
  bool get needsLocation => this == TourSort.nearest;
}

/// Everything currently narrowing and ordering the Explore Tours list.
///
/// Immutable, with `copyWith`-style helpers, so a rebuild always draws from
/// one value rather than five independent pieces of state that can disagree.
class TourFilters {
  const TourFilters({
    this.query = '',
    this.rangeStart,
    this.rangeEnd,
    this.features = const {},
    this.guideLanguages = const {},
    this.sort = TourSort.soonest,
    this.travellers = 1,
  });

  /// Free text, matched against name / location / operator in **every**
  /// language — see [Tour.matchesQuery].
  final String query;

  /// The date window, as a closed range. [rangeEnd] null with a non-null
  /// [rangeStart] means a single day.
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  /// [TourFeature] ids. **OR within the group** — selecting Camping and Food
  /// widens the results to tours with either, matching the semantics
  /// `NatureFilters` already established.
  final Set<String> features;

  /// [TourGuideLanguage] codes. Also OR within the group.
  final Set<String> guideLanguages;

  final TourSort sort;

  /// How many people are travelling. Used two ways: it prices the trip, and it
  /// hides departures that cannot seat the whole party — showing someone a
  /// tour with two places left when they have said there are four of them is
  /// how a booking failure gets discovered at the payment screen.
  final int travellers;

  static const int minTravellers = 1;

  /// A ceiling, so the stepper cannot run away and so a party larger than any
  /// real departure does not silently empty the list.
  static const int maxTravellers = 20;

  bool get hasDateRange => rangeStart != null;

  /// Whether anything at all is narrowing the list — which is what decides
  /// whether an empty result is offered a "clear" action.
  bool get isEmpty =>
      query.trim().isEmpty &&
      rangeStart == null &&
      features.isEmpty &&
      guideLanguages.isEmpty &&
      travellers == minTravellers;

  /// How many refinements are active, for the badge on the filter control.
  int get refinementCount => features.length + guideLanguages.length;

  TourFilters copyWith({
    String? query,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    bool clearRange = false,
    Set<String>? features,
    Set<String>? guideLanguages,
    TourSort? sort,
    int? travellers,
  }) => TourFilters(
    query: query ?? this.query,
    rangeStart: clearRange ? null : (rangeStart ?? this.rangeStart),
    rangeEnd: clearRange ? null : (rangeEnd ?? this.rangeEnd),
    features: features ?? this.features,
    guideLanguages: guideLanguages ?? this.guideLanguages,
    sort: sort ?? this.sort,
    travellers: travellers ?? this.travellers,
  );

  TourFilters toggleFeature(String id) => copyWith(
    features: features.contains(id)
        ? (Set<String>.from(features)..remove(id))
        : (Set<String>.from(features)..add(id)),
  );

  TourFilters toggleGuideLanguage(String code) => copyWith(
    guideLanguages: guideLanguages.contains(code)
        ? (Set<String>.from(guideLanguages)..remove(code))
        : (Set<String>.from(guideLanguages)..add(code)),
  );

  /// Whether [tour] survives every active filter.
  ///
  /// **OR within a group, AND across groups** — the same semantics as
  /// `NatureFilters.matches`. An empty group means "no filter", not "match
  /// nothing".
  bool matches(Tour tour) {
    if (!tour.matchesQuery(query)) return false;

    final from = rangeStart;
    if (from != null && !tour.runsBetween(from, rangeEnd)) return false;

    if (features.isNotEmpty && !features.any(tour.features.contains)) {
      return false;
    }
    if (guideLanguages.isNotEmpty &&
        !guideLanguages.any(tour.guideLanguages.contains)) {
      return false;
    }
    // A sold-out departure, or one that cannot seat the whole party.
    if (!tour.hasRoomFor(travellers)) return false;

    return true;
  }

  /// The filtered list in [sort] order.
  ///
  /// [fromLatitude]/[fromLongitude] are the device position, needed only by
  /// [TourSort.nearest]; without them that order falls back to [soonest]
  /// rather than presenting an arbitrary sequence as "nearest to you".
  ///
  /// Every comparison puts **items missing the sort key last** rather than
  /// treating a blank field as a zero — a tour with no price is not the
  /// cheapest, and an unrated tour is not the worst rated.
  List<Tour> sortedFrom(
    List<Tour> tours, {
    double? fromLatitude,
    double? fromLongitude,
  }) {
    final matching = tours.where(matches).toList();
    final canSortByDistance = fromLatitude != null && fromLongitude != null;
    final order = sort.needsLocation && !canSortByDistance
        ? TourSort.soonest
        : sort;

    int byMissingLast(Comparable<dynamic>? a, Comparable<dynamic>? b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b);
    }

    switch (order) {
      case TourSort.soonest:
        matching.sort((a, b) => byMissingLast(a.startAt, b.startAt));
        // The admin's "Trending" picks lead the default order only. Once the
        // user has chosen cheapest or top-rated, honouring an editorial pin
        // above their own instruction would just look like a broken sort.
        return trendingFirst(matching);
      case TourSort.priceLowToHigh:
        matching.sort(
          (a, b) => byMissingLast(a.pricePerPerson, b.pricePerPerson),
        );
      case TourSort.priceHighToLow:
        matching.sort((a, b) {
          if (a.pricePerPerson == null || b.pricePerPerson == null) {
            return byMissingLast(a.pricePerPerson, b.pricePerPerson);
          }
          return b.pricePerPerson!.compareTo(a.pricePerPerson!);
        });
      case TourSort.topRated:
        matching.sort((a, b) {
          if (a.reviewScore == null || b.reviewScore == null) {
            return byMissingLast(a.reviewScore, b.reviewScore);
          }
          return b.reviewScore!.compareTo(a.reviewScore!);
        });
      case TourSort.nearest:
        matching.sort(
          (a, b) => byMissingLast(
            a.distanceMetersFrom(fromLatitude!, fromLongitude!),
            b.distanceMetersFrom(fromLatitude, fromLongitude),
          ),
        );
    }
    return matching;
  }

  /// Moves the admin's `trending` picks to the front, in their
  /// `trendingOrder`, leaving everything else in the order it arrived.
  ///
  /// The partition is **stable**, so whatever ordering the caller established
  /// survives inside each group.
  static List<Tour> trendingFirst(List<Tour> tours) {
    final flagged = <Tour>[];
    final rest = <Tour>[];
    for (final tour in tours) {
      (tour.trending ? flagged : rest).add(tour);
    }
    flagged.sort((a, b) => a.trendingOrder.compareTo(b.trendingOrder));
    return [...flagged, ...rest];
  }
}
