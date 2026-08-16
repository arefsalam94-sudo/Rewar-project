import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/models/help_faq.dart';
import 'package:kurdistan_paradise_travel_guide/models/help_topic.dart';

void main() {
  test(
    'bundled FAQ covers the supplied nine categories and contact fallback',
    () {
      const expectedCounts = {
        HelpTopic.account: 6,
        HelpTopic.bookings: 5,
        HelpTopic.payments: 6,
        HelpTopic.cancellation: 4,
        HelpTopic.flights: 4,
        HelpTopic.stays: 5,
        HelpTopic.carRental: 5,
        HelpTopic.tours: 5,
        HelpTopic.safety: 3,
        HelpTopic.contact: 0,
      };

      expect(bundledHelpFaqs.keys.toSet(), HelpTopic.values.toSet());
      for (final topic in HelpTopic.values) {
        final entries = bundledHelpFaqsFor(topic);
        expect(entries.length, expectedCounts[topic], reason: '$topic');
        for (final entry in entries) {
          expect(entry.question.trim(), isNotEmpty, reason: '$topic question');
          expect(entry.answer.trim(), isNotEmpty, reason: '$topic answer');
        }
      }
    },
  );
}
