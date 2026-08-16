import 'package:flutter/widgets.dart';

/// The app's current locale. Changing its value rebuilds [MaterialApp] (which
/// listens to it), switching every screen's language and text direction.
///
/// Kept as a simple app-wide notifier for now — a fuller state-management
/// approach can replace it later (state management is still undecided per
/// CLAUDE.md).
final ValueNotifier<Locale> appLocale = ValueNotifier<Locale>(
  const Locale('en'),
);
