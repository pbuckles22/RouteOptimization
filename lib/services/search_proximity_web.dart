import 'dart:async';

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Best-effort browser location to bias address autocomplete near the user.
Future<({double longitude, double latitude})?> readBrowserProximity() async {
  final geolocation = html.window.navigator.geolocation;

  try {
    final position = await geolocation
        .getCurrentPosition()
        .timeout(const Duration(seconds: 6));
    return (
      longitude: position.coords?.longitude?.toDouble() ?? 0,
      latitude: position.coords?.latitude?.toDouble() ?? 0,
    );
  } catch (_) {
    return null;
  }
}
