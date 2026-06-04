import 'package:uuid/uuid.dart';

class RouteLocation {
  const RouteLocation({
    required this.uuid,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });

  final String uuid;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;

  factory RouteLocation.fromJson(Map<String, dynamic> json) {
    return RouteLocation(
      uuid: json['uuid'] as String? ?? const Uuid().v4(),
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

  String get latLngForGoogle => '$latitude,$longitude';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteLocation &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;
}
