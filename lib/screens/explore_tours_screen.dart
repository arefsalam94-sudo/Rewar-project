import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/featured_item.dart' show FeaturedType;
import '../models/tour.dart';
import '../models/tour_filters.dart';
import '../services/currency_rates_service.dart';
import '../services/device_location_service.dart';
import '../services/favorites_service.dart';
import '../services/tours_service.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_recessed_glass_field.dart';
import '../widgets/glass_back_button.dart';
import '../widgets/glass_panel.dart';
import '../widgets/page_background.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';
import 'tour_detail_screen.dart';
import 'tour_assets.dart' as tour_assets;

const String exploreToursBackgroundAsset =
    tour_assets.exploreToursBackgroundAsset;

/// The background photograph for the Explore Tours screen, supplied with the
/// reference (`DESIGN_SYSTEM.md` 4.1: every screen uses a developer-supplied
/// bundled photo, blurred at σ2 under the theme gradient at 45%).

/// Phase 6 — the Explore Tours list screen, opened from the Home screen's
/// "Explore Tours" card.
///
/// Layout comes from the supplied reference: the back button and title on one
/// row, a carousel of highlighted tours, the search block, then the "Trending
/// Tours" list. Every colour, radius and text size comes from tokens already
/// approved in `DESIGN_SYSTEM.md` / `DESIGN_LIGHT.md` / `DESIGN_DARK.md`.
///
/// The rating placement is as requested: **leading edge** on the carousel
/// slide, **trailing edge** on a list card.
///
/// Catalog data is public read, so a guest sees exactly what a signed-in user
/// sees (`SECURITY.md` section 1, `firestore.rules` → `tours`). Only the
/// favourite heart needs an account.
class ExploreToursScreen extends StatefulWidget {
  const ExploreToursScreen({
    super.key,
    this.toursService,
    this.locationService,
    this.favoritesService,
    this.currencyRatesService,
    this.userProfileService,
  });

  /// Injectable for tests; defaults to the real Firestore-backed service.
  final ToursService? toursService;

  /// Injectable for tests. A test that passes nothing gets the real service,
  /// which returns null off-device — so the distance line simply stays hidden
  /// rather than failing.
  final DeviceLocationService? locationService;

  final FavoritesService? favoritesService;
  final CurrencyRatesService? currencyRatesService;
  final UserProfileService? userProfileService;

  @override
  State<ExploreToursScreen> createState() => _ExploreToursScreenState();
}

class _ExploreToursScreenState extends State<ExploreToursScreen> {
  late final ToursService _service = widget.toursService ?? ToursService();
  late final DeviceLocationService _locationService =
      widget.locationService ?? const DeviceLocationService();
  late final FavoritesService _favoritesService =
      widget.favoritesService ?? FavoritesService();
  late final CurrencyRatesService _ratesService =
      widget.currencyRatesService ?? CurrencyRatesService();
  late final UserProfileService _profileService =
      widget.userProfileService ?? UserProfileService();

  late Future<List<Tour>> _highlightedFuture;

  /// The whole active catalog, fetched once and filtered in Dart.
  ///
  /// Firestore cannot do substring search at all, and the tour name is a
  /// locale map, so a server-side search would have to pick one of three
  /// languages. See [ToursService.fetchCatalog].
  List<Tour>? _catalog;
  Object? _catalogError;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  /// What the user has typed and picked, which is not yet what the list is
  /// showing — the reference has an explicit Apply button, so the *search*
  /// inputs do not narrow anything until it is pressed.
  DateTimeRange? _pendingRange;
  int _pendingTravellers = TourFilters.minTravellers;

  /// What is actually narrowing and ordering the list.
  ///
  /// Search text, dates and party size land here on Apply. The refinement
  /// chips and the sort control write straight through, because they refine a
  /// result set rather than describing a search — which is how both reference
  /// products behave, and what keeps Apply from looking decorative.
  TourFilters _filters = const TourFilters();

  /// Null until a GPS fix arrives, and stays null when location is off or
  /// denied — the cards then hide their distance line instead of inventing
  /// one, and "Nearest to me" quietly falls back to "Soonest".
  DeviceLocation? _deviceLocation;

  /// Indicative FX rates and the user's chosen display currency. Both are
  /// best-effort: without them prices stay in the operator's own currency,
  /// which is always correct.
  CurrencyRates _rates = CurrencyRates.empty;
  AppCurrency _displayCurrency = AppCurrency.usd;

  /// Tour ids the signed-in user has saved, and the ones mid-write so a
  /// double-tap cannot fire twice.
  Set<String> _favoriteIds = <String>{};
  final Set<String> _pendingFavorites = <String>{};

  final PageController _carouselController = PageController();
  int _currentSlide = 0;

  @override
  void initState() {
    super.initState();
    _highlightedFuture = _service.fetchHighlighted();
    _searchController.addListener(_onSearchChanged);
    _loadCatalog();
    _loadDeviceLocation();
    _loadSecondaryData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _dateController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  /// Only rebuilds when the box crosses between empty and non-empty — every
  /// keystroke in between changes nothing on screen.
  bool _searchWasEmpty = true;
  void _onSearchChanged() {
    final isEmpty = _searchController.text.isEmpty;
    if (isEmpty != _searchWasEmpty) {
      setState(() => _searchWasEmpty = isEmpty);
    }
  }

  /// The distance line is a nice-to-have, so a failure here must never surface
  /// as an error on a screen that is otherwise working.
  Future<void> _loadDeviceLocation() async {
    final location = await _locationService.currentLocation();
    if (mounted && location != null) {
      setState(() => _deviceLocation = location);
    }
  }

  /// Favourites, FX rates and the currency preference — three optional extras.
  ///
  /// Every one of them is allowed to fail silently: none is the reason the
  /// user opened this screen, and a tour list that refuses to draw because a
  /// rate table is missing would be a much worse bug than an unconverted price.
  Future<void> _loadSecondaryData() async {
    try {
      final rates = await _ratesService.fetchLatest();
      if (mounted) setState(() => _rates = rates);
    } catch (error) {
      debugPrint('Could not load currency rates: $error');
    }
    try {
      final profile = await _profileService.fetchProfile();
      if (mounted && profile != null) {
        setState(() => _displayCurrency = profile.currency);
      }
    } catch (error) {
      debugPrint('Could not load the currency preference: $error');
    }
    try {
      final ids = await _favoritesService.fetchFavoriteItemIds();
      if (mounted) setState(() => _favoriteIds = ids);
    } catch (error) {
      debugPrint('Could not load favorites: $error');
    }
  }

  void _retryHighlighted() {
    setState(() {
      _currentSlide = 0;
      _highlightedFuture = _service.fetchHighlighted();
    });
  }

  /// Loads the catalog, and is also the retry path — it resets to the loading
  /// state first, so a retry visibly restarts rather than sitting on the error.
  Future<void> _loadCatalog() async {
    setState(() {
      _catalog = null;
      _catalogError = null;
    });
    try {
      final tours = await _service.fetchCatalog();
      if (mounted) setState(() => _catalog = tours);
    } catch (error) {
      debugPrint('Could not load tours: $error');
      if (mounted) setState(() => _catalogError = error);
    }
  }

  /// Commits the search box, the date range and the party size to the list.
  /// Costs no read — the catalog is already in memory.
  void _apply() {
    FocusScope.of(context).unfocus();
    final range = _pendingRange;
    setState(() {
      _filters = _filters.copyWith(
        query: _searchController.text,
        clearRange: range == null,
        rangeStart: range?.start,
        rangeEnd: range?.end,
        travellers: _pendingTravellers,
      );
    });
  }

  void _clearEverything() {
    _searchController.clear();
    setState(() {
      _pendingRange = null;
      _pendingTravellers = TourFilters.minTravellers;
      // The sort survives a clear: it is the user's chosen view of the list,
      // not one of the things narrowing it.
      _filters = TourFilters(sort: _filters.sort);
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _pendingRange,
      // A tour that has already departed cannot be booked, so there is nothing
      // useful behind today.
      firstDate: today,
      lastDate: DateTime(today.year + 2, today.month, today.day),
    );
    if (picked != null && mounted) setState(() => _pendingRange = picked);
  }

  void _setTravellers(int value) => setState(
    () => _pendingTravellers = value.clamp(
      TourFilters.minTravellers,
      TourFilters.maxTravellers,
    ),
  );

  Future<void> _onFavoriteTapped(Tour tour) async {
    final l10n = AppLocalizations.of(context);

    if (!_service.isSignedIn) {
      await _showSignInPrompt();
      return;
    }
    if (_pendingFavorites.contains(tour.id)) return;

    final wasFavorite = _favoriteIds.contains(tour.id);
    setState(() => _pendingFavorites.add(tour.id));
    try {
      final nowFavorite = await _favoritesService.toggle(
        itemType: FeaturedType.tour,
        itemId: tour.id,
        currentlyFavorite: wasFavorite,
      );
      if (!mounted) return;
      setState(() {
        if (nowFavorite) {
          _favoriteIds.add(tour.id);
        } else {
          _favoriteIds.remove(tour.id);
        }
      });
      _snack(nowFavorite ? l10n.addedToFavorites : l10n.removedFromFavorites);
    } catch (error) {
      debugPrint('Favorite toggle failed: $error');
      if (mounted) _snack(l10n.favoriteFailed);
    } finally {
      if (mounted) setState(() => _pendingFavorites.remove(tour.id));
    }
  }

  /// The same prompt the Home screen shows: a favourite is tied to an account,
  /// so there is no such thing as an anonymous one.
  Future<void> _showSignInPrompt() async {
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GlassPanel(
            borderRadius: 28,
            elevated: true,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.signInToSave,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.signInToSaveBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: l10n.logIn,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(l10n.notNow),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// The list actually drawn: filtered and ordered by [_filters].
  List<Tour> _visibleTours(List<Tour> catalog) => _filters.sortedFrom(
    catalog,
    fromLatitude: _deviceLocation?.latitude,
    fromLongitude: _deviceLocation?.longitude,
  );

  /// How prices should be drawn, given the rate table and the user's currency.
  TourPricing get _pricing => TourPricing(
    rates: _rates,
    displayCurrency: _displayCurrency.code,
    travellers: _filters.travellers,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageBackground(
        imageAsset: exploreToursBackgroundAsset,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(0, 0, 0, bottomInset + 28),
            children: [
              const _BackBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCarousel(l10n, languageCode),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSearchControls(l10n),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _RefineBar(
                  filters: _filters,
                  onToggleFeature: (id) =>
                      setState(() => _filters = _filters.toggleFeature(id)),
                  onToggleLanguage: (code) => setState(
                    () => _filters = _filters.toggleGuideLanguage(code),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SortBar(
                  sort: _filters.sort,
                  // Offering "Nearest to me" without a fix would be offering
                  // an order the screen cannot produce.
                  locationAvailable: _deviceLocation != null,
                  onChanged: (sort) =>
                      setState(() => _filters = _filters.copyWith(sort: sort)),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.trendingTours,
                  // `section-title` from the DESIGN_SYSTEM.md type scale.
                  style: TextStyle(
                    fontSize: 20,
                    height: 28 / 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.heading(context),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTourList(l10n, languageCode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(AppLocalizations l10n, String languageCode) {
    return SizedBox(
      height: _HighlightCard.heightFor(context),
      child: FutureBuilder<List<Tour>>(
        future: _highlightedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _PanelShell(child: _PanelLoading());
          }
          if (snapshot.hasError) {
            return _PanelShell(
              child: _PanelMessage(
                message: l10n.toursLoadFailed,
                actionLabel: l10n.tryAgain,
                onAction: _retryHighlighted,
              ),
            );
          }

          final tours = snapshot.data ?? const <Tour>[];
          if (tours.isEmpty) {
            return _PanelShell(
              child: _PanelMessage(message: l10n.toursHighlightedEmpty),
            );
          }

          return Stack(
            children: [
              PageView.builder(
                controller: _carouselController,
                itemCount: tours.length,
                onPageChanged: (index) => setState(() => _currentSlide = index),
                itemBuilder: (context, index) => _HighlightCard(
                  tour: tours[index],
                  languageCode: languageCode,
                  onTap: () => _openTour(tours[index]),
                ),
              ),
              // Outside the PageView, so the dots stay still while the slides
              // move — the same rule the Home and Explore Nature carousels
              // follow.
              PositionedDirectional(
                end: 20,
                bottom: 16,
                child: _Dots(count: tours.length, current: _currentSlide),
              ),
            ],
          );
        },
      ),
    );
  }

  /// The recessed-glass inputs, the traveller stepper and the Apply button.
  ///
  /// Every field is the shared [AppRecessedGlassField] — `DESIGN_SYSTEM.md`
  /// section 8 requires one input family across the whole app, and section 22
  /// lists "different input families on different screens" as prohibited.
  Widget _buildSearchControls(AppLocalizations l10n) {
    final range = _pendingRange;
    // Written here rather than in `_pickDateRange`, so the field re-renders in
    // the new language when the app locale changes under it.
    _dateController.text = range == null
        ? ''
        : l10n.tourDateRange(range.start, range.end);

    return Column(
      children: [
        AppRecessedGlassField(
          key: exploreToursSearchFieldKey,
          controller: _searchController,
          hint: l10n.toursSearchHint,
          prefixIcon: Icons.search_rounded,
          textInputAction: TextInputAction.search,
          onFieldSubmitted: (_) => _apply(),
          suffix: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: l10n.clearSearch,
                  onPressed: () {
                    _searchController.clear();
                    _apply();
                  },
                ),
        ),
        const SizedBox(height: 12),
        AppRecessedGlassField(
          key: exploreToursDateFieldKey,
          controller: _dateController,
          hint: l10n.toursDateRangeHint,
          prefixIcon: Icons.calendar_month_outlined,
          // Read-only rather than a free-text date: a typed date has to be
          // parsed, and a parser that has to cover three languages is a source
          // of wrong dates, not convenience.
          readOnly: true,
          onTap: _pickDateRange,
          suffix: range == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: l10n.clearDate,
                  onPressed: () => setState(() => _pendingRange = null),
                ),
        ),
        const SizedBox(height: 12),
        _TravellerStepper(value: _pendingTravellers, onChanged: _setTravellers),
        const SizedBox(height: 20),
        // Not full width: the reference draws a compact centred action. The
        // token geometry (56dp, radius 14, solid action fill) is unchanged —
        // only the width is constrained, per `DESIGN_SYSTEM.md` 9.4.
        Center(
          child: SizedBox(
            width: 200,
            child: PrimaryButton(label: l10n.toursApply, onTap: _apply),
          ),
        ),
      ],
    );
  }

  Widget _buildTourList(AppLocalizations l10n, String languageCode) {
    if (_catalogError != null) {
      return SizedBox(
        height: 160,
        child: _PanelShell(
          child: _PanelMessage(
            message: l10n.toursLoadFailed,
            actionLabel: l10n.tryAgain,
            onAction: _loadCatalog,
          ),
        ),
      );
    }

    final catalog = _catalog;
    if (catalog == null) {
      return const SizedBox(
        height: 160,
        child: _PanelShell(child: _PanelLoading()),
      );
    }

    final tours = _visibleTours(catalog);
    if (tours.isEmpty) {
      return SizedBox(
        height: 160,
        child: _PanelShell(
          child: _PanelMessage(
            message: l10n.toursEmpty,
            // Only offered when a filter is what emptied the list — otherwise
            // there is nothing to clear.
            actionLabel: _filters.isEmpty ? null : l10n.toursClearAll,
            onAction: _filters.isEmpty ? null : _clearEverything,
          ),
        ),
      );
    }

    final pricing = _pricing;
    // The disclosure is drawn once, above the list, and only when a price on
    // screen actually was converted — a standing legal notice nobody needs is
    // noise, and noise is what makes real disclosures invisible.
    final showsConverted = tours.any(
      (tour) => pricing.isConverted(tour.currency),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showsConverted) ...[
          _PriceDisclosure(updatedAt: _rates.updatedAt),
          const SizedBox(height: 12),
        ],
        for (final tour in tours) ...[
          _TourCard(
            tour: tour,
            languageCode: languageCode,
            deviceLocation: _deviceLocation,
            pricing: pricing,
            isFavorite: _favoriteIds.contains(tour.id),
            favoritePending: _pendingFavorites.contains(tour.id),
            onFavorite: () => _onFavoriteTapped(tour),
            onTap: () => _openTour(tour),
          ),
          if (tour != tours.last) const SizedBox(height: 14),
        ],
      ],
    );
  }

  void _openTour(Tour tour) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TourDetailScreen(
          tour: tour,
          toursService: _service,
          locationService: _locationService,
        ),
      ),
    );
  }
}

@visibleForTesting
const Key exploreToursSearchFieldKey = ValueKey('explore-tours-search');

@visibleForTesting
const Key exploreToursDateFieldKey = ValueKey('explore-tours-date');

@visibleForTesting
const Key exploreToursTravellerPlusKey = ValueKey('explore-tours-travellers+');

@visibleForTesting
const Key exploreToursTravellerMinusKey = ValueKey('explore-tours-travellers-');

// --- Chrome -----------------------------------------------------------------

/// The back button and the page title, on one row, as the reference draws it.
///
/// Sized by its content rather than a fixed height, so the title can wrap at a
/// large system font size instead of being clipped (`DESIGN_SYSTEM.md` § 19,
/// "avoid fixed-height containers that clip text").
class _BackBar extends StatelessWidget {
  const _BackBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left, not start: GlassBackButton stays physically top-left in every
          // language, RTL included (`DESIGN_SYSTEM.md` 11.3 and 20).
          GlassBackButton(onTap: () => Navigator.of(context).maybePop()),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.exploreToursTitle,
              // `page-title` from the DESIGN_SYSTEM.md type scale: 28/700/36.
              style: TextStyle(
                fontSize: 28,
                height: 36 / 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.02 * 28,
                color: AppColors.heading(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Both design files specify the organic 28px `rounded-card` silhouette.
const double _cardRadius = 28;

// --- Pricing ----------------------------------------------------------------

/// How one screen draws money: the rate table, the currency to show, and how
/// many people are travelling.
///
/// A value object rather than three loose fields, so the card cannot render a
/// per-person price in one currency and a total in another.
@immutable
class TourPricing {
  const TourPricing({
    required this.rates,
    required this.displayCurrency,
    this.travellers = 1,
  });

  final CurrencyRates rates;

  /// The ISO code the user chose in Settings (`users.preferredCurrency`).
  final String displayCurrency;

  final int travellers;

  /// Whether a price quoted in [currency] would actually be converted for
  /// display — false when it already matches, and false when the rate table
  /// cannot do it.
  bool isConverted(String currency) {
    if (currency.toUpperCase() == displayCurrency.toUpperCase()) return false;
    return rates.convert(1, from: currency, to: displayCurrency) != null;
  }

  /// One person's price as drawn, e.g. `$55` or `≈ IQD 72,050`.
  ///
  /// Falls back to the operator's own currency whenever the conversion is not
  /// possible — an unconverted true price beats a converted invented one.
  String perPerson(num amount, String currency) =>
      _format(amount, currency, multiplier: 1);

  /// The whole party's price, or null when [travellers] is 1 and the line
  /// would only repeat the per-person figure.
  String? total(num amount, String currency) {
    if (travellers <= 1) return null;
    return _format(amount, currency, multiplier: travellers);
  }

  String _format(num amount, String currency, {required int multiplier}) {
    final base = amount * multiplier;
    final converted = rates.convert(base, from: currency, to: displayCurrency);
    if (converted == null || !isConverted(currency)) {
      return formatMoney(base, currency);
    }
    // "≈" is the whole disclosure at a glance; the sentence above the list
    // carries the rest.
    return '≈ ${formatMoney(converted, displayCurrency)}';
  }
}

/// `$55`, `€1,240`, `IQD 72,050`.
///
/// Grouped in threes with Western digits in every language, matching how every
/// other number in the app is drawn (see `AppLocalizations.bookingDate`).
/// A currency with no well-known glyph keeps its ISO code, because an invented
/// symbol is worse than three unambiguous letters.
@visibleForTesting
String formatMoney(num amount, String currency) {
  final symbol = CurrencyRatesService.symbolFor(currency);
  // Sub-unit precision only where it exists and matters: 55 is "$55", 55.5 is
  // "$55.50", and 72049.6 dinars is "IQD 72,050" — nobody quotes fils.
  final rounded = amount.abs() >= 1000 || amount % 1 == 0
      ? amount.round().toString()
      : amount.toStringAsFixed(2);
  final parts = rounded.split('.');
  final grouped = parts.first.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (match) => '${match[1]},',
  );
  final body = parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
  return symbol.length > 1 ? '$symbol $body' : '$symbol$body';
}

/// The one-line notice above a list containing converted prices.
class _PriceDisclosure extends StatelessWidget {
  const _PriceDisclosure({this.updatedAt});

  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final when = updatedAt;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 15,
          color: AppColors.secondaryText(context),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            when == null
                ? l10n.toursPriceApprox
                : '${l10n.toursPriceApprox} '
                      '${l10n.lastUpdated(l10n.bookingDate(when))}',
            style: TextStyle(
              // `caption`
              fontSize: 12,
              height: 16 / 12,
              color: AppColors.secondaryText(context),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Highlighted carousel ---------------------------------------------------

/// One carousel slide: the photo of a highlighted tour, its rating on the
/// **leading** edge and its operator tag on the trailing edge, then the name,
/// location line and a clipped description.
class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.tour,
    required this.languageCode,
    required this.onTap,
  });

  final Tour tour;
  final String languageCode;
  final VoidCallback onTap;

  /// Base height, grown for large system font sizes so the overlaid copy never
  /// runs out of room — the same rule the Explore Nature carousel uses.
  static double heightFor(BuildContext context) {
    final factor = (MediaQuery.textScalerOf(context).scale(16) / 16).clamp(
      1.0,
      1.6,
    );
    return 288 * factor;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final score = tour.reviewScore;

    return Padding(
      // Keeps a gap between slides as the PageView scrolls.
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Semantics(
        button: true,
        label: tour.name(languageCode),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(_cardRadius),
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_cardRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _TourPhoto(tour: tour, index: 0),
                  // Scrim, so white copy stays legible over any photograph.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x40000000),
                          Color(0x00000000),
                          Color(0xB3000000),
                        ],
                        stops: [0.0, 0.32, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating on the **leading** edge of the slide, as
                            // asked. Score and stars stay visually separate
                            // (`DESIGN_SYSTEM.md` 13).
                            if (score != null) ...[
                              _ScoreBox(score: score),
                              const SizedBox(width: 8),
                              _StarBox(score: score),
                            ],
                            const Spacer(),
                            if (tour.companyTag.isNotEmpty)
                              _CompanyTag(
                                label: tour.companyTag,
                                onPhoto: true,
                              ),
                          ],
                        ),
                        const Spacer(),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            tour.name(languageCode),
                            maxLines: 1,
                            style: const TextStyle(
                              // headline-lg
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.02 * 26,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 17,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                tour.locationLabel(languageCode),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          // Keeps the copy clear of the dot row in the opposite
                          // corner, which is drawn outside this slide.
                          padding: const EdgeInsetsDirectional.only(end: 70),
                          child: Text(
                            tour.description(languageCode),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              height: 17 / 13,
                              color: Colors.white.withValues(alpha: 0.88),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_cardRadius),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: isDark ? AppColors.darkBorderOpacity : 0.35,
                          ),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tour photograph: a bundled asset in preview mode, a Storage URL in
/// production. Both fall back to a brand-coloured panel with a tour icon
/// rather than a broken-image box.
class _TourPhoto extends StatelessWidget {
  const _TourPhoto({required this.tour, required this.index});

  final Tour tour;

  /// Which of the tour's photos to draw. Out-of-range falls back gracefully.
  final int index;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallback = ColoredBox(
      color: isDark
          ? AppColors.darkForestFloor
          : AppColors.pageGradientBottom.withValues(alpha: 0.55),
      child: Center(
        child: Icon(
          Icons.festival_outlined,
          size: 34,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );

    final photos = tour.photos;
    if (photos.isEmpty || index >= photos.length) return fallback;
    final photo = photos[index];

    if (tour.photosAreAssets) {
      return Image.asset(
        photo,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }
    return Image.network(
      photo,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback,
    );
  }
}

/// Page dots. Always laid out left-to-right, like the Home carousel and the
/// Explore Nature carousel — a progress track is not a sentence.
@visibleForTesting
const Key exploreToursDotsKey = ValueKey('explore-tours-dots');

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: Row(
      key: exploreToursDotsKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 9 : 7,
            height: i == current ? 9 : 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: i == current ? 1 : 0.5),
            ),
          ),
      ],
    ),
  );
}

// --- Rating badges ----------------------------------------------------------

/// The 0–10 review score, in the shared rating-badge shell.
class _ScoreBox extends StatelessWidget {
  const _ScoreBox({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) => _BadgeShell(
    child: Text(
      score.toStringAsFixed(1),
      // Always left-to-right: a decimal score reads the same way in every
      // language.
      textDirection: TextDirection.ltr,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: _BadgeShell.contentColor(context),
      ),
    ),
  );
}

/// Five stars, filled from the same 0–10 score. Derived, never stored — see
/// [Tour.starsForScore].
class _StarBox extends StatelessWidget {
  const _StarBox({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final filled = Tour.starsForScore(score);
    final color = _BadgeShell.contentColor(context);

    return _BadgeShell(
      child: Directionality(
        // A rating track fills left-to-right in every language, the same rule
        // the carousel dots follow.
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 5; i++)
              Padding(
                padding: EdgeInsets.only(right: i == 4 ? 0 : 5),
                child: Icon(
                  i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 17,
                  color: color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shared shell behind [_ScoreBox] and [_StarBox], per the unified
/// rating-badge rule in both theme documents. Identical to the Explore Nature
/// treatment on purpose — `DESIGN_SYSTEM.md` 13 forbids a per-screen rating.
class _BadgeShell extends StatelessWidget {
  const _BadgeShell({required this.child});

  final Widget child;

  /// `DESIGN_SYSTEM.md` 13: compact rounded box, radius 12.
  static const double radius = 12;

  static Color contentColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.darkOnPrimary
      : AppColors.actionNavy;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.luminousMint
            : AppColors.pageGradientTop.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark ? AppColors.darkOnPrimary : AppColors.actionNavy,
        ),
      ),
      child: child,
    );
  }
}

// --- Refine and sort --------------------------------------------------------

/// The refinement chips: what a tour includes, and what the guide speaks.
///
/// These write straight through rather than waiting for Apply. They refine a
/// result set the user is already looking at, which is how both reference
/// products behave — and it keeps Apply meaning "run this search" rather than
/// "commit the eight things I touched".
class _RefineBar extends StatelessWidget {
  const _RefineBar({
    required this.filters,
    required this.onToggleFeature,
    required this.onToggleLanguage,
  });

  final TourFilters filters;
  final ValueChanged<String> onToggleFeature;
  final ValueChanged<String> onToggleLanguage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GlassPanel(
      borderRadius: _cardRadius,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GroupLabel(label: l10n.toursIncludes),
          const SizedBox(height: 8),
          _ChipScroller(
            children: [
              for (final feature in TourFeature.values)
                _ChoiceChip(
                  label: l10n.tourFeatureLabel(feature),
                  selected: filters.features.contains(feature.id),
                  onTap: () => onToggleFeature(feature.id),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _GroupLabel(label: l10n.tourGuideLanguages),
          const SizedBox(height: 8),
          _ChipScroller(
            children: [
              for (final language in TourGuideLanguage.values)
                _ChoiceChip(
                  label: l10n.tourGuideLanguageLabel(language),
                  selected: filters.guideLanguages.contains(language.code),
                  onTap: () => onToggleLanguage(language.code),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The sort control. Single-select, so it uses the same chip with
/// `Semantics(inMutuallyExclusiveGroup)` rather than a second control family.
class _SortBar extends StatelessWidget {
  const _SortBar({
    required this.sort,
    required this.locationAvailable,
    required this.onChanged,
  });

  final TourSort sort;

  /// "Nearest to me" is hidden without a fix — offering an order the screen
  /// cannot produce is worse than offering one fewer.
  final bool locationAvailable;

  final ValueChanged<TourSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = TourSort.values
        .where((value) => locationAvailable || !value.needsLocation)
        .toList(growable: false);

    return GlassPanel(
      borderRadius: _cardRadius,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GroupLabel(label: l10n.toursSortLabel),
          const SizedBox(height: 8),
          _ChipScroller(
            children: [
              for (final option in options)
                _ChoiceChip(
                  label: l10n.tourSortLabel(option),
                  selected: option == sort,
                  exclusive: true,
                  onTap: () => onChanged(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    // `label` from the type scale: 12 / 600.
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.secondaryText(context),
    ),
  );
}

/// A horizontally scrollable chip row — a fixed row of eight localized labels
/// does not fit on a 320dp phone, and certainly not at a raised font size.
class _ChipScroller extends StatelessWidget {
  const _ChipScroller({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final child in children) ...[
          child,
          if (child != children.last) const SizedBox(width: 8),
        ],
      ],
    ),
  );
}

/// The one selectable chip used by both the refinement groups and the sort
/// control, per `DESIGN_SYSTEM.md` 12.1: pill geometry, ~38dp visual height
/// inside a 48dp target, accent stroke **only when selected**.
class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.exclusive = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// True for the sort row, where exactly one option is active — announced to
  /// assistive technology as a radio group rather than eight toggles.
  final bool exclusive;

  static const double visualHeight = 38;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedFill = isDark ? AppColors.luminousMint : AppColors.actionNavy;
    final selectedContent = isDark
        ? AppColors.darkOnPrimary
        : AppColors.pageGradientTop;
    final restingContent = isDark
        ? AppColors.luminousMint
        : AppColors.actionNavy;

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: exclusive,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: visualHeight,
          margin: const EdgeInsets.symmetric(vertical: (48 - visualHeight) / 2),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // Unselected keeps the neutral glass tint and **no** accent
            // stroke; selected strengthens the tint and adds the 1.5px accent
            // stroke (`DESIGN_SYSTEM.md` 7.1 / 7.2).
            color: selected
                ? selectedFill
                : AppColors.selectionTint(
                    context,
                  ).withValues(alpha: isDark ? 0.10 : 0.55),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? selectedContent
                  : restingContent.withValues(alpha: 0.35),
              width: selected ? AppColors.selectionStrokeWidth : 1,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? selectedContent : restingContent,
            ),
          ),
        ),
      ),
    );
  }
}

/// "Travellers  −  2  +".
///
/// A stepper rather than a text field: the value is a small integer with hard
/// bounds, and a keyboard would invite "0" and "300".
class _TravellerStepper extends StatelessWidget {
  const _TravellerStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canDecrease = value > TourFilters.minTravellers;
    final canIncrease = value < TourFilters.maxTravellers;

    return GlassPanel(
      borderRadius: AppRecessedGlassField.radius,
      padding: const EdgeInsetsDirectional.only(start: 18, end: 8),
      child: SizedBox(
        // The same 56dp control height as every other field on the screen.
        height: 56,
        child: Row(
          children: [
            Icon(
              Icons.group_outlined,
              size: 22,
              color: AppColors.selectionAccent(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.tourTravellers,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText(context),
                ),
              ),
            ),
            _StepperButton(
              buttonKey: exploreToursTravellerMinusKey,
              icon: Icons.remove_rounded,
              semanticLabel: l10n.tourTravellerCount(value - 1),
              onTap: canDecrease ? () => onChanged(value - 1) : null,
            ),
            // The count is a measurement, so it stays LTR in every language.
            SizedBox(
              width: 34,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.heading(context),
                ),
              ),
            ),
            _StepperButton(
              buttonKey: exploreToursTravellerPlusKey,
              icon: Icons.add_rounded,
              semanticLabel: l10n.tourTravellerCount(value + 1),
              onTap: canIncrease ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.buttonKey,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final Key buttonKey;
  final IconData icon;
  final String semanticLabel;

  /// Null disables the button at the range's ends.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final accent = AppColors.accent(
      context,
    ).withValues(alpha: enabled ? 1 : 0.35);

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: SizedBox(
        // 48dp target around a 32dp circle, per `DESIGN_SYSTEM.md` 19.
        width: 48,
        height: 48,
        child: InkWell(
          key: buttonKey,
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent, width: 1.5),
              ),
              child: Icon(icon, size: 18, color: accent),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Tour card --------------------------------------------------------------

/// One tour in the list.
///
/// The photo sits on the **leading** edge and the rating on the **trailing**
/// edge, so the whole card mirrors in Kurdish and Arabic instead of reading
/// backwards.
class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.tour,
    required this.languageCode,
    required this.deviceLocation,
    required this.pricing,
    required this.isFavorite,
    required this.favoritePending,
    required this.onFavorite,
    required this.onTap,
  });

  final Tour tour;
  final String languageCode;
  final DeviceLocation? deviceLocation;
  final TourPricing pricing;
  final bool isFavorite;
  final bool favoritePending;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  static const double thumbnailWidth = 140;
  static const double minHeight = 246;

  /// How many feature icons the list card draws.
  ///
  /// The reference shows four, and a fifth does not fit beside a 140dp
  /// thumbnail at any readable label size. A tour tagged with more keeps them
  /// all in Firestore — the detail screen is where the full set belongs.
  static const int maxFeaturesOnCard = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final distance = _distanceText(l10n);
    final features = tour.knownFeatures.take(maxFeaturesOnCard).toList();
    final start = tour.startAt;
    final score = tour.reviewScore;
    final policy = tour.cancellationPolicy;
    final languages = tour.knownGuideLanguages;
    final price = tour.pricePerPerson;

    return Semantics(
      button: true,
      label: tour.name(languageCode),
      child: InkWell(
        borderRadius: BorderRadius.circular(_cardRadius),
        onTap: onTap,
        child: GlassPanel(
          borderRadius: _cardRadius,
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: minHeight),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: thumbnailWidth,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(_cardRadius - 4),
                          child: _TourPhoto(tour: tour, index: 0),
                        ),
                        PositionedDirectional(
                          top: 0,
                          start: 0,
                          child: _FavoriteButton(
                            isFavorite: isFavorite,
                            pending: favoritePending,
                            onTap: onFavorite,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                tour.name(languageCode),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  // headline-md
                                  fontSize: 19,
                                  height: 24 / 19,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.heading(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Rating on the **trailing** edge of the card, as
                            // asked. The score badge alone rather than score +
                            // five stars: the column is ~230dp wide, and
                            // `DESIGN_SYSTEM.md` 13 approves either form.
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (tour.companyTag.isNotEmpty)
                                  _CompanyTag(label: tour.companyTag),
                                if (score != null) ...[
                                  const SizedBox(height: 6),
                                  _ScoreBox(score: score),
                                  const SizedBox(height: 3),
                                  Text(
                                    l10n.tourReviewCount(tour.ratingCount),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.secondaryText(context),
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    l10n.tourNoReviews,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.secondaryText(context),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.tourDuration(tour.durationDays),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryText(context),
                          ),
                        ),
                        if (features.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _FeatureRow(features: features),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.heading(context),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                tour.locationLabel(languageCode),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.heading(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (tour.isLowAvailability) ...[
                          const SizedBox(height: 6),
                          _MetaLine(
                            icon: Icons.event_seat_outlined,
                            text: l10n.tourSpotsLeft(tour.spotsLeft!),
                            // The one line on the card that is a warning rather
                            // than information, so it takes the semantic warning
                            // token instead of the quiet body colour.
                            color: Theme.of(context).colorScheme.error,
                            bold: true,
                          ),
                        ],
                        if (policy != null) ...[
                          const SizedBox(height: 6),
                          _MetaLine(
                            icon: policy.isFree
                                ? Icons.event_available_outlined
                                : Icons.event_busy_outlined,
                            text: l10n.tourCancellationLabel(policy),
                            color: policy.isFree
                                ? AppColors.statusSuccessContent(context)
                                : AppColors.secondaryText(context),
                          ),
                        ],
                        if (languages.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _MetaLine(
                            icon: Icons.translate_rounded,
                            text: languages
                                .map(l10n.tourGuideLanguageLabel)
                                .join(' · '),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (distance != null) ...[
                                    Text(
                                      distance,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryText(context),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  Text(
                                    tour.description(languageCode),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      // body-sm
                                      fontSize: 13,
                                      height: 19 / 13,
                                      color: AppColors.secondaryText(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (start != null) ...[
                                  Text(
                                    l10n.tourDateRange(start, tour.endAt),
                                    textAlign: TextAlign.end,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryText(context),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                if (price != null)
                                  _PriceBox(
                                    price: price,
                                    currency: tour.currency,
                                    pricing: pricing,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// "2.3 km from current location", or null when either the device position
  /// or the tour's coordinates are missing — in which case the line is not
  /// drawn at all, rather than showing a distance from somewhere the user
  /// is not.
  String? _distanceText(AppLocalizations l10n) {
    final from = deviceLocation;
    if (from == null) return null;
    final meters = tour.distanceMetersFrom(from.latitude, from.longitude);
    if (meters == null) return null;
    return l10n.distanceFromCurrentLocation(formatTourDistance(meters));
  }
}

/// Metres under a kilometre, then one decimal up to 10 km, then whole
/// kilometres — "0.3 km" and "127.4 km" are both worse than "300 m" and
/// "127 km".
///
/// Mirrors `formatSpotDistance` on the Explore Nature screen. Kept as its own
/// copy rather than imported because that one is `@visibleForTesting`; if a
/// third screen needs it, move both into a shared helper then.
@visibleForTesting
String formatTourDistance(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  final km = meters / 1000;
  return km < 10 ? '${km.toStringAsFixed(1)} km' : '${km.round()} km';
}

/// A small icon-and-text line on a card — availability, cancellation policy,
/// guide languages. One widget rather than three, so they cannot drift apart.
class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.icon,
    required this.text,
    this.color,
    this.bold = false,
  });

  final IconData icon;
  final String text;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? AppColors.secondaryText(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: resolved),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: resolved,
            ),
          ),
        ),
      ],
    );
  }
}

/// The heart, overlaid on the card's photo.
///
/// Mirrors the Home screen's featured-card control exactly — a favourite is
/// one concept, so it must not look like two.
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.pending,
    required this.onTap,
  });

  final bool isFavorite;

  /// True while the write is in flight, so a double-tap cannot fire twice.
  final bool pending;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.luminousMint : AppColors.actionNavy;

    return Semantics(
      button: true,
      selected: isFavorite,
      enabled: !pending,
      label: AppLocalizations.of(context).navSaved,
      child: SizedBox(
        // 34dp circle inside a 48dp target — the GlassBackButton pattern,
        // trimmed to sit on a 140dp thumbnail.
        width: 48,
        height: 48,
        child: InkWell(
          onTap: pending ? null : onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.darkGlassTop.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.9),
              ),
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 19,
                color: accent.withValues(alpha: pending ? 0.4 : 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The operator badge — "AB group".
///
/// Glass rather than a solid pill, per `DESIGN_SYSTEM.md` 5: badges sitting on
/// another glass surface use the shared material at the next layer up (6.1),
/// which is what `elevated` selects.
class _CompanyTag extends StatelessWidget {
  const _CompanyTag({required this.label, this.onPhoto = false});

  final String label;

  /// True when the tag sits directly on a photograph rather than on a glass
  /// card, which is the one case its label is white in both themes.
  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 110),
      child: GlassPanel(
        borderRadius: 999,
        elevated: true,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            // `label` from the type scale: 12 / 600.
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onPhoto ? Colors.white : AppColors.heading(context),
          ),
        ),
      ),
    );
  }
}

/// The row of "what's included" icons.
///
/// Stroke-only circles with the label beneath, per `DESIGN_SYSTEM.md` 11.1 —
/// the same feature-icon family the Home screen and Explore Nature already use.
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.features});

  final List<TourFeature> features;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final feature in features)
        Expanded(child: _FeatureIcon(feature: feature)),
    ],
  );
}

class _FeatureIcon extends StatelessWidget {
  const _FeatureIcon({required this.feature});

  final TourFeature feature;

  /// `DESIGN_SYSTEM.md` 11.1: circle 44–46dp, icon 22–24dp, stroke 1.5px.
  static const double circleSize = 44;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = AppColors.accent(context);
    final label = l10n.tourFeatureLabel(feature);

    return Semantics(
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Stroke only — no fill, per 11.1.
              border: Border.all(color: accent, width: 1.5),
            ),
            child: Icon(_iconFor(feature), size: 22, color: accent),
          ),
          const SizedBox(height: 4),
          // Allowed to shrink rather than overflow: "Photography" is far wider
          // than "Food", and the four columns are equal.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                // `label` from the type scale: 12 / 600.
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.heading(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(TourFeature feature) => switch (feature) {
    TourFeature.camping => Icons.cabin_outlined,
    TourFeature.hiking => Icons.hiking_rounded,
    TourFeature.guide => Icons.person_outline_rounded,
    TourFeature.food => Icons.restaurant_rounded,
    TourFeature.swimming => Icons.pool_outlined,
    TourFeature.campfire => Icons.local_fire_department_outlined,
    TourFeature.transport => Icons.directions_bus_outlined,
    TourFeature.photography => Icons.photo_camera_outlined,
  };
}

/// "$55 / per person", with the party total beneath it when more than one
/// person is travelling. In the small rounded-box badge family
/// (`DESIGN_SYSTEM.md` 13.4: radius 12, compact, high contrast).
class _PriceBox extends StatelessWidget {
  const _PriceBox({
    required this.price,
    required this.currency,
    required this.pricing,
  });

  final num price;
  final String currency;
  final TourPricing pricing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final perPerson = pricing.perPerson(price, currency);
    final total = pricing.total(price, currency);

    return Semantics(
      // The screen reader gets the operator's own price too, which is the one
      // that will actually be charged.
      label: pricing.isConverted(currency)
          ? '$perPerson (${formatMoney(price, currency)})'
          : perPerson,
      child: GlassPanel(
        borderRadius: 12,
        elevated: true,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              // A price is a measurement sequence: it stays left-to-right in
              // every language (`DESIGN_SYSTEM.md` 20).
              perPerson,
              textDirection: TextDirection.ltr,
              maxLines: 1,
              style: TextStyle(
                fontSize: 20,
                height: 24 / 20,
                fontWeight: FontWeight.w700,
                color: AppColors.heading(context),
              ),
            ),
            Text(
              l10n.tourPerPerson,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 14 / 11,
                color: AppColors.secondaryText(context),
              ),
            ),
            if (total != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.tourTotalFor(total),
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- Loading / error / empty ------------------------------------------------

/// Shared frame for this screen's loading, error and empty states, so the
/// layout does not jump between them.
class _PanelShell extends StatelessWidget {
  const _PanelShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => GlassPanel(
    borderRadius: _cardRadius,
    padding: const EdgeInsets.all(20),
    child: Center(child: child),
  );
}

class _PanelLoading extends StatelessWidget {
  const _PanelLoading();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 28,
    height: 28,
    child: CircularProgressIndicator(
      strokeWidth: 2.5,
      color: AppColors.accent(context),
    ),
  );
}

class _PanelMessage extends StatelessWidget {
  const _PanelMessage({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    final action = onAction;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.secondaryText(context),
          ),
        ),
        if (label != null && action != null) ...[
          const SizedBox(height: 14),
          Semantics(
            button: true,
            label: label,
            child: InkWell(
              onTap: action,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkOnPrimary : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
