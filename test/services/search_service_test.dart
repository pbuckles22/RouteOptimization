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
      client: MockClient((_) async {
        called = true;
        return http.Response('{}', 200);
      }),
    );

    final results = await service.search('   ');

    expect(results, isEmpty);
    expect(called, isFalse);
  });

  test('maps up to five Google Places text search results', () async {
    final service = SearchService(
      config,
      client: MockClient((request) async {
        expect(request.url.host, 'maps.googleapis.com');
        expect(request.url.queryParameters['key'], 'test-maps-key');
        expect(request.url.queryParameters['query'], 'mcdonalds');

        return http.Response(
          jsonEncode({
            'status': 'OK',
            'results': List.generate(
              7,
              (i) => {
                'place_id': 'place-$i',
                'name': 'McDonald\'s $i',
                'formatted_address': 'Street $i',
                'geometry': {
                  'location': {'lat': 37.0 + i, 'lng': -122.0 - i},
                },
              },
            ),
          }),
          200,
        );
      }),
    );

    final results = await service.search('mcdonalds');

    expect(results, hasLength(5));
    expect(results.first.name, 'McDonald\'s 0');
    expect(results.first.uuid, 'place-0');
    expect(results.first.latitude, 37.0);
    expect(results.first.longitude, -122.0);
  });

  test('throws when API status is not OK', () async {
    final service = SearchService(
      config,
      client: MockClient(
        (_) async =>
            http.Response(jsonEncode({'status': 'REQUEST_DENIED'}), 200),
      ),
    );

    expect(() => service.search('query'), throwsA(isA<SearchException>()));
  });
}
