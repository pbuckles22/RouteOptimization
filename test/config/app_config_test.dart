import 'package:route_optimization/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig.load', () {
    test('returns config when both keys are non-empty', () {
      final config = AppConfig.load(
        mapsApiKey: 'maps-key',
        mapboxAccessToken: 'mapbox-token',
      );

      expect(config.mapsApiKey, 'maps-key');
      expect(config.mapboxAccessToken, 'mapbox-token');
    });

    test('throws when maps API key is empty', () {
      expect(
        () => AppConfig.load(mapsApiKey: '', mapboxAccessToken: 'token'),
        throwsA(isA<AppConfigException>()),
      );
    });

    test('throws when Mapbox token is empty', () {
      expect(
        () => AppConfig.load(mapsApiKey: 'key', mapboxAccessToken: ''),
        throwsA(isA<AppConfigException>()),
      );
    });
  });
}
