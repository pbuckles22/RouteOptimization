import 'package:route_optimization/app/route_wise_app.dart';
import 'package:route_optimization/config/app_config.dart';
import 'package:route_optimization/models/route_location.dart';
import 'package:route_optimization/providers/route_provider.dart';
import 'package:route_optimization/ui/route_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('RouteWise dashboard loads with test config', (
    WidgetTester tester,
  ) async {
    final config = AppConfig.load(
      mapsApiKey: 'test-maps',
      mapboxAccessToken: 'test-mapbox',
    );

    await tester.pumpWidget(RouteWiseApp(config: config));
    await tester.pumpAndSettle();

    expect(find.text('RouteWise'), findsOneWidget);
    expect(find.text('Optimize route'), findsOneWidget);
    expect(find.text('Launch in Google Maps'), findsOneWidget);
  });

  testWidgets('search results on narrow layout do not overflow', (
    WidgetTester tester,
  ) async {
    final config = AppConfig.load(
      mapsApiKey: 'test-maps',
      mapboxAccessToken: 'test-mapbox',
    );
    final provider = RouteProvider(config: config)
      ..searchResults = List.generate(
        5,
        (i) => RouteLocation(
          uuid: 'stop-$i',
          name: 'Place $i',
          formattedAddress: '123 Example Street #$i, City, ST',
          latitude: 37.0 + i * 0.01,
          longitude: -122.0,
        ),
      );

    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(400, 600));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: RouteDashboard()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
