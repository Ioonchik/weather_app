import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<void> ensureServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw LocationServiceDisabled();
    }
  }

  Future<void> ensurePermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw PermissionDenied();
    }

    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedForever();
    }
  }

  Future<Position> getCurrentPositionOrThrow() async {
    await ensureServiceEnabled();
    await ensurePermissionGranted();
    return Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 12),
      ),
    );
  }
}

class LocationServiceDisabled implements Exception {}

class PermissionDenied implements Exception {}

class PermissionDeniedForever implements Exception {}
