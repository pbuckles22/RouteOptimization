import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:route_optimization/config/app_config.dart';
import 'package:route_optimization/models/route_location.dart';

class SearchException implements Exception {
  SearchException(this.message);

  final String message;

  @override
  String toString() => 'SearchException: $message';
}

/// Web: Google via local proxy, then Mapbox fallback. Native: Google Places direct.
enum SearchBackend { googlePlaces, mapboxGeocoding, googlePlacesProxy }

class SearchService {
  SearchService(
    this.config, {
    http.Client? client,
    SearchBackend? backend,
    String? placesProxyBaseUrl,
  })  : _client = client ?? http.Client(),
        _placesProxyBaseUrl = placesProxyBaseUrl ?? _defaultProxyBaseUrl,
        _backend = backend ?? _defaultBackend;

  final AppConfig config;
  final http.Client _client;
  final SearchBackend _backend;
  final String? _placesProxyBaseUrl;

  static const int maxResults = 5;
  static const String defaultPlacesProxyBaseUrl = 'http://127.0.0.1:8765';

  static SearchBackend get _defaultBackend => kIsWeb
      ? SearchBackend.googlePlacesProxy
      : SearchBackend.googlePlaces;

  static String? get _defaultProxyBaseUrl =>
      kIsWeb ? defaultPlacesProxyBaseUrl : null;

  Future<List<RouteLocation>> search(
    String query, {
    double? proximityLongitude,
    double? proximityLatitude,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    return switch (_backend) {
      SearchBackend.googlePlaces => _searchGooglePlaces(trimmed),
      SearchBackend.googlePlacesProxy => _searchWithProxyAndFallback(
          trimmed,
          proximityLongitude: proximityLongitude,
          proximityLatitude: proximityLatitude,
        ),
      SearchBackend.mapboxGeocoding => _searchMapbox(
          trimmed,
          proximityLongitude: proximityLongitude,
          proximityLatitude: proximityLatitude,
        ),
    };
  }

  Future<List<RouteLocation>> _searchWithProxyAndFallback(
    String query, {
    double? proximityLongitude,
    double? proximityLatitude,
  }) async {
    try {
      final proxyResults = await _searchGooglePlacesProxy(
        query,
        proximityLongitude: proximityLongitude,
        proximityLatitude: proximityLatitude,
      );
      if (proxyResults.isNotEmpty) {
        return proxyResults;
      }
    } on SearchException {
      rethrow;
    } catch (_) {
      // Proxy not running or unreachable — fall back to Mapbox.
    }

    return _searchMapbox(
      query,
      proximityLongitude: proximityLongitude,
      proximityLatitude: proximityLatitude,
    );
  }

  Future<List<RouteLocation>> _searchGooglePlacesProxy(
    String query, {
    double? proximityLongitude,
    double? proximityLatitude,
  }) async {
    final base = _placesProxyBaseUrl;
    if (base == null || base.isEmpty) {
      throw SearchException('Places proxy URL is not configured.');
    }

    final params = <String, String>{
      'q': query,
      'country': config.searchCountry,
    };
    if (proximityLongitude != null && proximityLatitude != null) {
      params['lat'] = '$proximityLatitude';
      params['lng'] = '$proximityLongitude';
    }

    final uri = Uri.parse(base).replace(
      path: '/search',
      queryParameters: params,
    );

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw SearchException(
        'Places proxy failed (HTTP ${response.statusCode}). '
        'Run: dart run tool/places_proxy.dart',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final status = body['status'] as String? ?? 'UNKNOWN';

    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw SearchException('Places search failed ($status).');
    }

    final predictions = body['predictions'] as List<dynamic>? ?? [];
    return predictions
        .take(maxResults)
        .map(_mapAutocompletePrediction)
        .toList();
  }

  /// Resolves lat/lng and canonical address after user picks an autocomplete row.
  Future<RouteLocation> resolvePlace(String placeId) async {
    return switch (_backend) {
      SearchBackend.googlePlacesProxy => _resolvePlaceProxy(placeId),
      SearchBackend.googlePlaces => _resolvePlaceGoogle(placeId),
      SearchBackend.mapboxGeocoding => throw SearchException(
          'Place resolution is not supported for Mapbox search.',
        ),
    };
  }

  Future<RouteLocation> _resolvePlaceProxy(String placeId) async {
    final base = _placesProxyBaseUrl!;
    final uri = Uri.parse(base).replace(
      path: '/details',
      queryParameters: {'place_id': placeId},
    );

    final response = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw SearchException('Could not load place details.');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final status = body['status'] as String? ?? 'UNKNOWN';
    if (status != 'OK') {
      throw SearchException('Place details failed ($status).');
    }

    return _mapGoogleDetails(body['result'] as Map<String, dynamic>);
  }

  Future<RouteLocation> _resolvePlaceGoogle(String placeId) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {
        'place_id': placeId,
        'fields': 'place_id,name,formatted_address,geometry',
        'key': config.mapsApiKey,
      },
    );

    final response = await _client.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final status = body['status'] as String? ?? 'UNKNOWN';
    if (status != 'OK') {
      throw SearchException('Place details failed ($status).');
    }

    return _mapGoogleDetails(body['result'] as Map<String, dynamic>);
  }

  Future<List<RouteLocation>> _searchGooglePlaces(String query) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/textsearch/json',
      {'query': query, 'key': config.mapsApiKey},
    );

    final response = await _client.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final status = body['status'] as String? ?? 'UNKNOWN';

    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw SearchException('Places search failed ($status).');
    }

    final results = body['results'] as List<dynamic>? ?? [];
    return results.take(maxResults).map(_mapGoogleResult).toList();
  }

  Future<List<RouteLocation>> _searchMapbox(
    String query, {
    double? proximityLongitude,
    double? proximityLatitude,
  }) async {
    final v6 = await _searchMapboxV6(
      query,
      proximityLongitude: proximityLongitude,
      proximityLatitude: proximityLatitude,
    );
    if (v6.isNotEmpty) {
      return v6;
    }

    return _searchMapboxV5Broad(
      query,
      proximityLongitude: proximityLongitude,
      proximityLatitude: proximityLatitude,
    );
  }

  Future<List<RouteLocation>> _searchMapboxV6(
    String query, {
    double? proximityLongitude,
    double? proximityLatitude,
  }) async {
    final params = <String, String>{
      'q': query,
      'access_token': config.mapboxAccessToken,
      'limit': '10',
      'autocomplete': 'true',
      'country': config.searchCountry,
    };

    if (proximityLongitude != null && proximityLatitude != null) {
      params['proximity'] = '$proximityLongitude,$proximityLatitude';
    }

    final uri = Uri.https(
      'api.mapbox.com',
      '/search/geocode/v6/forward',
      params,
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      return [];
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final features = body['features'] as List<dynamic>? ?? [];

    final ranked = features
        .cast<Map<String, dynamic>>()
        .where((f) => _isUsefulV6(f, query))
        .toList()
      ..sort((a, b) => _v6Rank(a, query).compareTo(_v6Rank(b, query)));

    return ranked.take(maxResults).map(_mapMapboxV6Feature).toList();
  }

  Future<List<RouteLocation>> _searchMapboxV5Broad(
    String query, {
    double? proximityLongitude,
    double? proximityLatitude,
  }) async {
    final params = <String, String>{
      'access_token': config.mapboxAccessToken,
      'limit': '10',
      'autocomplete': 'true',
      'country': config.searchCountry,
    };

    if (proximityLongitude != null && proximityLatitude != null) {
      params['proximity'] = '$proximityLongitude,$proximityLatitude';
    }

    final uri = Uri.https(
      'api.mapbox.com',
      '/geocoding/v5/mapbox.places/$query.json',
      params,
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw SearchException(
        'Search failed (HTTP ${response.statusCode}).',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final features = body['features'] as List<dynamic>? ?? [];

    final ranked = features
        .cast<Map<String, dynamic>>()
        .where((f) => _isUsefulV5(f, query))
        .toList()
      ..sort((a, b) => _v5Rank(a, query).compareTo(_v5Rank(b, query)));

    return ranked.take(maxResults).map(_mapMapboxFeature).toList();
  }

  bool _queryLooksLikeAddress(String query) {
    return RegExp(r'\d').hasMatch(query);
  }

  bool _isUsefulV6(Map<String, dynamic> feature, String query) {
    final props = feature['properties'] as Map<String, dynamic>? ?? {};
    final type = props['feature_type'] as String? ?? '';
    if (type == 'address' || type == 'street' || type == 'poi') {
      return true;
    }
    if (_queryLooksLikeAddress(query) &&
        (type == 'place' || type == 'region' || type == 'country')) {
      return false;
    }
    return type.isNotEmpty && type != 'country' && type != 'region';
  }

  int _v6Rank(Map<String, dynamic> feature, String query) {
    final type =
        (feature['properties'] as Map<String, dynamic>?)?['feature_type']
            as String? ??
        '';
    final addressLike = _queryLooksLikeAddress(query);
    if (addressLike) {
      return switch (type) {
        'address' || 'street' => 0,
        'poi' => 2,
        'place' => 50,
        _ => 25,
      };
    }
    return switch (type) {
      'poi' => 0,
      'address' || 'street' => 1,
      'place' => 10,
      _ => 20,
    };
  }

  bool _isUsefulV5(Map<String, dynamic> feature, String query) {
    final types =
        (feature['place_type'] as List<dynamic>?)?.cast<String>() ?? [];
    if (types.contains('address') || types.contains('poi')) {
      return true;
    }
    if (_queryLooksLikeAddress(query) &&
        (types.contains('place') || types.contains('region'))) {
      return false;
    }
    return types.isNotEmpty;
  }

  int _v5Rank(Map<String, dynamic> feature, String query) {
    final types =
        (feature['place_type'] as List<dynamic>?)?.cast<String>() ?? [];
    final addressLike = _queryLooksLikeAddress(query);
    if (addressLike) {
      if (types.contains('address')) return 0;
      if (types.contains('poi')) return 2;
      if (types.contains('place')) return 50;
    } else {
      if (types.contains('poi')) return 0;
      if (types.contains('address')) return 1;
    }
    return 25;
  }

  RouteLocation _mapAutocompletePrediction(dynamic raw) {
    final json = raw as Map<String, dynamic>;
    final structured =
        json['structured_formatting'] as Map<String, dynamic>? ?? {};
    final mainText = structured['main_text'] as String? ?? '';
    final description = json['description'] as String? ?? mainText;

    return RouteLocation(
      uuid: json['place_id'] as String,
      name: mainText.isNotEmpty ? mainText : description,
      formattedAddress: description,
      latitude: 0,
      longitude: 0,
    );
  }

  RouteLocation _mapGoogleDetails(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>;
    final location = geometry['location'] as Map<String, dynamic>;

    return RouteLocation(
      uuid: json['place_id'] as String,
      name: json['name'] as String? ?? 'Unknown place',
      formattedAddress:
          json['formatted_address'] as String? ?? 'Address unavailable',
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
    );
  }

  RouteLocation _mapGoogleResult(dynamic raw) {
    final json = raw as Map<String, dynamic>;
    final geometry = json['geometry'] as Map<String, dynamic>;
    final location = geometry['location'] as Map<String, dynamic>;

    return RouteLocation(
      uuid: json['place_id'] as String? ?? json['name'] as String,
      name: json['name'] as String? ?? 'Unknown place',
      formattedAddress:
          json['formatted_address'] as String? ?? 'Address unavailable',
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
    );
  }

  RouteLocation _mapMapboxV6Feature(Map<String, dynamic> feature) {
    final props = feature['properties'] as Map<String, dynamic>? ?? {};
    final coords =
        (feature['geometry'] as Map<String, dynamic>?)?['coordinates']
            as List<dynamic>? ??
        [0, 0];
    final name = props['name'] as String? ??
        props['place_formatted'] as String? ??
        'Unknown';
    final address = props['full_address'] as String? ??
        props['place_formatted'] as String? ??
        name;

    return RouteLocation(
      uuid: props['mapbox_id'] as String? ?? name,
      name: name,
      formattedAddress: address,
      longitude: (coords[0] as num).toDouble(),
      latitude: (coords[1] as num).toDouble(),
    );
  }

  RouteLocation _mapMapboxFeature(Map<String, dynamic> json) {
    final center = json['center'] as List<dynamic>;
    final placeName = json['place_name'] as String? ?? 'Unknown location';
    final text = json['text'] as String?;

    return RouteLocation(
      uuid: json['id'] as String? ?? placeName,
      name: text ?? placeName.split(',').first.trim(),
      formattedAddress: placeName,
      longitude: (center[0] as num).toDouble(),
      latitude: (center[1] as num).toDouble(),
    );
  }
}
