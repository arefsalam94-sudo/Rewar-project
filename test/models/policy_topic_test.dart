import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/models/policy_topic.dart';
import 'package:kurdistan_paradise_travel_guide/services/legal_document_service.dart';

void main() {
  group('PolicyTopic', () {
    test('is the seven categories the Policy screen draws, in order', () {
      expect(PolicyTopic.values, [
        PolicyTopic.privacy,
        PolicyTopic.terms,
        PolicyTopic.cancellation,
        PolicyTopic.payment,
        PolicyTopic.liability,
        PolicyTopic.contact,
        PolicyTopic.accountDeletion,
      ]);
    });

    test('every docId is unique and snake_case', () {
      final ids = PolicyTopic.values.map((t) => t.docId).toList();
      expect(ids.toSet().length, ids.length);
      for (final id in ids) {
        expect(id, matches(RegExp(r'^[a-z][a-z0-9_]*$')), reason: id);
      }
    });

    test('the Terms row points at the document the Register flow already '
        'reads, not a second copy of the agreement', () {
      // If these ever diverge, a user could accept one wording and read
      // another — consent is recorded against `legal_documents/terms_of_service`.
      expect(PolicyTopic.terms.docId, LegalDocumentService.termsDocId);
    });
  });
}
