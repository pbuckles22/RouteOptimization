# MASTER_BLUEPRINT: RouteWise Phase 1 (Web Prototype)

> **Platform note (2026):** The **ship target is iOS**. This doc describes shared map/search/optimize behavior. **PM_PLAN.md → Platform strategy** supersedes “web-first” wording below. Flutter Web and `tool/places_proxy.dart` are **dev-only** harnesses—not the product architecture.

## ==========================================
## PART 1: SYSTEM SPECIFICATIONS (The Guardrails)
## ==========================================

### 1.1 Architecture & Constraints
* **Target Framework:** Pure Flutter/Dart (Material 3).
* **Target Execution Environment:** Flutter Web (`flutter run -d chrome`). 
* **FFI Exclusion:** Absolute prohibition on native Go/Rust FFI modules for Phase 1. All routing, geospatial rendering, and traffic matrices must be handled via cloud endpoints to ensure frictionless web compilation.
* **State Patterns:** Centralized Change Notifier (`ChangeNotifier`) acting as a state controller, paired with isolated service/repository classes.

### 1.2 Data Domain Model
```dart
import 'package:uuid/uuid.dart';

class RouteLocation {
  final String uuid;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;

  RouteLocation({
    String? uuid,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  }) : uuid = uuid ?? const Uuid().v4();

  factory RouteLocation.fromJson(Map<String, dynamic> json) {
    return RouteLocation(
      uuid: json['uuid'] as String?,
      name: json['name'] as String,
      formattedAddress: json['address'] as String,
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    'address': formattedAddress,
    'lat': latitude,
    'lng': longitude,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteLocation && runtimeType == other.runtimeType && uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;
}
```

### 1.3 Key API Contracts
* **Config Strategy:** Keys must be extracted via `String.fromEnvironment('KEY_NAME')`.
* **Fuzzy Search:** Google Places Text Search API (`https://maps.googleapis.com/maps/api/place/textsearch/json?query={input}&key={KEY}`).
* **Traffic-Aware Optimization:** Mapbox Optimization API (`https://api.mapbox.com/optimized-trips/v1/mapbox/driving-traffic/{coordinates}`).

> ⚠️ **CRITICAL COORDINATE FORMATTING RULE:** Mapbox strictly requires a coordinate sequence format of **`longitude,latitude`** separated by semicolons. Google strictly uses **`latitude,longitude`**. You must explicitly flip the vector order when transiting data to Mapbox.

---

## ==========================================
## PART 2: IMPLEMENTATION BACKLOG (What to Accomplish)
## ==========================================

### Milestone 1: Project Setup & Bootstrapping
- [ ] Initialize a fresh Flutter Web compatible project configuration.
- [ ] Update `pubspec.yaml` to include exactly: `http`, `uuid`, `url_launcher`, and `provider`.
- [ ] Create an immutable `AppConfig` class to capture incoming runtime arguments for `Maps_API_KEY` and `MAPBOX_ACCESS_TOKEN`. Throw an explicit initialization error if keys evaluate to empty strings.

### Milestone 2: Infrastructure & Service Layer
- [ ] **Build `SearchService`:** Write an asynchronous network call parsing up to a maximum of 5 top match payloads from the Google Places API text search route. Map incoming entries to a typed `List<RouteLocation>`.
- [ ] **Build `OptimizationService`:** Implement the Mapbox driving-traffic matrix call. Pass parameters `source=first`, `destination=any`, and `roundtrip=false`. Read the integer matrix inside `waypoints -> waypoint_index` to align and return the newly reordered `List<RouteLocation>`.
- [ ] **Build `NavigationService`:** Construct a browser-safe, cross-platform external link redirection utility using `package:url_launcher` targeting `https://maps.google.com/?q=@37.3161,-122.1836.\\n...\\nLaunching`. Dynamically append matching parameters for `origin`, `destination`, and pipe-separated (`|`) `waypoints`.

### Milestone 3: State & Core App Controller
- [ ] Implement an explicit state controller enum: `enum AppState { idle, searching, optimizing, success, error }`.
- [ ] Create a central `RouteProvider` (or basic `ChangeNotifier`) to expose state variables: `AppState currentState`, `List<RouteLocation> activeStops`, and `List<RouteLocation> searchSearchResults`.
- [ ] Enforce safety boundaries:
    - Protect index `0` as the fixed route origin point.
    - Block duplicate location item additions by evaluating matching `uuid` properties.

### Milestone 4: UI Presentation Layer (Split-Pane Dashboard)
- [ ] Build a responsive split-pane UI (Left: 1/3 control workspace, Right: 2/3 itinerary outputs).
- [ ] **Left Panel Components:**
    - [ ] A search input tracking text changes with an internal 500ms debouncer loop to safely manage API hits.
    - [ ] A contextual overlay dropdown displaying the 5 candidate lookups from the `SearchService`. Selecting an entry appends it to the active path list and dismisses the view.
    - [ ] A clean vertical list view showing active waypoints with numerical sequence badges and trailing delete actions.
- [ ] **Right Panel Components:**
    - [ ] High-visibility action button: "Optimize Path" (disabled if `activeStops.length < 2`, exhibits loading state if `optimizing`).
    - [ ] High-visibility accent button: "Launch Google Maps Navigation" (appears or unlocks *only* under `AppState.success`). Tapping invokes the `NavigationService` to redirect the browser to the calculated route path.