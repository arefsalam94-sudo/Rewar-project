import '../l10n/app_localizations.dart';

/// Gender options offered at registration. Optional by explicit decision —
/// `SECURITY.md` 9 says not to collect more than a screen needs, so this can
/// be left unset and is stored as null when skipped.
enum Gender {
  male('male'),
  female('female'),
  other('other');

  const Gender(this.value);

  /// What gets written to Firestore. Stable across languages — never store
  /// the translated label.
  final String value;

  String label(AppLocalizations l10n) => switch (this) {
    Gender.male => l10n.genderMale,
    Gender.female => l10n.genderFemale,
    Gender.other => l10n.genderOther,
  };
}

/// A dialling code the phone field can be prefixed with.
///
/// Deliberately a short, hand-kept list covering the region the app serves
/// plus the most common diaspora destinations, rather than a new dependency
/// for all ~200 countries. Easy to extend; revisit if the app goes wider.
class CountryCode {
  const CountryCode({
    required this.flag,
    required this.dialCode,
    required this.isoCode,
    required this.nationalDigits,
  });

  final String flag;

  /// Including the leading `+`, e.g. `+964`.
  final String dialCode;

  final String isoCode;

  /// Expected length of the number *after* the dial code and after any
  /// leading trunk `0` is stripped. Used for a light sanity check only — the
  /// real validation is Firebase failing to send the SMS.
  final int nationalDigits;

  /// Iraq first: it is the app's primary market, so it is the default.
  static const List<CountryCode> all = [
    CountryCode(
      flag: '🇮🇶',
      dialCode: '+964',
      isoCode: 'IQ',
      nationalDigits: 10,
    ),
    CountryCode(
      flag: '🇹🇷',
      dialCode: '+90',
      isoCode: 'TR',
      nationalDigits: 10,
    ),
    CountryCode(
      flag: '🇮🇷',
      dialCode: '+98',
      isoCode: 'IR',
      nationalDigits: 10,
    ),
    CountryCode(
      flag: '🇸🇾',
      dialCode: '+963',
      isoCode: 'SY',
      nationalDigits: 9,
    ),
    CountryCode(
      flag: '🇦🇪',
      dialCode: '+971',
      isoCode: 'AE',
      nationalDigits: 9,
    ),
    CountryCode(
      flag: '🇬🇧',
      dialCode: '+44',
      isoCode: 'GB',
      nationalDigits: 10,
    ),
    CountryCode(
      flag: '🇩🇪',
      dialCode: '+49',
      isoCode: 'DE',
      nationalDigits: 10,
    ),
    CountryCode(
      flag: '🇺🇸',
      dialCode: '+1',
      isoCode: 'US',
      nationalDigits: 10,
    ),
  ];

  static CountryCode get defaultCountry => all.first;

  /// Builds the E.164 string Firebase phone auth requires, e.g.
  /// `+9647500009042`. Strips spaces and the leading trunk `0` people
  /// naturally type ("0750…" → "750…").
  String toE164(String nationalNumber) {
    var digits = nationalNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = digits.substring(1);
    return '$dialCode$digits';
  }

  /// Light client-side check. Real verification is the SMS actually arriving.
  bool isPlausible(String nationalNumber) {
    var digits = nationalNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = digits.substring(1);
    // A little slack either side — numbering plans vary within a country.
    return digits.length >= nationalDigits - 1 &&
        digits.length <= nationalDigits + 1;
  }
}

/// Everything the Register screen collects, ready to hand to the auth
/// service. Deliberately holds no password — that is passed separately and
/// never stored on an object that might get logged.
class RegistrationDetails {
  const RegistrationDetails({
    required this.fullName,
    required this.dateOfBirth,
    required this.phoneE164,
    required this.email,
    this.gender,
  });

  final String fullName;
  final DateTime dateOfBirth;
  final String phoneE164;
  final String email;

  /// Null when the user skipped it.
  final Gender? gender;
}
