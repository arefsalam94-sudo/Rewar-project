import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// A device position, reduced to the two numbers the distance calculation
/// needs. Keeps [DeviceLocationService] mockable without pulling Geolocator's
/// `Position` into widget tests.
@immutable
class DeviceLocation {
  const DeviceLocation(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

/// Reads the device's current position for the "N km from current location"
/// line on the Explore Nature cards.
///
/// **Never throws and never blocks the screen.** Every failure path — location
/// services switched off, permission denied, a GPS fix that times out, running
/// on a platform with no location at all — comes back as `null`, and the card
/// then hides its Distance row rather than inventing a number or showing a
/// distance from somewhere that is not where the user is.
///
/// Permission is requested only when it has not been decided yet, matching the
/// pattern already used by `map_screen.dart`. A `deniedForever` answer is never
/// re-prompted — that is the OS telling us to stop asking.
class DeviceLocationService {
  const DeviceLocationService();

  static const Duration _fixTimeout = Duration(seconds: 8);

  Future<DeviceLocation?> currentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          // "2.5km from current location" does not need a survey-grade fix,
          // and a lower accuracy target returns faster and costs less battery.
          accuracy: LocationAccuracy.medium,
          timeLimit: _fixTimeout,
        ),
      );
      return DeviceLocation(position.latitude, position.longitude);
    } catch (error) {
      debugPrint('Current location unavailable: $error');
      return null;
    }
  }
}
