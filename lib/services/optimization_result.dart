import 'package:route_optimization/models/route_location.dart';

class OptimizationResult {
  const OptimizationResult({
    required this.stops,
    required this.totalDistanceMeters,
  });

  final List<RouteLocation> stops;
  final double totalDistanceMeters;

  double get totalDistanceMiles => totalDistanceMeters / 1609.344;
}
