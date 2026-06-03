import 'package:route_optimization/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App loads and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const RouteOptimizationApp());
    await tester.pumpAndSettle();

    expect(find.text('Route Optimization'), findsOneWidget);
  });
}
