import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/models/booking.dart';
import 'package:kurdistan_paradise_travel_guide/services/bookings_service.dart';

void main() {
  group('BookingsService.bundledBookings — the preview fixtures', () {
    test('covers every product type, so every card layout is reachable', () {
      final bundled = BookingsService.bundledBookings();
      final types = bundled.map((booking) => booking.type).toSet();

      expect(types, BookingType.values.toSet());
      expect(bundled.length, 5);
    });

    test('has an upcoming tour, not only a completed one', () {
      // The screen opens on Upcoming. With the tour fixture completed-only,
      // the Tours chip looked broken on the segment users land on.
      final now = DateTime.now();
      final upcomingTours = BookingsService.bundledBookings().where(
        (booking) =>
            booking.type == BookingType.tour &&
            booking.segment(now) == BookingTimeFilter.upcoming,
      );

      expect(upcomingTours, isNotEmpty);
    });

    test('mirrors tool/seed_bookings.js — ids and references must match', () {
      // The bundled list and the seed script are two copies of the same four
      // documents. If they drift, preview mode and the real screen show
      // different content and nobody notices until a review.
      final byId = {
        for (final booking in BookingsService.bundledBookings())
          booking.id: booking,
      };

      expect(byId.keys.toSet(), {
        'preview-hotel',
        'preview-flight',
        'preview-car',
        'preview-tour-upcoming',
        'preview-tour',
      });
      expect(byId['preview-hotel']!.bookingReference, 'HTL-7845123');
      expect(byId['preview-flight']!.bookingReference, 'FL-9856217');
      expect(byId['preview-car']!.bookingReference, 'CR-6623148');
      expect(byId['preview-tour-upcoming']!.bookingReference, 'TO-4471908');
      expect(byId['preview-tour']!.bookingReference, 'TO-122534');
    });

    test('every reference carries its type prefix', () {
      for (final booking in BookingsService.bundledBookings()) {
        expect(
          booking.bookingReference,
          startsWith('${booking.type.referencePrefix}-'),
          reason: booking.id,
        );
      }
    });

    test('every fixture has all three languages on every visible string', () {
      // The whole app is trilingual; a fixture missing Kurdish would silently
      // fall back to English and hide a real gap during review.
      for (final booking in BookingsService.bundledBookings()) {
        for (final code in ['en', 'ku', 'ar']) {
          expect(
            booking.display.title(code),
            isNotEmpty,
            reason: '${booking.id} title/$code',
          );
          expect(
            booking.display.locationLabel(code),
            isNotEmpty,
            reason: '${booking.id} location/$code',
          );
        }
        // Distinct per language, i.e. actually translated rather than the
        // English string copied into all three slots.
        expect(
          {
            booking.display.title('en'),
            booking.display.title('ku'),
            booking.display.title('ar'),
          }.length,
          greaterThan(1),
          reason: '${booking.id} title is not translated',
        );
      }
    });

    test('exercises both sides of the time axis', () {
      // Four trips ahead and one behind, so Upcoming and Past both have
      // content to show during review without waiting for a date to pass.
      final now = DateTime.now();
      final segments = BookingsService.bundledBookings()
          .map((booking) => booking.segment(now))
          .toList();

      expect(
        segments.where((s) => s == BookingTimeFilter.upcoming),
        isNotEmpty,
      );
      expect(segments.where((s) => s == BookingTimeFilter.past), isNotEmpty);
    });

    test('the flight fixture carries everything the boarding pass draws', () {
      final flight = BookingsService.bundledBookings().firstWhere(
        (booking) => booking.type == BookingType.flight,
      );

      expect(flight.display.fromCode, isNotEmpty);
      expect(flight.display.toCode, isNotEmpty);
      expect(flight.display.durationMinutes, isNotNull);
      expect(flight.display.cabinClass, isNotNull);
      expect(flight.display.seat, isNotNull);
    });

    test('dates are internally consistent', () {
      for (final booking in BookingsService.bundledBookings()) {
        final end = booking.endAt;
        expect(end, isNotNull, reason: booking.id);
        expect(
          end!.isBefore(booking.startAt),
          isFalse,
          reason: '${booking.id} ends before it starts',
        );
      }
    });
  });

  group('BookingsService — the read-only contract', () {
    test('reads the collection the rules are written against', () {
      // `firestore.rules` grants owner-read on `bookings` and denies every
      // client write. If this constant is ever renamed without the rules
      // following, the screen silently falls through to the catch-all deny.
      expect(BookingsService.collection, 'bookings');
      expect(BookingsService.fetchLimit, 50);
    });
  });
}
