import 'package:route_optimization/config/app_config.dart';
import 'package:route_optimization/models/app_state.dart';
import 'package:route_optimization/models/route_location.dart';
import 'package:route_optimization/providers/route_provider.dart';
import 'package:route_optimization/services/optimization_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppConfig config;

  setUp(() {
    config = AppConfig.load(
      mapsApiKey: 'maps',
      mapboxAccessToken: 'mapbox',
    );
  });

  RouteProvider buildProvider({
    Future<OptimizationResult> Function(List<RouteLocation> stops)? optimizeFn,
  }) {
    return RouteProvider(
      config: config,
      optimizeOverride: optimizeFn,
    );
  }

  test('addStop rejects duplicate uuid', () {
    const stop = RouteLocation(
      uuid: 'dup',
      name: 'A',
      formattedAddress: '1',
      latitude: 0,
      longitude: 0,
    );
    final provider = buildProvider();

    provider.addStop(stop);
    provider.addStop(stop);

    expect(provider.activeStops, hasLength(1));
  });

  test('first stop is origin and cannot be removed', () {
    const stop = RouteLocation(
      uuid: 'origin',
      name: 'Start',
      formattedAddress: '1',
      latitude: 0,
      longitude: 0,
    );
    final provider = buildProvider()..addStop(stop);

    provider.removeStopAt(0);

    expect(provider.activeStops, hasLength(1));
    expect(provider.isOrigin(0), isTrue);
  });

  test('canOptimize is false until at least two stops', () {
    final provider = buildProvider();
    expect(provider.canOptimize, isFalse);

    provider.addStop(
      const RouteLocation(
        uuid: '1',
        name: 'A',
        formattedAddress: 'a',
        latitude: 0,
        longitude: 0,
      ),
    );
    expect(provider.canOptimize, isFalse);

    provider.addStop(
      const RouteLocation(
        uuid: '2',
        name: 'B',
        formattedAddress: 'b',
        latitude: 1,
        longitude: 1,
      ),
    );
    expect(provider.canOptimize, isTrue);
  });

  test('optimize reorders stops and sets success state', () async {
    final provider = buildProvider(
      optimizeFn: (_) async => const OptimizationResult(
        stops: [
          RouteLocation(
            uuid: '1',
            name: 'A',
            formattedAddress: 'a',
            latitude: 0,
            longitude: 0,
          ),
          RouteLocation(
            uuid: '2',
            name: 'B',
            formattedAddress: 'b',
            latitude: 1,
            longitude: 1,
          ),
        ],
        totalDistanceMeters: 5000,
      ),
    );
    provider.addStop(
      const RouteLocation(
        uuid: '1',
        name: 'A',
        formattedAddress: 'a',
        latitude: 0,
        longitude: 0,
      ),
    );
    provider.addStop(
      const RouteLocation(
        uuid: '2',
        name: 'B',
        formattedAddress: 'b',
        latitude: 1,
        longitude: 1,
      ),
    );

    await provider.optimize();

    expect(provider.currentState, AppState.success);
    expect(provider.totalDistanceMiles, closeTo(3.11, 0.1));
    expect(provider.canLaunchMaps, isTrue);
  });
}
