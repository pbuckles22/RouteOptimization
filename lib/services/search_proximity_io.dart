import 'package:geolocator/geolocator.dart';

/// Device GPS to bias address search near the user (iOS ship target).
Future<({double longitude, double latitude})?> readBrowserProximity() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        timeLimit: Duration(seconds: 6),
      ),
    );
    return (longitude: position.longitude, latitude: position.latitude);
  } catch (_) {
    return null;
  }
}
