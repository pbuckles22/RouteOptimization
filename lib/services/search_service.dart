import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:route_optimization/config/app_config.dart';
import 'package:route_optimization/models/route_location.dart';

class SearchException implements Exception {
  SearchException(this.message);

  final String message;

  @override
  String toString() => 'SearchException: $message';
}

class SearchService {
  SearchService(this.config, {http.Client? client})
      : _client = client ?? http.Client();

  final AppConfig config;
  final http.Client _client;

  static const int maxResults = 5;

  Future<List<RouteLocation>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/textsearch/json',
      {'query': trimmed, 'key': config.mapsApiKey},
    );

    final response = await _client.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final status = body['status'] as String? ?? 'UNKNOWN';

    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw SearchException('Places API status: $status');
    }

    final results = body['results'] as List<dynamic>? ?? [];
    return results.take(maxResults).map(_mapResult).toList();
  }

  RouteLocation _mapResult(dynamic raw) {
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
}
