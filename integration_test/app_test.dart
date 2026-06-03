import 'package:route_optimization/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app loads and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const app.RouteOptimizationApp());
    await tester.pumpAndSettle();

    expect(find.text('Route Optimization'), findsOneWidget);
  });
}
