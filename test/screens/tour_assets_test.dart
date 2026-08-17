import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/screens/tour_assets.dart';

void main() {
  test('tour flow shares the Explore Tours bundled background', () {
    expect(exploreToursBackgroundAsset, 'assets/images/explore tour.webp');
  });
}
