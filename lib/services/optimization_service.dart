import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:route_optimization/config/app_config.dart';
import 'package:route_optimization/models/route_location.dart';
import 'package:route_optimization/services/optimization_result.dart';

class OptimizationException implements Exception {
  OptimizationException(this.message);

  final String message;

  @override
  String toString() => 'OptimizationException: $message';
}

class OptimizationService {
  OptimizationService(this.config, {http.Client? client})
      : _client = client ?? http.Client();

  final AppConfig config;
  final http.Client _client;

  /// Distance-based ordering via Mapbox `driving` profile (no traffic).
  Future<OptimizationResult> optimize(List<RouteLocation> stops) async {
    if (stops.length < 2) {
      throw ArgumentError('At least two stops are required to optimize');
    }

    final coordinates = stops
        .map((s) => '${s.longitude},${s.latitude}')
        .join(';');

    final uri = Uri.https(
      'api.mapbox.com',
      '/optimized-trips/v1/mapbox/driving/$coordinates',
      {
        'access_token': config.mapboxAccessToken,
        'source': 'first',
        // Mapbox returns NotImplemented for destination=any + roundtrip=false.
        'destination': 'last',
        'roundtrip': 'false',
      },
    );

    final response = await _client.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final code = body['code'] as String? ?? 'Unknown';

    if (code != 'Ok') {
      throw OptimizationException('Mapbox optimization code: $code');
    }

    final waypoints = body['waypoints'] as List<dynamic>;
    final reordered = List<RouteLocation?>.filled(stops.length, null);

    for (var i = 0; i < waypoints.length; i++) {
      final waypoint = waypoints[i] as Map<String, dynamic>;
      final index = waypoint['waypoint_index'] as int;
      reordered[index] = stops[i];
    }

    final trips = body['trips'] as List<dynamic>?;
    final distance = trips == null || trips.isEmpty
        ? 0.0
        : (trips.first as Map<String, dynamic>)['distance'] as num;

    return OptimizationResult(
      stops: reordered.cast<RouteLocation>(),
      totalDistanceMeters: distance.toDouble(),
    );
  }
}
