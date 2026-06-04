import 'package:route_optimization/app/route_wise_app.dart';
import 'package:route_optimization/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app loads RouteWise dashboard', (WidgetTester tester) async {
    final config = AppConfig.load(
      mapsApiKey: 'test-maps',
      mapboxAccessToken: 'test-mapbox',
    );

    await tester.pumpWidget(RouteWiseApp(config: config));
    await tester.pumpAndSettle();

    expect(find.text('RouteWise'), findsOneWidget);
  });
}
