import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/models/nature_detail.dart';
import 'package:kurdistan_paradise_travel_guide/services/tours_service.dart';

void main() {
  setUp(ToursService.resetPreviewReviewState);

  test(
    'tour reviews read and write only through the selected tour id',
    () async {
      final service = ToursService();
      await service.submitReview(
        tourId: 'gali-alibag-waterfall',
        rating: 5,
        comment: 'A wonderful and well-organised tour.',
        userName: 'Preview Traveller',
      );

      final own = await service.fetchViewerReview('gali-alibag-waterfall');
      expect(own?.rating, 5);
      expect(await service.fetchViewerReview('gali-sherana'), isNull);

      final page = await service.fetchReviewPage(
        tourId: 'gali-alibag-waterfall',
        sort: ReviewSort.mostRecent,
      );
      expect(page.reviews.first.id, service.currentUid);
    },
  );

  test('tour helpful votes are scoped to that tour review', () async {
    final service = ToursService();
    await service.setHelpful(
      tourId: 'gali-alibag-waterfall',
      reviewId: 'seed-hemin',
      helpful: true,
    );

    expect(
      await service.fetchViewerVotes('gali-alibag-waterfall', ['seed-hemin']),
      {'seed-hemin'},
    );
    expect(
      await service.fetchViewerVotes('gali-sherana', ['seed-hemin']),
      isEmpty,
    );
  });
}
