import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:route_optimization/config/app_config.dart';
import 'package:route_optimization/providers/route_provider.dart';
import 'package:route_optimization/ui/route_dashboard.dart';

class RouteWiseApp extends StatelessWidget {
  const RouteWiseApp({required this.config, super.key});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RouteProvider(config: config),
      child: MaterialApp(
        title: 'RouteWise',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const RouteDashboard(),
      ),
    );
  }
}

class RouteWiseConfigErrorApp extends StatelessWidget {
  const RouteWiseConfigErrorApp({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
