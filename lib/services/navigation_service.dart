import 'package:route_optimization/models/route_location.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  static Uri buildGoogleMapsUrl(List<RouteLocation> stops) {
    if (stops.length < 2) {
      throw ArgumentError('At least two stops are required for navigation');
    }

    final origin = stops.first;
    final destination = stops.last;
    final intermediates = stops.length > 2
        ? stops.sublist(1, stops.length - 1)
        : <RouteLocation>[];

    final params = <String, String>{
      'saddr': origin.latLngForGoogle,
      'daddr': destination.latLngForGoogle,
    };

    if (intermediates.isNotEmpty) {
      params['waypoints'] =
          intermediates.map((s) => s.latLngForGoogle).join('|');
    }

    return Uri.https('maps.google.com', '/', params);
  }

  Future<bool> launchGoogleMaps(List<RouteLocation> stops) async {
    final uri = buildGoogleMapsUrl(stops);
    return launchUrl(uri, webOnlyWindowName: '_blank');
  }
}
