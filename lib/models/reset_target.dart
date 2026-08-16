/// Which contact channel the user chose on the Forget Password screen, and
/// the address/number the verification code is being sent to.
///
/// Shared by Forget Password (which picks it) and Verification Code (which
/// displays it and sends/verifies against it).
enum ResetMethod { phone, email }

class ResetTarget {
  const ResetTarget({
    required this.method,
    required this.value,
    required this.maskedValue,
  });

  final ResetMethod method;

  /// The real destination — an E.164 phone number or an email address.
  /// Never shown in the UI; only used for the send/verify calls.
  final String value;

  /// What the user sees, e.g. `*** *** 9042` or `*******sa@gmail.com`.
  /// Masking happens server-side in the real flow so the client never needs
  /// the full address just to render this screen.
  final String maskedValue;

  bool get isPhone => method == ResetMethod.phone;
}
