/// The categories listed on the Help & Support screen, in the order drawn.
///
/// [docId] is the id each one will take in the `help_topics` Firestore
/// collection once its bundled questions and answers move to live content —
/// fixed here so the app, a seed script and the admin panel can never drift on
/// naming, the same arrangement `PolicyTopic` uses for `legal_documents`.
enum HelpTopic {
  account('account_signin'),
  bookings('bookings_confirmation'),
  payments('payments_refunds'),
  cancellation('cancellation_changes'),
  flights('flights'),
  stays('stays_hotels'),
  carRental('car_rental'),
  tours('tours_nature'),
  safety('safety_travel_info'),

  /// The odd one out: not a question category but a route to a human. Kept in
  /// the same list because the reference draws it as the tenth row, with the
  /// same styling and the same expand control.
  contact('contact_support');

  const HelpTopic(this.docId);

  /// The future live `help_topics/{docId}` source for this row.
  final String docId;
}
