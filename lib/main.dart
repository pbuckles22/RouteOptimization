import 'package:flutter/material.dart';
import 'package:route_optimization/app/route_wise_app.dart';
import 'package:route_optimization/config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runRouteWise();
}

/// Entry used by tests and production.
void runRouteWise() {
  try {
    final config = AppConfig.load();
    runApp(RouteWiseApp(config: config));
  } on AppConfigException catch (e) {
    runApp(RouteWiseConfigErrorApp(message: e.message));
  }
}
