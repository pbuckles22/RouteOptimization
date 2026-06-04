import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:route_optimization/config/app_config.dart';
import 'package:route_optimization/services/search_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppConfig config;

  setUp(() {
    config = AppConfig.load(
      mapsApiKey: 'test-maps-key',
      mapboxAccessToken: 'test-mapbox',
    );
  });

  test('returns empty list for blank query without calling API', () async {
    var called = false;
    final service = SearchService(
      config,
      backend: SearchBackend.googlePlaces,
      client: MockClient((_) async {
        called = true;
        return http.Response('{}', 200);
      }),
    );

    expect(await service.search('   '), isEmpty);
    expect(called, isFalse);
  });

  group('Google Places proxy (autocomplete)', () {
    test('maps autocomplete predictions with location bias', () async {
      final service = SearchService(
        config,
        backend: SearchBackend.googlePlacesProxy,
        placesProxyBaseUrl: 'http://127.0.0.1:8765',
        client: MockClient((request) async {
          expect(request.url.path, '/search');
          expect(request.url.queryParameters['q'], '2314 Johnson');
          expect(request.url.queryParameters['lat'], '37.5');
          expect(request.url.queryParameters['lng'], '-122.0');

          return http.Response(
            jsonEncode({
              'status': 'OK',
              'predictions': [
                {
                  'place_id': 'addr-1',
                  'description':
                      '2314 Johnson Avenue, San Jose, CA 95129, USA',
                  'structured_formatting': {
                    'main_text': '2314 Johnson Avenue',
                    'secondary_text': 'San Jose, CA 95129, USA',
                  },
                  'types': ['street_address', 'geocode'],
                },
              ],
            }),
            200,
          );
        }),
      );

      final results = await service.search(
        '2314 Johnson',
        proximityLongitude: -122,
        proximityLatitude: 37.5,
      );

      expect(results, hasLength(1));
      expect(results.first.name, '2314 Johnson Avenue');
      expect(results.first.uuid, 'addr-1');
    });

    test('resolvePlace loads coordinates from details', () async {
      final service = SearchService(
        config,
        backend: SearchBackend.googlePlacesProxy,
        placesProxyBaseUrl: 'http://127.0.0.1:8765',
        client: MockClient((request) async {
          expect(request.url.path, '/details');
          expect(request.url.queryParameters['place_id'], 'addr-1');

          return http.Response(
            jsonEncode({
              'status': 'OK',
              'result': {
                'place_id': 'addr-1',
                'name': '2314 Johnson Avenue',
                'formatted_address': '2314 Johnson Ave, San Jose, CA',
                'geometry': {
                  'location': {'lat': 37.25, 'lng': -121.88},
                },
              },
            }),
            200,
          );
        }),
      );

      final resolved = await service.resolvePlace('addr-1');

      expect(resolved.latitude, 37.25);
      expect(resolved.longitude, -121.88);
      expect(resolved.formattedAddress, contains('Johnson'));
    });
  });

  group('Mapbox fallback', () {
    test('uses v6 forward with country and proximity', () async {
      final service = SearchService(
        config,
        backend: SearchBackend.mapboxGeocoding,
        client: MockClient((request) async {
          expect(request.url.path, '/search/geocode/v6/forward');
          expect(request.url.queryParameters['q'], '231');
          expect(request.url.queryParameters['country'], 'us');

          return http.Response(
            jsonEncode({
              'features': [
                {
                  'geometry': {'coordinates': [-121.9, 37.3]},
                  'properties': {
                    'mapbox_id': 'addr.1',
                    'feature_type': 'address',
                    'name': '231 North 1st Street',
                    'full_address':
                        '231 North 1st Street, San Jose, California',
                  },
                },
              ],
            }),
            200,
          );
        }),
      );

      final results = await service.search(
        '231',
        proximityLongitude: -122,
        proximityLatitude: 37,
      );

      expect(results.first.name, contains('231'));
    });
  });
}
