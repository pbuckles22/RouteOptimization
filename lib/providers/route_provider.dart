import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:route_optimization/config/app_config.dart';
import 'package:route_optimization/models/app_state.dart';
import 'package:route_optimization/models/route_location.dart';
import 'package:route_optimization/services/navigation_service.dart';
import 'package:route_optimization/services/optimization_result.dart';
import 'package:route_optimization/services/optimization_service.dart';
import 'package:route_optimization/services/search_proximity.dart';
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
    Future<({double longitude, double latitude})?> Function()? proximityReader,
  })  : _config = config,
        _searchService = searchService ?? SearchService(config),
        _optimizationService =
            optimizationService ?? OptimizationService(config),
        _navigationService = navigationService ?? NavigationService(),
        _searchOverride = searchOverride,
        _optimizeOverride = optimizeOverride,
        _proximityReader = proximityReader;

  final AppConfig _config;
  final SearchService _searchService;
  final OptimizationService _optimizationService;
  final NavigationService _navigationService;
  final Future<List<RouteLocation>> Function(String query)? _searchOverride;
  final Future<OptimizationResult> Function(List<RouteLocation> stops)?
      _optimizeOverride;
  final Future<({double longitude, double latitude})?> Function()?
      _proximityReader;

  AppState currentState = AppState.idle;
  List<RouteLocation> activeStops = [];
  List<RouteLocation> searchResults = [];
  String? errorMessage;
  double? totalDistanceMiles;

  Timer? _debounceTimer;
  String _lastQuery = '';
  double? _proximityLongitude;
  double? _proximityLatitude;
  bool _proximityRequested = false;

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

  /// Call once when the dashboard opens so address search is biased locally.
  Future<void> ensureSearchProximity() async {
    if (_proximityRequested) {
      return;
    }
    _proximityRequested = true;
    final readProximity = _proximityReader ?? readBrowserProximity;
    final position = await readProximity();
    if (position == null) {
      return;
    }
    _proximityLongitude = position.longitude;
    _proximityLatitude = position.latitude;
  }

  void onSearchQueryChanged(String query) {
    _lastQuery = query;
    _debounceTimer?.cancel();
    unawaited(ensureSearchProximity());

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
          : await _searchService.search(
              query,
              proximityLongitude:
                  _proximityLongitude ?? _config.searchProximityLongitude,
              proximityLatitude:
                  _proximityLatitude ?? _config.searchProximityLatitude,
            );
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
      errorMessage = _userFacingError(e);
    }
    notifyListeners();
  }

  Future<void> selectSearchResult(RouteLocation stop) async {
    currentState = AppState.searching;
    errorMessage = null;
    notifyListeners();

    try {
      final resolved = _searchOverride != null
          ? stop
          : await _searchService.resolvePlace(stop.uuid);
      addStop(resolved);
      searchResults = [];
      _lastQuery = '';
      currentState = AppState.idle;
    } catch (e) {
      currentState = AppState.error;
      errorMessage = _userFacingError(e);
    }
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
      errorMessage = _userFacingError(e);
    }
    notifyListeners();
  }

  static String _userFacingError(Object error) {
    if (error is SearchException) {
      return error.message;
    }
    if (error is OptimizationException) {
      return error.message;
    }
    final text = error.toString();
    if (text.contains('Failed to fetch') || text.contains('ClientException')) {
      if (kIsWeb) {
        return 'Search could not reach the server. Start the places proxy: '
            'dart run tool/places_proxy.dart';
      }
      return 'Search could not reach the server. Check your network connection.';
    }
    if (text.contains('Places proxy')) {
      return error.toString().replaceFirst('SearchException: ', '');
    }
    return 'Something went wrong. Please try again.';
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
