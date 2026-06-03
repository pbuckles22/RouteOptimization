import 'package:flutter/material.dart';

void main() {
  runApp(const RouteOptimizationApp());
}

class RouteOptimizationApp extends StatelessWidget {
  const RouteOptimizationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Route Optimization',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Route Optimization'),
        ),
        body: const Center(
          child: Text('Replace with your app. Run tests: flutter test'),
        ),
      ),
    );
  }
}
