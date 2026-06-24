import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:route_optimization/app/route_wise_app.dart';
import 'package:route_optimization/config/app_config.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        _runStartupError(details.exceptionAsString());
      };
      runRouteWise();
    },
    (error, stack) {
      if (kDebugMode) {
        debugPrint('Uncaught error: $error\n$stack');
      }
      _runStartupError(error.toString());
    },
  );
}

void _runStartupError(String message) {
  runApp(RouteWiseConfigErrorApp(message: message));
}

/// Entry used by tests and production.
void runRouteWise() {
  if (kIsWeb && const bool.fromEnvironment('E2E_SEMANTICS')) {
    SemanticsBinding.instance.ensureSemantics();
  }

  try {
    final config = AppConfig.load();
    runApp(RouteWiseApp(config: config));
  } on AppConfigException catch (e) {
    runApp(RouteWiseConfigErrorApp(message: e.message));
  } catch (e) {
    runApp(
      RouteWiseConfigErrorApp(
        message: 'RouteWise failed to start: $e',
      ),
    );
  }
}
