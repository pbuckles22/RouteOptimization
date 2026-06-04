/// Runtime API keys from `--dart-define` (internal web testing only).
class AppConfig {
  AppConfig({
    required this.mapsApiKey,
    required this.mapboxAccessToken,
  });

  final String mapsApiKey;
  final String mapboxAccessToken;

  static const String mapsApiKeyDefine = 'MAPS_API_KEY';
  static const String mapboxTokenDefine = 'MAPBOX_ACCESS_TOKEN';

  /// Loads keys from compile-time environment unless overrides are supplied (tests).
  factory AppConfig.load({
    String? mapsApiKey,
    String? mapboxAccessToken,
  }) {
    final resolved = AppConfig(
      mapsApiKey:
          mapsApiKey ?? const String.fromEnvironment(mapsApiKeyDefine),
      mapboxAccessToken: mapboxAccessToken ??
          const String.fromEnvironment(mapboxTokenDefine),
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
