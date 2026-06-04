/// Runtime API keys from `--dart-define` (internal web testing only).
class AppConfig {
  AppConfig({
    required this.mapsApiKey,
    required this.mapboxAccessToken,
    this.searchCountry = 'us',
    this.searchProximityLongitude,
    this.searchProximityLatitude,
  });

  final String mapsApiKey;
  final String mapboxAccessToken;

  /// ISO country code to bias Mapbox fallback (e.g. `us`).
  final String searchCountry;

  /// Optional fixed map center when browser geolocation is unavailable.
  final double? searchProximityLongitude;
  final double? searchProximityLatitude;

  static const String mapsApiKeyDefine = 'MAPS_API_KEY';
  static const String mapboxTokenDefine = 'MAPBOX_ACCESS_TOKEN';
  static const String searchCountryDefine = 'SEARCH_COUNTRY';
  static const String searchProximityLngDefine = 'SEARCH_PROXIMITY_LNG';
  static const String searchProximityLatDefine = 'SEARCH_PROXIMITY_LAT';

  /// Loads keys from compile-time environment unless overrides are supplied (tests).
  factory AppConfig.load({
    String? mapsApiKey,
    String? mapboxAccessToken,
    String? searchCountry,
    double? searchProximityLongitude,
    double? searchProximityLatitude,
  }) {
    const lngFromEnv =
        String.fromEnvironment(searchProximityLngDefine, defaultValue: '');
    const latFromEnv =
        String.fromEnvironment(searchProximityLatDefine, defaultValue: '');
    final lng = searchProximityLongitude ??
        (lngFromEnv.isEmpty ? null : double.tryParse(lngFromEnv));
    final lat = searchProximityLatitude ??
        (latFromEnv.isEmpty ? null : double.tryParse(latFromEnv));

    final resolved = AppConfig(
      mapsApiKey:
          mapsApiKey ?? const String.fromEnvironment(mapsApiKeyDefine),
      mapboxAccessToken: mapboxAccessToken ??
          const String.fromEnvironment(mapboxTokenDefine),
      searchCountry: searchCountry ??
          const String.fromEnvironment(searchCountryDefine, defaultValue: 'us'),
      searchProximityLongitude: lng,
      searchProximityLatitude: lat,
    );
    if (resolved.mapsApiKey.isEmpty || resolved.mapboxAccessToken.isEmpty) {
      throw AppConfigException(
        'Missing API keys. Run with '
        '--dart-define=$mapsApiKeyDefine=... '
        '--dart-define=$mapboxTokenDefine=...',
      );
    }
    return resolved;
  }

}

class AppConfigException implements Exception {
  AppConfigException(this.message);

  final String message;

  @override
  String toString() => 'AppConfigException: $message';
}
