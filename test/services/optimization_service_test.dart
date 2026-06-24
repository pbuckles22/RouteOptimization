import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:route_optimization/config/app_config.dart';
import 'package:route_optimization/models/route_location.dart';
import 'package:route_optimization/services/optimization_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppConfig config;

  setUp(() {
    config = AppConfig.load(
      mapsApiKey: 'maps',
      mapboxAccessToken: 'mapbox-token',
    );
  });

  const stops = [
    RouteLocation(
      uuid: 'a',
      name: 'Origin',
      formattedAddress: 'O',
      latitude: 37.0,
      longitude: -122.0,
    ),
    RouteLocation(
      uuid: 'b',
      name: 'B',
      formattedAddress: 'B',
      latitude: 37.1,
      longitude: -122.1,
    ),
    RouteLocation(
      uuid: 'c',
      name: 'C',
      formattedAddress: 'C',
      latitude: 37.2,
      longitude: -122.2,
    ),
  ];

  test('calls Mapbox driving profile with lng,lat coordinate order', () async {
    Uri? capturedUri;
    final service = OptimizationService(
      config,
      client: MockClient((request) async {
        capturedUri = request.url;
        return http.Response(
          jsonEncode({
            'code': 'Ok',
            'trips': [
              {'distance': 12345.6},
            ],
            'waypoints': [
              {'waypoint_index': 0},
              {'waypoint_index': 2},
              {'waypoint_index': 1},
            ],
          }),
          200,
        );
      }),
    );

    final result = await service.optimize(stops);

    expect(capturedUri!.path, contains('/mapbox/driving/'));
    expect(
      capturedUri!.pathSegments.last,
      '-122.0,37.0;-122.1,37.1;-122.2,37.2',
    );
    expect(capturedUri!.queryParameters['access_token'], 'mapbox-token');
    expect(capturedUri!.queryParameters['source'], 'first');
    expect(capturedUri!.queryParameters['destination'], 'last');
    expect(capturedUri!.queryParameters['roundtrip'], 'false');

    expect(result.stops.map((s) => s.uuid), ['a', 'c', 'b']);
    expect(result.totalDistanceMeters, closeTo(12345.6, 0.01));
  });

  test('throws when Mapbox returns non-Ok code', () async {
    final service = OptimizationService(
      config,
      client: MockClient(
        (_) async => http.Response(jsonEncode({'code': 'NoRoute'}), 200),
      ),
    );

    expect(
      () => service.optimize(stops),
      throwsA(isA<OptimizationException>()),
    );
  });
}
