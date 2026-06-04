import 'package:route_optimization/app/route_wise_app.dart';
import 'package:route_optimization/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
