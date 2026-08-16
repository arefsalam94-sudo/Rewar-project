/// Models for the `bookings` collection — see `DATA_MODEL.md`.
///
/// The card content is **denormalized onto the booking document** rather than
/// joined from `hotels` / `cars` / `tours` / `flights` at display time. A
/// booking is a historical record: if a hotel is renamed, re-photographed or
/// delisted, the card must still show what was actually booked. See the "a
/// booking is a historical record" rule in `DATA_MODEL.md` for the full
/// reasoning.
library;

/// Which product a booking is for. Selects the card layout and the filter chip.
enum BookingType {
  hotel('hotel'),
  car('car'),
  flight('flight'),
  tour('tour');

  const BookingType(this.id);

  /// The value stored in Firestore (`bookings.type`).
  final String id;

  /// The prefix used by the server-generated [Booking.bookingReference].
  String get referencePrefix => switch (this) {
    BookingType.hotel => 'HTL',
    BookingType.car => 'CR',
    BookingType.flight => 'FL',
    BookingType.tour => 'TO',
  };

  static BookingType? fromId(Object? id) {
    for (final type in BookingType.values) {
      if (type.id == id) return type;
    }
    return null;
  }
}

/// Lifecycle of a booking.
///
/// `completed` is not in the original draft schema — it was added with the
/// Upcoming/Past/Cancelled time axis, so a finished trip can be distinguished
/// from one that is still ahead without inspecting dates on every card.
enum BookingStatus {
  pending('pending'),
  confirmed('confirmed'),
  cancelled('cancelled'),
  completed('completed');

  const BookingStatus(this.id);

  final String id;

  static BookingStatus? fromId(Object? id) {
    for (final status in BookingStatus.values) {
      if (status.id == id) return status;
    }
    return null;
  }
}

/// Flight cabin, stored as a **key rather than a display string** so it can be
/// translated. Drawn as the informational status pill.
enum CabinClass {
  economy('economy'),
  premiumEconomy('premium_economy'),
  business('business'),
  first('first');

  const CabinClass(this.id);

  final String id;

  static CabinClass? fromId(Object? id) {
    for (final cabin in CabinClass.values) {
      if (cabin.id == id) return cabin;
    }
    return null;
  }
}

/// The screen's time axis — the Booking.com / Agoda primary split.
enum BookingTimeFilter { upcoming, past, cancelled }

/// The screen's type axis, matching the chips drawn in the reference.
enum BookingTypeFilter {
  all(null),
  hotels(BookingType.hotel),
  cars(BookingType.car),
  flights(BookingType.flight),
  tours(BookingType.tour);

  const BookingTypeFilter(this.type);

  /// Null for [BookingTypeFilter.all], which matches every type.
  final BookingType? type;

  bool matches(Booking booking) => type == null || booking.type == type;
}

/// One document from `bookings/{id}`.
class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.bookingReference,
    required this.startAt,
    required this.referenceId,
    required this.display,
    this.endAt,
    this.totalPrice,
    this.currency,
    this.cancellable = false,
  });

  final String id;
  final String userId;
  final BookingType type;
  final BookingStatus status;

  /// The human-readable code shown on the card, e.g. `HTL-7845123`.
  /// Generated server-side — see `DATA_MODEL.md`.
  final String bookingReference;

  /// Check-in / departure / pick-up / tour start. Drives both the sort order
  /// and the Upcoming-vs-Past split.
  final DateTime startAt;

  /// Check-out / arrival / drop-off / tour end. Absent on a one-way flight.
  final DateTime? endAt;

  /// Id of the hotel/car/tour/flight document. **Navigation only** — never the
  /// source of anything the card displays.
  final String referenceId;

  final BookingDisplay display;

  final num? totalPrice;
  final String? currency;

  /// Whether the Cancel action is offered. Server-owned, derived from the
  /// provider's fare rules at purchase time.
  final bool cancellable;

  /// Which time segment this booking belongs in.
  ///
  /// Cancelled wins over dates: a cancelled trip is not "upcoming" merely
  /// because its date has not passed yet. Otherwise a booking is past once it
  /// has ended — using [endAt] when present, so a five-night stay stays
  /// "upcoming" on its third night rather than flipping to "past" the day
  /// after check-in.
  BookingTimeFilter segment(DateTime now) {
    if (status == BookingStatus.cancelled) return BookingTimeFilter.cancelled;
    if (status == BookingStatus.completed) return BookingTimeFilter.past;
    final boundary = endAt ?? startAt;
    return boundary.isBefore(now)
        ? BookingTimeFilter.past
        : BookingTimeFilter.upcoming;
  }

  /// Builds a booking from a Firestore document, or null when a field the card
  /// cannot be drawn without is missing.
  ///
  /// Returning null rather than throwing keeps one malformed document from
  /// emptying the user's entire booking list — the service skips it and shows
  /// the rest, the same rule [FeaturedItem] follows.
  static Booking? fromMap(String id, Map<String, dynamic>? data) {
    if (data == null) return null;

    final type = BookingType.fromId(data['type']);
    if (type == null) return null;

    final status = BookingStatus.fromId(data['status']);
    if (status == null) return null;

    final userId = data['userId'];
    if (userId is! String || userId.isEmpty) return null;

    final reference = data['bookingReference'];
    if (reference is! String || reference.isEmpty) return null;

    final startAt = _dateTime(data['startAt']);
    if (startAt == null) return null;

    final display = BookingDisplay.fromMap(type, data['display']);
    if (display == null) return null;

    final referenceId = data['referenceId'];
    final price = data['totalPrice'];
    final currency = data['currency'];

    return Booking(
      id: id,
      userId: userId,
      type: type,
      status: status,
      bookingReference: reference,
      startAt: startAt,
      endAt: _dateTime(data['endAt']),
      referenceId: referenceId is String ? referenceId : '',
      display: display,
      totalPrice: price is num ? price : null,
      currency: currency is String && currency.isNotEmpty ? currency : null,
      cancellable: data['cancellable'] == true,
    );
  }

  /// Accepts a Firestore `Timestamp` (via its `toDate()`), a `DateTime`, or an
  /// ISO-8601 string — the last so the bundled preview fixtures and the seed
  /// script can share one JSON shape without importing `cloud_firestore`.
  static DateTime? _dateTime(Object? raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    try {
      final converted = (raw as dynamic).toDate();
      return converted is DateTime ? converted : null;
    } catch (_) {
      return null;
    }
  }
}

/// The denormalized `display` map — everything the card actually draws.
class BookingDisplay {
  const BookingDisplay({
    required this.titles,
    required this.locationLabels,
    this.imageUrl,
    this.imageAsset,
    this.guestCount,
    this.roomName,
    this.fromCode,
    this.toCode,
    this.fromCities = const {},
    this.toCities = const {},
    this.durationMinutes,
    this.seat,
    this.cabinClass,
    this.pickupLocations = const {},
    this.carClass,
    this.durationHours,
  });

  final Map<String, String> titles;
  final Map<String, String> locationLabels;

  /// Storage download URL for the card thumbnail. Flights have none.
  final String? imageUrl;

  /// Bundled asset used instead of [imageUrl] in preview mode, before any real
  /// image has been uploaded. Never set on a document read from Firestore.
  final String? imageAsset;

  /// Guests / travelers / drivers / passengers. One field, four labels — the
  /// label comes from [Booking.type], so the schema needs no near-duplicates.
  final int? guestCount;

  // --- hotel ---
  final String? roomName;

  // --- flight ---
  final String? fromCode;
  final String? toCode;
  final Map<String, String> fromCities;
  final Map<String, String> toCities;
  final int? durationMinutes;

  /// Absent before check-in. The Seat row is **hidden rather than faked** when
  /// null — the same rule as Explore Nature's Distance row.
  final String? seat;
  final CabinClass? cabinClass;

  // --- car ---
  final Map<String, String> pickupLocations;
  final String? carClass;

  // --- tour ---
  final int? durationHours;

  String title(String languageCode) => _localized(titles, languageCode);

  String locationLabel(String languageCode) =>
      _localized(locationLabels, languageCode);

  String fromCity(String languageCode) => _localized(fromCities, languageCode);

  String toCity(String languageCode) => _localized(toCities, languageCode);

  String pickupLocation(String languageCode) =>
      _localized(pickupLocations, languageCode);

  static String _localized(Map<String, String> values, String languageCode) =>
      values[languageCode] ?? values['en'] ?? '';

  /// Returns null when the map is missing the title every card needs.
  static BookingDisplay? fromMap(BookingType type, Object? raw) {
    if (raw is! Map) return null;
    final data = raw.cast<Object?, Object?>();

    final titles = _localeMap(data['title']);
    if (titles.isEmpty) return null;

    final guestCount = data['guestCount'];
    final durationMinutes = data['durationMinutes'];
    final durationHours = data['durationHours'];

    return BookingDisplay(
      titles: titles,
      locationLabels: _localeMap(data['locationLabel']),
      imageUrl: _string(data['imageUrl']),
      guestCount: guestCount is num ? guestCount.toInt() : null,
      roomName: type == BookingType.hotel ? _string(data['roomName']) : null,
      fromCode: type == BookingType.flight ? _string(data['fromCode']) : null,
      toCode: type == BookingType.flight ? _string(data['toCode']) : null,
      fromCities: type == BookingType.flight
          ? _localeMap(data['fromCity'])
          : const {},
      toCities: type == BookingType.flight
          ? _localeMap(data['toCity'])
          : const {},
      durationMinutes: type == BookingType.flight && durationMinutes is num
          ? durationMinutes.toInt()
          : null,
      seat: type == BookingType.flight ? _string(data['seat']) : null,
      cabinClass: type == BookingType.flight
          ? CabinClass.fromId(data['cabinClass'])
          : null,
      pickupLocations: type == BookingType.car
          ? _localeMap(data['pickupLocation'])
          : const {},
      carClass: type == BookingType.car ? _string(data['carClass']) : null,
      durationHours: type == BookingType.tour && durationHours is num
          ? durationHours.toInt()
          : null,
    );
  }

  static String? _string(Object? raw) =>
      raw is String && raw.isNotEmpty ? raw : null;

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
