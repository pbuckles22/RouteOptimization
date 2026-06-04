import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:route_optimization/config/app_config.dart';
import 'package:route_optimization/models/app_state.dart';
import 'package:route_optimization/models/route_location.dart';
import 'package:route_optimization/services/navigation_service.dart';
import 'package:route_optimization/services/optimization_result.dart';
import 'package:route_optimization/services/optimization_service.dart';
import 'package:route_optimization/services/search_service.dart';

class RouteProvider extends ChangeNotifier {
  RouteProvider({
    required AppConfig config,
    SearchService? searchService,
    OptimizationService? optimizationService,
    NavigationService? navigationService,
    Future<List<RouteLocation>> Function(String query)? searchOverride,
    Future<OptimizationResult> Function(List<RouteLocation> stops)?
        optimizeOverride,
  })  : _searchService = searchService ?? SearchService(config),
        _optimizationService =
            optimizationService ?? OptimizationService(config),
        _navigationService = navigationService ?? NavigationService(),
        _searchOverride = searchOverride,
        _optimizeOverride = optimizeOverride;

  final SearchService _searchService;
  final OptimizationService _optimizationService;
  final NavigationService _navigationService;
  final Future<List<RouteLocation>> Function(String query)? _searchOverride;
  final Future<OptimizationResult> Function(List<RouteLocation> stops)?
      _optimizeOverride;

  AppState currentState = AppState.idle;
  List<RouteLocation> activeStops = [];
  List<RouteLocation> searchResults = [];
  String? errorMessage;
  double? totalDistanceMiles;

  Timer? _debounceTimer;
  String _lastQuery = '';

  bool get canOptimize => activeStops.length >= 2;

  bool get canLaunchMaps =>
      currentState == AppState.success && activeStops.length >= 2;

  bool isOrigin(int index) => index == 0;

  void addStop(RouteLocation stop) {
    if (activeStops.any((s) => s.uuid == stop.uuid)) {
      return;
    }
    activeStops = [...activeStops, stop];
    currentState = AppState.idle;
    errorMessage = null;
    notifyListeners();
  }

  void removeStopAt(int index) {
    if (index == 0 || index < 0 || index >= activeStops.length) {
      return;
    }
    activeStops = [
      ...activeStops.sublist(0, index),
      ...activeStops.sublist(index + 1),
    ];
    currentState = AppState.idle;
    totalDistanceMiles = null;
    notifyListeners();
  }

  void onSearchQueryChanged(String query) {
    _lastQuery = query;
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      searchResults = [];
      currentState = AppState.idle;
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      unawaited(_runSearch(_lastQuery));
    });
  }

  Future<void> _runSearch(String query) async {
    currentState = AppState.searching;
    errorMessage = null;
    notifyListeners();

    try {
      final results = _searchOverride != null
          ? await _searchOverride(query)
          : await _searchService.search(query);
      if (query != _lastQuery) {
        return;
      }
      searchResults = results;
      currentState = AppState.idle;
    } catch (e) {
      if (query != _lastQuery) {
        return;
      }
      searchResults = [];
      currentState = AppState.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  void selectSearchResult(RouteLocation stop) {
    addStop(stop);
    searchResults = [];
    _lastQuery = '';
    notifyListeners();
  }

  Future<void> optimize() async {
    if (!canOptimize) {
      return;
    }

    currentState = AppState.optimizing;
    errorMessage = null;
    notifyListeners();

    try {
      final result = _optimizeOverride != null
          ? await _optimizeOverride(activeStops)
          : await _optimizationService.optimize(activeStops);
      activeStops = result.stops;
      totalDistanceMiles = result.totalDistanceMiles;
      currentState = AppState.success;
    } catch (e) {
      currentState = AppState.error;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> launchGoogleMaps() async {
    if (!canLaunchMaps) {
      return;
    }
    await _navigationService.launchGoogleMaps(activeStops);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
