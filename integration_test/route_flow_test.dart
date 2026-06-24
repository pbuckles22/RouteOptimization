import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:route_optimization/config/app_config.dart';

import '../test/e2e/route_flow_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('search → add stops → optimize → launch enabled (mocked APIs)', (
    WidgetTester tester,
  ) async {
    final config = AppConfig.load(
      mapsApiKey: 'test-maps',
      mapboxAccessToken: 'test-mapbox',
    );
    final provider = buildE2eRouteProvider(config);

    await pumpRouteDashboard(tester, provider);

    await e2eSearchAndSelect(tester, query: '2314', tapText: e2eStartStop.name);
    expect(find.text('Start'), findsOneWidget);

    await e2eSearchAndSelect(
      tester,
      query: 'burger',
      tapText: e2eSecondStop.name,
    );

    await tester.tap(find.text('Optimize route'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Estimated distance'), findsOneWidget);
    expectLaunchEnabled(tester);
  });
}
