import 'package:flutter/material.dart';

import '../models/nature_detail.dart';
import '../models/nature_spot.dart';
import '../models/tour.dart';
import '../services/nature_spots_service.dart';
import '../services/tours_service.dart';
import '../services/user_profile_service.dart';
import 'nature_reviews_screen.dart';
import 'tour_assets.dart';

/// Tour-specific entry point for the shared Reviews & Ratings experience.
///
/// The visual interaction is deliberately identical to Explore Nature, while
/// [_TourReviewAdapter] redirects every read and write to
/// `tours/{tourId}/reviews`. This keeps one review UI without mixing the two
/// Firestore collections.
class TourReviewsScreen extends StatelessWidget {
  const TourReviewsScreen({
    super.key,
    required this.tour,
    this.toursService,
    this.userProfileService,
  });

  final Tour tour;
  final ToursService? toursService;
  final UserProfileService? userProfileService;

  @override
  Widget build(BuildContext context) {
    final service = toursService ?? ToursService();
    return NatureReviewsScreen(
      spot: _asNatureSpot(tour),
      natureSpotsService: _TourReviewAdapter(service),
      userProfileService: userProfileService,
      isTourReview: true,
      backgroundFallbackAsset: exploreToursBackgroundAsset,
      useSubjectPhotoForBackground: false,
    );
  }
}

NatureSpot _asNatureSpot(Tour tour) => NatureSpot(
  id: tour.id,
  names: tour.names,
  descriptions: tour.descriptions,
  locationLabels: tour.locationLabels,
  imageUrls: tour.imageUrls,
  imageAssets: tour.imageAssets,
  latitude: tour.latitude,
  longitude: tour.longitude,
  reviewScore: tour.reviewScore,
  ratingCount: tour.ratingCount,
  ratingBreakdown: tour.ratingBreakdown,
);

class _TourReviewAdapter extends NatureSpotsService {
  _TourReviewAdapter(this.service);

  final ToursService service;

  @override
  String? get currentUid => service.currentUid;

  @override
  bool get isSignedIn => service.currentUid != null;

  @override
  Future<List<NatureReview>> fetchTopReviews(String spotId) =>
      service.fetchTopReviews(spotId);

  @override
  Future<NatureReviewPage> fetchReviewPage({
    required String spotId,
    ReviewSort sort = ReviewSort.mostRecent,
    Object? startAfter,
  }) => service.fetchReviewPage(
    tourId: spotId,
    sort: sort,
    startAfter: startAfter,
  );

  @override
  Future<NatureSpot?> fetchSpot(String spotId) async {
    final tour = await service.fetchTour(spotId);
    return tour == null ? null : _asNatureSpot(tour);
  }

  @override
  Future<NatureReview?> fetchViewerReview(String spotId) =>
      service.fetchViewerReview(spotId);

  @override
  Future<void> submitReview({
    required String spotId,
    required double rating,
    required String comment,
    required String userName,
    String? avatarUrl,
  }) => service.submitReview(
    tourId: spotId,
    rating: rating,
    comment: comment,
    userName: userName,
    avatarUrl: avatarUrl,
  );

  @override
  Future<Set<String>> fetchViewerVotes(
    String spotId,
    Iterable<String> reviewIds,
  ) => service.fetchViewerVotes(spotId, reviewIds);

  @override
  Future<void> setHelpful({
    required String spotId,
    required String reviewId,
    required bool helpful,
  }) =>
      service.setHelpful(tourId: spotId, reviewId: reviewId, helpful: helpful);
}
