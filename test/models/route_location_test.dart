import 'package:route_optimization/models/route_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson maps place fields and preserves uuid', () {
    final location = RouteLocation.fromJson({
      'uuid': 'place-1',
      'name': 'McDonald\'s',
      'address': '123 Main St',
      'lat': 37.4,
      'lng': -122.1,
    });

    expect(location.uuid, 'place-1');
    expect(location.name, 'McDonald\'s');
    expect(location.formattedAddress, '123 Main St');
    expect(location.latitude, 37.4);
    expect(location.longitude, -122.1);
  });

  test('toJson round-trips address key as address', () {
    const location = RouteLocation(
      uuid: 'id-1',
      name: 'Stop',
      formattedAddress: '1 Road',
      latitude: 1,
      longitude: 2,
    );

    final json = location.toJson();
    expect(json['address'], '1 Road');
    expect(RouteLocation.fromJson(json).uuid, 'id-1');
  });

  test('equality is by uuid only', () {
    const a = RouteLocation(
      uuid: 'same',
      name: 'A',
      formattedAddress: 'x',
      latitude: 0,
      longitude: 0,
    );
    const b = RouteLocation(
      uuid: 'same',
      name: 'B',
      formattedAddress: 'y',
      latitude: 9,
      longitude: 9,
    );

    expect(a, equals(b));
  });
}
