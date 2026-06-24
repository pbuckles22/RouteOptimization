import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:route_optimization/config/app_config.dart';
import 'package:route_optimization/models/route_location.dart';
import 'package:route_optimization/providers/route_provider.dart';
import 'package:route_optimization/services/optimization_result.dart';
import 'package:route_optimization/ui/route_dashboard.dart';

/// Shared mock stops for full UI flow tests (Tier 2 E2E).
const e2eStartStop = RouteLocation(
  uuid: 'place-start',
  name: '2314 Joree Ln',
  formattedAddress: '2314 Joree Ln, San Ramon, CA',
  latitude: 37.7799,
  longitude: -121.978,
);

const e2eSecondStop = RouteLocation(
  uuid: 'place-second',
  name: 'Burger King',
  formattedAddress: '5315 Hopyard Rd, Pleasanton, CA',
  latitude: 37.6945,
  longitude: -121.875,
);

RouteProvider buildE2eRouteProvider(AppConfig config) {
  return RouteProvider(
    config: config,
    searchOverride: (query) async {
      final q = query.toLowerCase();
      if (q.contains('2314')) {
        return [e2eStartStop];
      }
      if (q.contains('burger')) {
        return [e2eSecondStop];
      }
      return [];
    },
    optimizeOverride: (stops) async {
      return OptimizationResult(
        stops: stops,
        totalDistanceMeters: 12_000,
      );
    },
  );
}

Future<void> e2eSearchAndSelect(
  WidgetTester tester, {
  required String query,
  required String tapText,
}) async {
  await tester.enterText(find.byType(TextField), query);
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
  await tester.tap(find.text(tapText).first);
  await tester.pumpAndSettle();
}

Future<void> pumpRouteDashboard(WidgetTester tester, RouteProvider provider) async {
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: provider,
      child: const MaterialApp(home: RouteDashboard()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Asserts Launch in Google Maps is tappable (optimize succeeded).
void expectLaunchEnabled(WidgetTester tester) {
  expect(find.text('Launch in Google Maps'), findsOneWidget);
  final launchLabel = find.text('Launch in Google Maps');
  final button = find.ancestor(
    of: launchLabel,
    matching: find.byWidgetPredicate(
      (widget) => widget is FilledButton || widget is ButtonStyleButton,
    ),
  );
  expect(button, findsOneWidget);
  final widget = tester.widget<ButtonStyleButton>(button);
  expect(widget.onPressed, isNotNull);
}
