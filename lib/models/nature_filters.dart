import 'package:flutter/foundation.dart';

import 'nature_spot.dart';

/// The "Place Type" group on the Customize Filters screen.
///
/// Stored as the snake_case [id] inside `nature_spots.placeTypes`; the visible
/// label is localized by the screen, so adding a language never means
/// rewriting Firestore data.
enum NaturePlaceType {
  forest('forest'),
  mountain('mountain'),
  canyon('canyon'),
  park('park'),
  lake('lake'),
  waterfall('waterfall'),
  river('river'),
  museum('museum');

  const NaturePlaceType(this.id);

  final String id;
}

/// The "Facilities & Amenities" group.
///
/// Stored as the snake_case [id] inside `nature_spots.amenities`.
enum NatureAmenity {
  parking('parking'),
  restrooms('restrooms'),
  restaurants('restaurants'),
  cafes('cafes'),
  mobileSignal('mobile_signal'),
  lodgingNearby('lodging_nearby'),
  atmNearby('atm_nearby');

  const NatureAmenity(this.id);

  final String id;
}

/// Everything currently narrowing the Explore Nature list.
///
/// Three independent dimensions:
/// * [activities] — the quick chips on the list screen itself (Hiking, Beach,
///   Sunset View), stored in `nature_spots.categories`.
/// * [placeTypes] — the Customize screen's first group.
/// * [amenities] — the Customize screen's second group.
///
/// **OR within a group, AND across groups.** Selecting Forest and Waterfall
/// widens the results to places that are either; selecting Waterfall *and*
/// Restrooms narrows to waterfalls that have restrooms. Confirmed decision —
/// see `PROGRESS.md`.
///
/// Immutable, so a screen can hold a draft ([copyWith]) and either return it or
/// throw it away without the caller's copy ever changing underneath it.
@immutable
class NatureFilters {
  const NatureFilters({
    this.activities = const {},
    this.placeTypes = const {},
    this.amenities = const {},
  });

  final Set<String> activities;
  final Set<String> placeTypes;
  final Set<String> amenities;

  /// How many chips the **Customize** screen shows as selected.
  ///
  /// Deliberately excludes [activities]: the reference counts only the two
  /// groups drawn on that screen, and Reset All clears only those. The quick
  /// chips stay selected on the list screen behind it.
  int get customizeCount => placeTypes.length + amenities.length;

  bool get isEmpty =>
      activities.isEmpty && placeTypes.isEmpty && amenities.isEmpty;

  /// Whether [spot] survives every active dimension.
  ///
  /// Applied in Dart rather than in the Firestore query, because Firestore
  /// permits only one array clause per query and this screen has three. See
  /// `DATA_MODEL.md` for why that is the right trade at this catalog size.
  bool matches(NatureSpot spot) =>
      _matchesAny(activities, spot.categories) &&
      _matchesAny(placeTypes, spot.placeTypes) &&
      _matchesAny(amenities, spot.amenities);

  /// An empty selection is "no filter", not "match nothing".
  static bool _matchesAny(Set<String> selected, Set<String> owned) =>
      selected.isEmpty || selected.any(owned.contains);

  /// Returns a copy with [value] toggled in the named group.
  NatureFilters toggleActivity(String value) =>
      copyWith(activities: _toggled(activities, value));

  NatureFilters togglePlaceType(String value) =>
      copyWith(placeTypes: _toggled(placeTypes, value));

  NatureFilters toggleAmenity(String value) =>
      copyWith(amenities: _toggled(amenities, value));

  /// Clears only the two Customize groups, leaving the quick chips alone —
  /// what "Reset All" means on that screen.
  NatureFilters clearCustomize() => NatureFilters(
    activities: activities,
    placeTypes: const {},
    amenities: const {},
  );

  NatureFilters copyWith({
    Set<String>? activities,
    Set<String>? placeTypes,
    Set<String>? amenities,
  }) => NatureFilters(
    activities: activities ?? this.activities,
    placeTypes: placeTypes ?? this.placeTypes,
    amenities: amenities ?? this.amenities,
  );

  static Set<String> _toggled(Set<String> source, String value) {
    final next = Set<String>.of(source);
    if (!next.remove(value)) next.add(value);
    return next;
  }

  @override
  bool operator ==(Object other) =>
      other is NatureFilters &&
      setEquals(other.activities, activities) &&
      setEquals(other.placeTypes, placeTypes) &&
      setEquals(other.amenities, amenities);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(activities),
    Object.hashAllUnordered(placeTypes),
    Object.hashAllUnordered(amenities),
  );
}
