/// The policy categories listed on the Policy screen, in the order drawn.
///
/// [docId] is the id each one will take in the `legal_documents` collection
/// once its wording exists — recorded here so the app, the seed script and the
/// admin panel can never drift on the naming. Nothing reads these yet: every
/// row on the Policy screen is deliberately inert until the documents have
/// been written (see `PROGRESS.md`).
enum PolicyTopic {
  privacy('privacy_policy'),

  /// Already seeded-in-spirit: `legal_documents/terms_of_service` is the
  /// document the Register screen's Terms of Service page reads. This row will
  /// open the same document rather than a second copy of it.
  terms('terms_of_service'),

  cancellation('cancellation_refunds'),
  payment('payment_policy'),
  liability('liability_disclaimer'),
  contact('contact_complaints'),

  /// Not in the reference screenshot. Added deliberately: both the App Store
  /// and Play Store require an in-app route to account and data deletion for
  /// any app that lets a user create an account, so a Policy hub without it is
  /// a store-review risk rather than a stylistic choice.
  accountDeletion('account_data_deletion');

  const PolicyTopic(this.docId);

  /// The `legal_documents/{docId}` this topic will read once it has content.
  final String docId;
}
