import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/models/booking.dart';

void main() {
  group('Booking.fromMap — parsing', () {
    test('parses a complete hotel document', () {
      final booking = Booking.fromMap('b1', _hotelData());

      expect(booking, isNotNull);
      expect(booking!.type, BookingType.hotel);
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.bookingReference, 'HTL-7845123');
      expect(booking.startAt, DateTime.parse('2030-05-24T14:00:00Z'));
      expect(booking.endAt, DateTime.parse('2030-05-27T12:00:00Z'));
      expect(booking.display.title('en'), 'Divan Erbil Hotel');
      expect(booking.display.guestCount, 2);
      expect(booking.display.roomName, 'Deluxe Twin');
      expect(booking.cancellable, isTrue);
    });

    test('falls back to English for a missing locale, never to blank', () {
      final booking = Booking.fromMap('b1', _hotelData())!;

      expect(booking.display.title('ku'), 'هوتێلی دیڤان هەولێر');
      // No Arabic in this fixture — English rather than an empty card.
      expect(booking.display.title('ar'), 'Divan Erbil Hotel');
      expect(booking.display.title('de'), 'Divan Erbil Hotel');
    });

    test('returns null rather than throwing on a malformed document', () {
      // One bad document must not empty the user's whole booking list — the
      // service skips it and shows the rest.
      expect(Booking.fromMap('x', null), isNull);
      expect(Booking.fromMap('x', _hotelData(type: 'spaceship')), isNull);
      expect(Booking.fromMap('x', _hotelData(status: 'refunded')), isNull);
      expect(Booking.fromMap('x', _hotelData(reference: '')), isNull);
      expect(Booking.fromMap('x', _hotelData(userId: '')), isNull);
      expect(Booking.fromMap('x', _hotelData(startAt: 'not-a-date')), isNull);
      expect(Booking.fromMap('x', _hotelData(display: null)), isNull);
      expect(
        Booking.fromMap('x', _hotelData(display: <String, Object>{})),
        isNull,
      );
    });

    test('type-specific fields are only read for their own type', () {
      // A hotel document carrying stray flight keys must not surface them —
      // otherwise a mistyped admin entry would draw a seat number on a hotel.
      final data = _hotelData();
      (data['display']! as Map<String, Object?>)
        ..['seat'] = '16A'
        ..['cabinClass'] = 'business'
        ..['fromCode'] = 'EBL'
        ..['durationHours'] = 8;

      final booking = Booking.fromMap('b1', data)!;
      expect(booking.display.seat, isNull);
      expect(booking.display.cabinClass, isNull);
      expect(booking.display.fromCode, isNull);
      expect(booking.display.durationHours, isNull);
    });

    test('parses the flight block, including the cabin key', () {
      final booking = Booking.fromMap('f1', _flightData())!;

      expect(booking.display.fromCode, 'EBL');
      expect(booking.display.toCode, 'IST');
      expect(booking.display.fromCity('en'), 'Erbil');
      expect(booking.display.toCity('ar'), 'إسطنبول');
      expect(booking.display.durationMinutes, 165);
      expect(booking.display.seat, '16A');
      expect(booking.display.cabinClass, CabinClass.economy);
    });

    test('an absent seat stays null, so the row can be hidden not faked', () {
      final data = _flightData();
      (data['display']! as Map<String, Object?>).remove('seat');

      expect(Booking.fromMap('f1', data)!.display.seat, isNull);
    });
  });

  group('Booking.segment — the Upcoming / Past / Cancelled axis', () {
    final now = DateTime.parse('2030-06-01T12:00:00Z');

    Booking build({
      required BookingStatus status,
      required String startAt,
      String? endAt,
    }) => Booking.fromMap(
      'b',
      _hotelData(status: status.id, startAt: startAt, endAt: endAt),
    )!;

    test('a future booking is upcoming', () {
      final booking = build(
        status: BookingStatus.confirmed,
        startAt: '2030-06-10T14:00:00Z',
        endAt: '2030-06-14T12:00:00Z',
      );
      expect(booking.segment(now), BookingTimeFilter.upcoming);
    });

    test('a finished booking is past', () {
      final booking = build(
        status: BookingStatus.confirmed,
        startAt: '2030-05-10T14:00:00Z',
        endAt: '2030-05-14T12:00:00Z',
      );
      expect(booking.segment(now), BookingTimeFilter.past);
    });

    test('a stay in progress is still upcoming, not past', () {
      // The regression this guards: using startAt alone would flip a five-night
      // stay to "past" on its second day, hiding the card the guest most needs.
      final booking = build(
        status: BookingStatus.confirmed,
        startAt: '2030-05-30T14:00:00Z',
        endAt: '2030-06-04T12:00:00Z',
      );
      expect(booking.segment(now), BookingTimeFilter.upcoming);
    });

    test('cancelled wins over dates, in both directions', () {
      // A cancelled trip is not "upcoming" merely because its date has not
      // arrived yet.
      expect(
        build(
          status: BookingStatus.cancelled,
          startAt: '2030-06-10T14:00:00Z',
        ).segment(now),
        BookingTimeFilter.cancelled,
      );
      expect(
        build(
          status: BookingStatus.cancelled,
          startAt: '2030-05-01T14:00:00Z',
        ).segment(now),
        BookingTimeFilter.cancelled,
      );
    });

    test('completed is past even if its dates say otherwise', () {
      expect(
        build(
          status: BookingStatus.completed,
          startAt: '2030-06-10T14:00:00Z',
        ).segment(now),
        BookingTimeFilter.past,
      );
    });

    test('a booking with no endAt falls back to startAt', () {
      expect(
        build(
          status: BookingStatus.confirmed,
          startAt: '2030-05-10T14:00:00Z',
        ).segment(now),
        BookingTimeFilter.past,
      );
    });
  });

  group('Filters and reference prefixes', () {
    test('BookingTypeFilter.all matches every type', () {
      for (final type in BookingType.values) {
        final booking = Booking.fromMap('b', _hotelData(type: type.id))!;
        expect(BookingTypeFilter.all.matches(booking), isTrue);
      }
    });

    test('a type filter matches only its own type', () {
      final hotel = Booking.fromMap('b', _hotelData())!;
      expect(BookingTypeFilter.hotels.matches(hotel), isTrue);
      expect(BookingTypeFilter.cars.matches(hotel), isFalse);
      expect(BookingTypeFilter.flights.matches(hotel), isFalse);
      expect(BookingTypeFilter.tours.matches(hotel), isFalse);
    });

    test('every type has a distinct reference prefix', () {
      final prefixes = BookingType.values
          .map((type) => type.referencePrefix)
          .toSet();
      expect(prefixes.length, BookingType.values.length);
      expect(BookingType.hotel.referencePrefix, 'HTL');
      expect(BookingType.flight.referencePrefix, 'FL');
    });

    test('every filter except `all` maps to a real type', () {
      for (final filter in BookingTypeFilter.values) {
        if (filter == BookingTypeFilter.all) {
          expect(filter.type, isNull);
        } else {
          expect(filter.type, isNotNull, reason: '$filter');
        }
      }
    });
  });
}

// --- Fixtures ----------------------------------------------------------------

Map<String, dynamic> _hotelData({
  String type = 'hotel',
  String status = 'confirmed',
  String reference = 'HTL-7845123',
  String userId = 'user-1',
  Object? startAt = '2030-05-24T14:00:00Z',
  Object? endAt = '2030-05-27T12:00:00Z',
  Object? display = _unset,
}) => <String, dynamic>{
  'userId': userId,
  'type': type,
  'status': status,
  'bookingReference': reference,
  'referenceId': 'divan-erbil',
  'startAt': startAt,
  'endAt': endAt,
  'totalPrice': 420,
  'currency': 'USD',
  'cancellable': true,
  'display': identical(display, _unset)
      ? <String, Object?>{
          'title': {'en': 'Divan Erbil Hotel', 'ku': 'هوتێلی دیڤان هەولێر'},
          'locationLabel': {'en': 'Erbil, Iraq'},
          'guestCount': 2,
          'roomName': 'Deluxe Twin',
        }
      : display,
};

Map<String, dynamic> _flightData() => <String, dynamic>{
  'userId': 'user-1',
  'type': 'flight',
  'status': 'confirmed',
  'bookingReference': 'FL-9856217',
  'referenceId': 'ebl-ist',
  'startAt': '2030-05-25T09:35:00Z',
  'endAt': '2030-05-25T12:20:00Z',
  'display': <String, Object?>{
    'title': {'en': 'Iraqi Airways'},
    'locationLabel': {'en': 'Erbil International Airport'},
    'guestCount': 1,
    'fromCode': 'EBL',
    'toCode': 'IST',
    'fromCity': {'en': 'Erbil'},
    'toCity': {'en': 'Istanbul', 'ar': 'إسطنبول'},
    'durationMinutes': 165,
    'seat': '16A',
    'cabinClass': 'economy',
  },
};

/// Sentinel so a test can pass an explicit `null` display.
const Object _unset = Object();
