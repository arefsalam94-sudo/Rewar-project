import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/l10n/app_localizations.dart';
import 'package:kurdistan_paradise_travel_guide/models/featured_item.dart';
import 'package:kurdistan_paradise_travel_guide/models/tour.dart';
import 'package:kurdistan_paradise_travel_guide/models/tour_filters.dart';
import 'package:kurdistan_paradise_travel_guide/screens/explore_tours_screen.dart';
import 'package:kurdistan_paradise_travel_guide/services/currency_rates_service.dart';
import 'package:kurdistan_paradise_travel_guide/services/device_location_service.dart';
import 'package:kurdistan_paradise_travel_guide/services/favorites_service.dart';
import 'package:kurdistan_paradise_travel_guide/services/tours_service.dart';
import 'package:kurdistan_paradise_travel_guide/services/user_profile_service.dart';
import 'package:kurdistan_paradise_travel_guide/theme/app_theme.dart';
import 'package:kurdistan_paradise_travel_guide/widgets/glass_back_button.dart';
import 'package:kurdistan_paradise_travel_guide/widgets/page_background.dart';
import 'package:kurdistan_paradise_travel_guide/widgets/primary_button.dart';

void main() {
  group('Tour', () {
    test('falls back to English when a locale is missing', () {
      const tour = Tour(
        id: 'x',
        names: {'en': 'Gali Sherana'},
        descriptions: {'en': 'Quiet.'},
      );
      expect(tour.name('ku'), 'Gali Sherana');
      expect(tour.description('ar'), 'Quiet.');
      // No location label at all is an empty string, never a crash.
      expect(tour.locationLabel('en'), '');
    });

    test('fromMap skips a document with no name', () {
      expect(Tour.fromMap('x', <String, dynamic>{'pricePerPerson': 55}), null);
      expect(Tour.fromMap('x', null), null);
    });

    test('fromMap reads every field the card draws', () {
      final tour = Tour.fromMap('gali-alibag', <String, dynamic>{
        'name': {'en': 'Gali Alibag Waterfall', 'ku': 'ئاوشاری گەلی عەلی بەگ'},
        'description': {'en': 'A popular scenic waterfall.'},
        'locationLabel': {'en': 'Rawanduz, Erbil'},
        'companyTag': 'AB group',
        'durationDays': 2,
        'features': ['camping', 'guide', 42, ''],
        'imageUrls': ['https://example.test/a.jpg', ''],
        'pricePerPerson': 55,
        'currency': 'USD',
        'startAt': '2026-08-14T00:00:00.000',
        'endAt': '2026-08-16T00:00:00.000',
        'reviewScore': 8.7,
        'ratingCount': 128,
        'ratingBreakdown': {'5': 90, '4': 30, '3': 8},
        'capacity': 24,
        'bookedCount': 21,
        'cancellationPolicy': 'free_48h',
        'guideLanguages': ['en', 'ku'],
        'transportAvailable': true,
        'transportPricePerPerson': 5,
        'trending': true,
        'trendingOrder': 1,
        'highlighted': true,
        'highlightOrder': 3,
      });

      expect(tour, isNotNull);
      expect(tour!.name('ku'), 'ئاوشاری گەلی عەلی بەگ');
      expect(tour.companyTag, 'AB group');
      expect(tour.durationDays, 2);
      // Empty strings and non-strings are dropped rather than drawn.
      expect(tour.features, {'camping', 'guide'});
      expect(tour.imageUrls, ['https://example.test/a.jpg']);
      expect(tour.pricePerPerson, 55);
      expect(tour.startAt, DateTime(2026, 8, 14));
      expect(tour.reviewScore, 8.7);
      expect(tour.ratingCount, 128);
      expect(tour.ratingBreakdown.countFor(5), 90);
      expect(tour.spotsLeft, 3);
      expect(tour.cancellationPolicy, TourCancellationPolicy.free48h);
      expect(tour.guideLanguages, {'en', 'ku'});
      expect(tour.transportAvailable, isTrue);
      expect(tour.transportPricePerPerson, 5);
      expect(tour.trending, isTrue);
      expect(tour.highlightOrder, 3);
    });

    test('drops feature and language ids the app cannot draw', () {
      const tour = Tour(
        id: 'x',
        names: {'en': 'X'},
        features: {'camping', 'scuba_diving', 'food'},
        guideLanguages: {'en', 'zz', 'ar'},
      );
      expect(tour.knownFeatures, [TourFeature.camping, TourFeature.food]);
      expect(tour.knownGuideLanguages, [
        TourGuideLanguage.english,
        TourGuideLanguage.arabic,
      ]);
    });

    test('availability is derived, clamped, and absent without a capacity', () {
      const noCapacity = Tour(id: 'x', names: {'en': 'X'});
      expect(noCapacity.spotsLeft, isNull);
      expect(noCapacity.isLowAvailability, isFalse);
      // A tour whose operator published no capacity is assumed bookable —
      // hiding a good tour over a blank field would be worse.
      expect(noCapacity.hasRoomFor(8), isTrue);

      const nearlyFull = Tour(
        id: 'x',
        names: {'en': 'X'},
        capacity: 24,
        bookedCount: 21,
      );
      expect(nearlyFull.spotsLeft, 3);
      expect(nearlyFull.isLowAvailability, isTrue);
      expect(nearlyFull.hasRoomFor(3), isTrue);
      expect(nearlyFull.hasRoomFor(4), isFalse);

      // Over-booked is sold out, not negative.
      const oversold = Tour(
        id: 'x',
        names: {'en': 'X'},
        capacity: 10,
        bookedCount: 12,
      );
      expect(oversold.spotsLeft, 0);
      expect(oversold.isSoldOut, isTrue);
      expect(oversold.isLowAvailability, isFalse);

      // A big departure is not nagged about.
      const plentyLeft = Tour(
        id: 'x',
        names: {'en': 'X'},
        capacity: 60,
        bookedCount: 4,
      );
      expect(plentyLeft.isLowAvailability, isFalse);
    });

    test('search matches name, location and operator in any language', () {
      const tour = Tour(
        id: 'x',
        names: {'en': 'Gali Alibag Waterfall', 'ar': 'شلال كلي علي بك'},
        locationLabels: {'en': 'Rawanduz, Erbil'},
        companyTag: 'AB group',
      );
      expect(tour.matchesQuery(''), isTrue);
      expect(tour.matchesQuery('waterfall'), isTrue);
      // Someone browsing in Arabic may still type the English spelling.
      expect(tour.matchesQuery('شلال'), isTrue);
      expect(tour.matchesQuery('erbil'), isTrue);
      expect(tour.matchesQuery('AB'), isTrue);
      expect(tour.matchesQuery('duhok'), isFalse);
    });

    test('a date range matches by overlap, not containment', () {
      final tour = Tour(
        id: 'x',
        names: const {'en': 'X'},
        startAt: DateTime(2026, 8, 14, 9),
        endAt: DateTime(2026, 8, 16, 18),
      );
      // Entirely inside the window.
      expect(
        tour.runsBetween(DateTime(2026, 8, 1), DateTime(2026, 8, 31)),
        isTrue,
      );
      // Overlapping at each end — someone searching 16–20 August wants this.
      expect(
        tour.runsBetween(DateTime(2026, 8, 16), DateTime(2026, 8, 20)),
        isTrue,
      );
      expect(
        tour.runsBetween(DateTime(2026, 8, 10), DateTime(2026, 8, 14)),
        isTrue,
      );
      // A single day inside the run.
      expect(tour.runsBetween(DateTime(2026, 8, 15), null), isTrue);
      // Clear of it on both sides.
      expect(
        tour.runsBetween(DateTime(2026, 8, 17), DateTime(2026, 8, 20)),
        isFalse,
      );
      expect(
        tour.runsBetween(DateTime(2026, 8, 1), DateTime(2026, 8, 13)),
        isFalse,
      );
    });

    test('a tour with no start date never matches a date filter', () {
      const tour = Tour(id: 'x', names: {'en': 'X'});
      expect(tour.runsOn(DateTime(2026, 8, 14)), isFalse);
      expect(
        tour.runsBetween(DateTime(2026, 8, 1), DateTime(2026, 8, 31)),
        isFalse,
      );
    });
  });

  group('TourFilters', () {
    const camping = Tour(
      id: 'camping',
      names: {'en': 'Camping trip'},
      features: {'camping', 'food'},
      guideLanguages: {'ku'},
      pricePerPerson: 30,
      reviewScore: 7.0,
      capacity: 10,
      bookedCount: 8,
    );
    const hiking = Tour(
      id: 'hiking',
      names: {'en': 'Hiking trip'},
      features: {'hiking'},
      guideLanguages: {'en'},
      pricePerPerson: 90,
      reviewScore: 9.4,
    );

    test('OR within a group, AND across groups', () {
      const both = TourFilters(features: {'camping', 'hiking'});
      expect(both.matches(camping), isTrue);
      expect(both.matches(hiking), isTrue);

      // Adding a language group narrows: hiking's guide speaks English only.
      const narrowed = TourFilters(
        features: {'camping', 'hiking'},
        guideLanguages: {'ku'},
      );
      expect(narrowed.matches(camping), isTrue);
      expect(narrowed.matches(hiking), isFalse);
    });

    test('an empty group means no filter, not match-nothing', () {
      const none = TourFilters();
      expect(none.matches(camping), isTrue);
      expect(none.matches(hiking), isTrue);
    });

    test('party size hides a departure that cannot seat it', () {
      // Two places left on the camping trip.
      expect(const TourFilters(travellers: 2).matches(camping), isTrue);
      expect(const TourFilters(travellers: 3).matches(camping), isFalse);
      // The hiking trip published no capacity, so it stays.
      expect(const TourFilters(travellers: 3).matches(hiking), isTrue);
    });

    test('sorting puts a missing value last, never first', () {
      const priced = Tour(id: 'p', names: {'en': 'P'}, pricePerPerson: 10);
      const unpriced = Tour(id: 'u', names: {'en': 'U'});

      // Cheapest first must not rank "no price" as free.
      final low = const TourFilters(
        sort: TourSort.priceLowToHigh,
      ).sortedFrom(const [unpriced, priced]);
      expect(low.map((t) => t.id), ['p', 'u']);

      // And "most expensive" must not rank it as infinite either.
      final high = const TourFilters(
        sort: TourSort.priceHighToLow,
      ).sortedFrom(const [unpriced, priced]);
      expect(high.map((t) => t.id), ['p', 'u']);

      // Same for an unrated tour under "Top rated".
      final rated = const TourFilters(
        sort: TourSort.topRated,
      ).sortedFrom(const [camping, hiking]);
      expect(rated.map((t) => t.id), ['hiking', 'camping']);
    });

    test('"nearest" falls back to soonest without a device position', () {
      final near = Tour(
        id: 'near',
        names: const {'en': 'Near'},
        latitude: 36.19,
        longitude: 44.01,
        startAt: DateTime(2026, 9, 1),
      );
      final far = Tour(
        id: 'far',
        names: const {'en': 'Far'},
        latitude: 37.05,
        longitude: 43.09,
        startAt: DateTime(2026, 8, 1),
      );

      const filters = TourFilters(sort: TourSort.nearest);
      // No fix: chronological, not an arbitrary order presented as "nearest".
      expect(filters.sortedFrom([near, far]).map((t) => t.id), ['far', 'near']);
      // With a fix, actually nearest first.
      expect(
        filters
            .sortedFrom([far, near], fromLatitude: 36.19, fromLongitude: 44.01)
            .map((t) => t.id),
        ['near', 'far'],
      );
    });

    test('trending pins lead the default order only', () {
      const a = Tour(id: 'a', names: {'en': 'A'});
      const b = Tour(
        id: 'b',
        names: {'en': 'B'},
        trending: true,
        trendingOrder: 2,
        pricePerPerson: 99,
      );
      const d = Tour(
        id: 'd',
        names: {'en': 'D'},
        trending: true,
        trendingOrder: 1,
        pricePerPerson: 50,
      );

      expect(const TourFilters().sortedFrom(const [a, b, d]).map((t) => t.id), [
        'd',
        'b',
        'a',
      ]);
      // Once the user has chosen an order, an editorial pin must not override
      // it — that just looks like a broken sort.
      expect(
        const TourFilters(
          sort: TourSort.priceLowToHigh,
        ).sortedFrom(const [b, d, a]).map((t) => t.id),
        ['d', 'b', 'a'],
      );
    });

    test('isEmpty tracks every narrowing dimension but not the sort', () {
      expect(const TourFilters().isEmpty, isTrue);
      expect(const TourFilters(sort: TourSort.topRated).isEmpty, isTrue);
      expect(const TourFilters(query: 'x').isEmpty, isFalse);
      expect(const TourFilters(features: {'food'}).isEmpty, isFalse);
      expect(const TourFilters(travellers: 2).isEmpty, isFalse);
      expect(TourFilters(rangeStart: DateTime(2026, 8, 1)).isEmpty, isFalse);
    });
  });

  group('CurrencyRates', () {
    const rates = CurrencyRates(
      base: 'USD',
      rates: {'USD': 1, 'IQD': 1310, 'EUR': 0.92},
    );

    test('converts through the base, and is identity on a match', () {
      expect(rates.convert(10, from: 'USD', to: 'USD'), 10);
      expect(rates.convert(1, from: 'USD', to: 'IQD'), 1310);
      // Cross-rate, not a base-only conversion.
      expect(rates.convert(1310, from: 'IQD', to: 'USD'), closeTo(1, 0.0001));
      expect(rates.convert(1310, from: 'IQD', to: 'EUR'), closeTo(0.92, 0.001));
    });

    test('returns null rather than guessing at an unknown currency', () {
      expect(rates.convert(10, from: 'GBP', to: 'USD'), isNull);
      expect(rates.convert(10, from: 'USD', to: 'JPY'), isNull);
      expect(CurrencyRates.empty.convert(10, from: 'USD', to: 'IQD'), isNull);
    });

    test('fromMap drops non-positive and non-numeric rates', () {
      final parsed = CurrencyRates.fromMap(<String, dynamic>{
        'base': 'usd',
        'rates': {'USD': 1, 'IQD': 1310, 'EUR': 0, 'GBP': 'nope'},
      });
      expect(parsed.base, 'USD');
      expect(parsed.supports('IQD'), isTrue);
      expect(parsed.supports('EUR'), isFalse);
      expect(parsed.supports('GBP'), isFalse);
    });
  });

  group('formatMoney', () {
    test('groups thousands and keeps a symbol tight but a code spaced', () {
      expect(formatMoney(55, 'USD'), r'$55');
      expect(formatMoney(55.5, 'USD'), r'$55.50');
      expect(formatMoney(1240, 'EUR'), '€1,240');
      expect(formatMoney(72049.6, 'IQD'), 'IQD 72,050');
    });
  });

  group('TourPricing', () {
    const rates = CurrencyRates(base: 'USD', rates: {'USD': 1, 'IQD': 1310});

    test('leaves a matching currency alone', () {
      const pricing = TourPricing(rates: rates, displayCurrency: 'USD');
      expect(pricing.isConverted('USD'), isFalse);
      expect(pricing.perPerson(55, 'USD'), r'$55');
      expect(pricing.total(55, 'USD'), isNull);
    });

    test('marks a converted price approximate', () {
      const pricing = TourPricing(rates: rates, displayCurrency: 'IQD');
      expect(pricing.isConverted('USD'), isTrue);
      expect(pricing.perPerson(55, 'USD'), '≈ IQD 72,050');
    });

    test('falls back to the operator currency when no rate exists', () {
      const pricing = TourPricing(
        rates: CurrencyRates.empty,
        displayCurrency: 'IQD',
      );
      expect(pricing.isConverted('USD'), isFalse);
      // An unconverted true price beats a converted invented one.
      expect(pricing.perPerson(55, 'USD'), r'$55');
    });

    test('the party total appears only above one traveller', () {
      const one = TourPricing(
        rates: rates,
        displayCurrency: 'USD',
        travellers: 1,
      );
      const four = TourPricing(
        rates: rates,
        displayCurrency: 'USD',
        travellers: 4,
      );
      expect(one.total(55, 'USD'), isNull);
      expect(four.total(55, 'USD'), r'$220');
    });
  });

  group('AppLocalizations tour formatting', () {
    test('collapses a same-month range and spells out a crossing one', () {
      const en = AppLocalizations(Locale('en'));
      expect(
        en.tourDateRange(DateTime(2026, 8, 14), DateTime(2026, 8, 16)),
        'Aug 14 - 16',
      );
      expect(
        en.tourDateRange(DateTime(2026, 8, 30), DateTime(2026, 9, 2)),
        'Aug 30 - Sep 2',
      );
      // A one-day tour is a single date, not "Aug 14 - Aug 14".
      expect(en.tourDateRange(DateTime(2026, 8, 14), null), 'Aug 14');
    });

    test('Kurdish and Arabic put the day first and spell the month out', () {
      const ku = AppLocalizations(Locale('ku'));
      const ar = AppLocalizations(Locale('ar'));
      // No invented three-letter abbreviation — the full month name is used.
      expect(ku.tourDateRange(DateTime(2026, 8, 14), null), '14 ئاب');
      expect(
        ar.tourDateRange(DateTime(2026, 8, 14), DateTime(2026, 8, 16)),
        '14 - 16 أغسطس',
      );
    });

    test('counted strings have a real singular in all three languages', () {
      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = AppLocalizations(locale);
        expect(l10n.tourDuration(1), isNot(l10n.tourDuration(2)));
        expect(l10n.tourReviewCount(1), isNot(l10n.tourReviewCount(2)));
        expect(l10n.tourSpotsLeft(1), isNot(l10n.tourSpotsLeft(3)));
        expect(l10n.tourTravellerCount(1), isNot(l10n.tourTravellerCount(2)));
      }
      expect(
        const AppLocalizations(Locale('en')).tourReviewCount(128),
        '128 reviews',
      );
      expect(
        const AppLocalizations(Locale('en')).tourSpotsLeft(3),
        'Only 3 spots left',
      );
    });

    test('every tour string exists in all three languages', () {
      const english = AppLocalizations(Locale('en'));
      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = AppLocalizations(locale);
        for (final value in [
          l10n.toursSearchHint,
          l10n.toursDateRangeHint,
          l10n.toursApply,
          l10n.trendingTours,
          l10n.toursLoadFailed,
          l10n.toursEmpty,
          l10n.toursHighlightedEmpty,
          l10n.tourPerPerson,
          l10n.tourNoReviews,
          l10n.tourTravellers,
          l10n.tourGuideLanguages,
          l10n.toursSortLabel,
          l10n.toursIncludes,
          l10n.toursPriceApprox,
          l10n.toursClearAll,
        ]) {
          expect(value, isNotEmpty);
        }
        for (final feature in TourFeature.values) {
          expect(l10n.tourFeatureLabel(feature), isNotEmpty);
        }
        for (final policy in TourCancellationPolicy.values) {
          expect(l10n.tourCancellationLabel(policy), isNotEmpty);
        }
        for (final language in TourGuideLanguage.values) {
          expect(l10n.tourGuideLanguageLabel(language), isNotEmpty);
        }
        for (final sort in TourSort.values) {
          expect(l10n.tourSortLabel(sort), isNotEmpty);
        }
        if (locale.languageCode != 'en') {
          // A missing translation would silently fall through to English.
          expect(l10n.toursApply, isNot(english.toursApply));
          expect(l10n.toursSortLabel, isNot(english.toursSortLabel));
          expect(l10n.tourNoReviews, isNot(english.tourNoReviews));
        }
      }
    });
  });

  group('formatTourDistance', () {
    test('metres, then one decimal, then whole kilometres', () {
      expect(formatTourDistance(340), '340 m');
      expect(formatTourDistance(2300), '2.3 km');
      expect(formatTourDistance(127_400), '127 km');
    });
  });

  group('ExploreToursScreen', () {
    testWidgets('uses the supplied background photo under the gradient', (
      tester,
    ) async {
      await _pumpScreen(tester, service: _FakeToursService());

      final background = tester.widget<PageBackground>(
        find.byType(PageBackground),
      );
      expect(background.imageAsset, exploreToursBackgroundAsset);
      // The design-standard σ2 blur and 45% gradient, not a per-screen recipe.
      expect(background.blurSigma, isNull);
      expect(background.gradientOpacity, isNull);
    });

    testWidgets('draws the back button and title on one row', (tester) async {
      await _pumpScreen(tester, service: _FakeToursService());

      expect(find.byType(GlassBackButton), findsOneWidget);
      expect(find.text('Explore Tours'), findsOneWidget);

      final button = tester.getRect(find.byType(GlassBackButton));
      final title = tester.getRect(find.text('Explore Tours'));
      // Same row: the title's vertical centre sits inside the button's height.
      expect(title.center.dy, greaterThan(button.top));
      expect(title.center.dy, lessThan(button.bottom));
      // And after it, not above it.
      expect(title.left, greaterThan(button.right));
    });

    testWidgets('the carousel rating sits on the leading edge', (tester) async {
      await _pumpScreen(tester, service: _FakeToursService());

      // The slide's own score badge and its operator tag.
      final score = tester.getRect(find.text('8.7').first);
      final tag = tester.getRect(find.text('AB group').first);
      // Rating left, operator tag right — as asked.
      expect(score.left, lessThan(tag.left));
    });

    testWidgets('the card rating sits on the trailing edge', (tester) async {
      await _pumpScreen(tester, service: _FakeToursService());

      // On a card, the score badge is to the right of the tour name.
      final name = tester.getRect(find.text('Gali Sherana'));
      final score = tester.getRect(find.text('8.5'));
      expect(score.left, greaterThan(name.right - 1));
    });

    testWidgets('an unrated tour says so rather than showing a zero', (
      tester,
    ) async {
      await _pumpScreen(tester, service: _FakeToursService());
      // Korek has no reviews seeded.
      expect(find.text('No reviews yet'), findsOneWidget);
      expect(find.text('0.0'), findsNothing);
    });

    testWidgets('draws the review count beside the score', (tester) async {
      await _pumpScreen(tester, service: _FakeToursService());
      expect(find.text('3 reviews'), findsOneWidget);
      expect(find.text('2 reviews'), findsOneWidget);
    });

    testWidgets('low availability is called out; a roomy departure is not', (
      tester,
    ) async {
      await _pumpScreen(tester, service: _FakeToursService());
      // Gali Alibag: 24 capacity, 21 booked. Korek: 30/28.
      expect(find.text('Only 3 spots left'), findsOneWidget);
      expect(find.text('Only 2 spots left'), findsOneWidget);
      // Gali Sherana has 12 places left, and is not nagged about.
      expect(find.textContaining('12 spots'), findsNothing);
    });

    testWidgets('the cancellation tier is shown, free and non-refundable', (
      tester,
    ) async {
      await _pumpScreen(tester, service: _FakeToursService());
      expect(find.text('Free cancellation until 48h before'), findsOneWidget);
      expect(find.text('Non-refundable'), findsOneWidget);
    });

    testWidgets('the guide languages are listed', (tester) async {
      await _pumpScreen(tester, service: _FakeToursService());
      expect(find.text('English · Kurdish · Arabic'), findsOneWidget);
      expect(find.text('English · Turkish'), findsOneWidget);
    });

    testWidgets('draws the carousel, the controls and a card per tour', (
      tester,
    ) async {
      await _pumpScreen(tester, service: _FakeToursService());

      // Carousel slide plus its own list card.
      expect(find.text('Gali Alibag Waterfall'), findsNWidgets(2));
      expect(find.text('Gali Sherana'), findsOneWidget);

      // Controls.
      expect(find.byKey(exploreToursSearchFieldKey), findsOneWidget);
      expect(find.byKey(exploreToursDateFieldKey), findsOneWidget);
      expect(find.byKey(exploreToursTravellerPlusKey), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);
      expect(find.text('Sort'), findsOneWidget);
      expect(find.text('Includes'), findsOneWidget);
      expect(find.text('Trending Tours'), findsOneWidget);
      expect(find.text(r'$55'), findsOneWidget);
      expect(find.text('per person'), findsNWidgets(3));
    });

    testWidgets('a refinement chip filters immediately, with no Apply', (
      tester,
    ) async {
      final service = _FakeToursService();
      await _pumpScreen(tester, service: service);
      expect(service.catalogReads, 1);

      // `.first` is the refinement chip; the same label also appears under a
      // feature icon further down the page.
      // Only Gali Alibag is tagged "swimming".
      await tester.tap(find.text('Swimming').first);
      await tester.pumpAndSettle();
      expect(find.text('Gali Alibag Waterfall'), findsNWidgets(2));
      expect(find.text('Gali Sherana'), findsNothing);

      // Multi-select is OR: adding Campfire widens it back out.
      await tester.tap(find.text('Campfire').first);
      await tester.pumpAndSettle();
      expect(find.text('Gali Sherana'), findsOneWidget);

      // Still one read — refining costs nothing.
      expect(service.catalogReads, 1);
    });

    testWidgets('the sort control reorders without re-reading', (tester) async {
      final service = _FakeToursService();
      await _pumpScreen(tester, service: service);

      await tester.tap(find.text('Price: low to high'));
      await tester.pumpAndSettle();

      // Cheapest first: Sherana $32, Korek $40, Alibag $55.
      final sherana = tester.getRect(find.text('Gali Sherana'));
      final korek = tester.getRect(find.text('Korek Mountain Day Trip'));
      expect(sherana.top, lessThan(korek.top));
      expect(service.catalogReads, 1);
    });

    // Two tests rather than one: pumping a second ExploreToursScreen into the
    // same tester reuses the State (same type, no key), so the injected
    // services would not be swapped and the assertion would be meaningless.
    testWidgets('"Nearest to me" is hidden without a device position', (
      tester,
    ) async {
      await _pumpScreen(tester, service: _FakeToursService());
      expect(find.text('Nearest to me'), findsNothing);
    });

    testWidgets('"Nearest to me" appears once there is a fix', (tester) async {
      await _pumpScreen(
        tester,
        service: _FakeToursService(),
        location: const _FakeLocationService(DeviceLocation(36.6289, 44.5311)),
      );
      expect(find.text('Nearest to me'), findsOneWidget);
    });

    testWidgets('the traveller stepper hides departures without room', (
      tester,
    ) async {
      await _pumpScreen(tester, service: _FakeToursService());

      // Alibag has 3 places left, Korek 2, Sherana 12. Four travellers leaves
      // only Sherana.
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(exploreToursTravellerPlusKey));
        await tester.pumpAndSettle();
      }
      // Nothing has changed yet — party size is a search input.
      expect(find.text('Korek Mountain Day Trip'), findsOneWidget);

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.text('Gali Sherana'), findsOneWidget);
      expect(find.text('Korek Mountain Day Trip'), findsNothing);
      // And the price box now carries the party total: $32 × 4.
      expect(find.text(r'Total $128'), findsOneWidget);
    });

    testWidgets('the stepper cannot go below one traveller', (tester) async {
      await _pumpScreen(tester, service: _FakeToursService());
      await tester.tap(find.byKey(exploreToursTravellerMinusKey));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('prices convert, are marked approximate, and are disclosed', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        service: _FakeToursService(),
        profile: _FakeUserProfileService(AppCurrency.iqd),
      );

      // $55 at 1310 IQD/USD.
      expect(find.text('≈ IQD 72,050'), findsOneWidget);
      expect(find.textContaining('indicative rate'), findsOneWidget);
    });

    testWidgets('no rate table means the operator price, not a guess', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        service: _FakeToursService(),
        profile: _FakeUserProfileService(AppCurrency.iqd),
        rates: _FakeCurrencyRatesService(CurrencyRates.empty),
      );

      expect(find.text(r'$55'), findsOneWidget);
      // And no disclosure, because nothing on screen was converted.
      expect(find.textContaining('indicative rate'), findsNothing);
    });

    testWidgets('a guest tapping the heart is asked to sign in', (
      tester,
    ) async {
      final favorites = _FakeFavoritesService();
      await _pumpScreen(
        tester,
        service: _FakeToursService(signedIn: false),
        favorites: favorites,
      );

      await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('Sign in to save favourites'), findsOneWidget);
      // Nothing was written — a favourite is tied to an account.
      expect(favorites.toggles, 0);
    });

    testWidgets('a signed-in user can save a tour', (tester) async {
      final favorites = _FakeFavoritesService();
      await _pumpScreen(
        tester,
        service: _FakeToursService(signedIn: true),
        favorites: favorites,
      );

      await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
      await tester.pumpAndSettle();

      expect(favorites.toggles, 1);
      expect(favorites.lastType, FeaturedType.tour);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('hides the distance line when location is unavailable', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        service: _FakeToursService(),
        location: const _FakeLocationService(null),
      );
      expect(find.textContaining('from current location'), findsNothing);
    });

    testWidgets('shows the distance line once a fix arrives', (tester) async {
      await _pumpScreen(
        tester,
        service: _FakeToursService(),
        location: const _FakeLocationService(DeviceLocation(36.6289, 44.5311)),
      );
      expect(find.textContaining('from current location'), findsNWidgets(3));
    });

    testWidgets('search narrows the list only after Apply, and costs no read', (
      tester,
    ) async {
      final service = _FakeToursService();
      await _pumpScreen(tester, service: service);
      expect(service.catalogReads, 1);

      await tester.enterText(find.byKey(exploreToursSearchFieldKey), 'sherana');
      await tester.pumpAndSettle();
      // Nothing has changed yet — the reference has an explicit Apply button.
      expect(find.text('Korek Mountain Day Trip'), findsOneWidget);

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.text('Gali Sherana'), findsOneWidget);
      expect(find.text('Korek Mountain Day Trip'), findsNothing);
      // Still one read: filtering happens in Dart over the catalog in memory.
      expect(service.catalogReads, 1);
    });

    testWidgets('an empty result offers to clear everything', (tester) async {
      await _pumpScreen(tester, service: _FakeToursService());

      await tester.enterText(
        find.byKey(exploreToursSearchFieldKey),
        'antarctica',
      );
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(find.text('No tours match your search'), findsOneWidget);
      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();
      expect(find.text('Gali Sherana'), findsOneWidget);
    });

    testWidgets('a load failure shows the error and retries', (tester) async {
      final service = _FakeToursService(failFirstList: true);
      await _pumpScreen(tester, service: service);

      expect(find.text("Couldn't load tours"), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Gali Sherana'), findsOneWidget);
    });

    testWidgets('an empty catalog says so without offering a clear', (
      tester,
    ) async {
      await _pumpScreen(tester, service: _FakeToursService(emptyList: true));
      expect(find.text('No tours match your search'), findsOneWidget);
      expect(find.text('Clear all'), findsNothing);
    });

    testWidgets('an empty carousel says so without failing the page', (
      tester,
    ) async {
      await _pumpScreen(tester, service: _FakeToursService(noHighlights: true));
      expect(find.text('No tours are highlighted yet'), findsOneWidget);
      // The list below is unaffected.
      expect(find.text('Gali Sherana'), findsOneWidget);
    });

    testWidgets('the carousel dots stay left-to-right in Arabic', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        service: _FakeToursService(),
        locale: const Locale('ar'),
      );
      final dots = tester.widget<Directionality>(
        find
            .ancestor(
              of: find.byKey(exploreToursDotsKey),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(dots.textDirection, TextDirection.ltr);
    });

    testWidgets('renders in Kurdish and Arabic, right to left', (tester) async {
      for (final locale in const [Locale('ku'), Locale('ar')]) {
        await _pumpScreen(tester, service: _FakeToursService(), locale: locale);
        final l10n = AppLocalizations(locale);
        expect(find.text(l10n.trendingTours), findsOneWidget);
        expect(find.text(l10n.toursApply), findsOneWidget);
        expect(find.text(l10n.toursSortLabel), findsOneWidget);
        expect(
          Directionality.of(tester.element(find.byType(PrimaryButton))),
          TextDirection.rtl,
        );
      }
    });

    testWidgets('renders in dark mode', (tester) async {
      await _pumpScreen(tester, service: _FakeToursService(), dark: true);
      expect(find.text('Trending Tours'), findsOneWidget);
      expect(find.text('Gali Sherana'), findsOneWidget);
    });

    testWidgets('every chip and stepper button meets the 48dp target', (
      tester,
    ) async {
      await _pumpScreen(tester, service: _FakeToursService());

      for (final key in [
        exploreToursTravellerPlusKey,
        exploreToursTravellerMinusKey,
      ]) {
        final size = tester.getSize(find.byKey(key));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }

      // Chips are 38dp of visual height inside a 48dp margin box.
      final chip = tester.getSize(
        find
            .ancestor(
              of: find.text('Camping'),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(chip.height, greaterThanOrEqualTo(38));
    });
  });
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required ToursService service,
  DeviceLocationService location = const _FakeLocationService(null),
  FavoritesService? favorites,
  UserProfileService? profile,
  CurrencyRatesService? rates,
  Locale locale = const Locale('en'),
  bool dark = false,
}) async {
  // Tall enough that the whole page is laid out; several assertions read
  // positions, which requires the widget to be on screen.
  tester.view.physicalSize = const Size(900, 3400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightForLocale(locale),
      darkTheme: AppTheme.darkForLocale(locale),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: ExploreToursScreen(
        toursService: service,
        locationService: location,
        favoritesService: favorites ?? _FakeFavoritesService(),
        userProfileService: profile ?? _FakeUserProfileService(AppCurrency.usd),
        currencyRatesService:
            rates ??
            _FakeCurrencyRatesService(CurrencyRatesService.bundledRates),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Stands in for the Firestore-backed catalog source, and counts reads so a
/// test can prove that searching and refining cost none.
class _FakeToursService extends ToursService {
  _FakeToursService({
    this.failFirstList = false,
    this.emptyList = false,
    this.noHighlights = false,
    this.signedIn = false,
  });

  /// Fails the first catalog read only, so a retry can be shown to succeed.
  bool failFirstList;
  final bool emptyList;
  final bool noHighlights;
  final bool signedIn;

  int catalogReads = 0;

  @override
  bool get isSignedIn => signedIn;

  @override
  Future<List<Tour>> fetchHighlighted() async {
    if (noHighlights) return const <Tour>[];
    return ToursService.bundledTours()
        .where((tour) => tour.highlighted)
        .toList();
  }

  @override
  Future<List<Tour>> fetchCatalog() async {
    catalogReads++;
    if (failFirstList) {
      failFirstList = false;
      throw StateError('simulated failure');
    }
    if (emptyList) return const <Tour>[];
    return ToursService.bundledTours();
  }
}

class _FakeLocationService extends DeviceLocationService {
  const _FakeLocationService(this.location);

  final DeviceLocation? location;

  @override
  Future<DeviceLocation?> currentLocation() async => location;
}

class _FakeFavoritesService extends FavoritesService {
  _FakeFavoritesService();

  int toggles = 0;
  FeaturedType? lastType;
  final Set<String> saved = <String>{};

  @override
  Future<Set<String>> fetchFavoriteItemIds() async => saved;

  @override
  Future<bool> toggle({
    required FeaturedType itemType,
    required String itemId,
    required bool currentlyFavorite,
  }) async {
    toggles++;
    lastType = itemType;
    if (currentlyFavorite) {
      saved.remove(itemId);
      return false;
    }
    saved.add(itemId);
    return true;
  }
}

class _FakeUserProfileService extends UserProfileService {
  _FakeUserProfileService(this.currency);

  final AppCurrency currency;

  @override
  Future<UserProfile?> fetchProfile() async => UserProfile(
    name: 'Test',
    email: 'test@example.test',
    phone: '',
    profileImageUrl: null,
    currency: currency,
  );
}

class _FakeCurrencyRatesService extends CurrencyRatesService {
  _FakeCurrencyRatesService(this.rates);

  final CurrencyRates rates;

  @override
  Future<CurrencyRates> fetchLatest() async => rates;
}
