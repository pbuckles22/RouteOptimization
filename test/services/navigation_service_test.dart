import 'package:route_optimization/models/route_location.dart';
import 'package:route_optimization/services/navigation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigationService.buildGoogleMapsUrl', () {
    test('builds saddr, daddr, and pipe-separated waypoints', () {
      const stops = [
        RouteLocation(
          uuid: '1',
          name: 'Start',
          formattedAddress: 'A',
          latitude: 37.0,
          longitude: -122.0,
        ),
        RouteLocation(
          uuid: '2',
          name: 'Mid',
          formattedAddress: 'B',
          latitude: 37.1,
          longitude: -122.1,
        ),
        RouteLocation(
          uuid: '3',
          name: 'End',
          formattedAddress: 'C',
          latitude: 37.2,
          longitude: -122.2,
        ),
      ];

      final url = NavigationService.buildGoogleMapsUrl(stops);

      expect(url.host, 'maps.google.com');
      expect(url.queryParameters['saddr'], '37.0,-122.0');
      expect(url.queryParameters['daddr'], '37.2,-122.2');
      expect(url.queryParameters['waypoints'], '37.1,-122.1');
    });

    test('throws when fewer than two stops', () {
      expect(
        () => NavigationService.buildGoogleMapsUrl([
          const RouteLocation(
            uuid: '1',
            name: 'Only',
            formattedAddress: 'A',
            latitude: 1,
            longitude: 2,
          ),
        ]),
        throwsArgumentError,
      );
    });
  });
}
