import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/models/help_topic.dart';

void main() {
  group('HelpTopic', () {
    test('contains the ten help categories in display order', () {
      expect(HelpTopic.values, [
        HelpTopic.account,
        HelpTopic.bookings,
        HelpTopic.payments,
        HelpTopic.cancellation,
        HelpTopic.flights,
        HelpTopic.stays,
        HelpTopic.carRental,
        HelpTopic.tours,
        HelpTopic.safety,
        HelpTopic.contact,
      ]);
    });

    test('every future Firestore document id is unique and snake_case', () {
      final ids = HelpTopic.values.map((topic) => topic.docId).toList();
      expect(ids.toSet(), hasLength(ids.length));
      for (final id in ids) {
        expect(id, matches(RegExp(r'^[a-z][a-z0-9_]*$')), reason: id);
      }
    });
  });
}
