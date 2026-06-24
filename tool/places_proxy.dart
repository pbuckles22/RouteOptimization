// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// Local CORS proxy for Google Places Autocomplete + Details.
/// **Dev-only:** Flutter Web testing (browser CORS). Not used on iOS.
/// Usage: dart run tool/places_proxy.dart
Future<void> main() async {
  final apiKey = _resolveMapsApiKey();
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln('Set MAPS_API_KEY in .env or environment.');
    exit(1);
  }

  final port = int.tryParse(
        Platform.environment['PLACES_PROXY_PORT'] ?? '8765',
      ) ??
      8765;

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print('Places proxy on http://127.0.0.1:$port');
  print('  GET /search?q=2314&lat=37.4&lng=-122.1');
  print('  GET /details?place_id=ChIJ...');

  await for (final request in server) {
    await _handle(request, apiKey);
  }
}

Future<void> _handle(HttpRequest request, String apiKey) async {
  _cors(request);

  if (request.method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  try {
    switch (request.uri.path) {
      case '/search':
        await _handleSearch(request, apiKey);
      case '/details':
        await _handleDetails(request, apiKey);
      default:
        request.response.statusCode = HttpStatus.notFound;
        request.response.write(
          'Use /search?q=... or /details?place_id=...',
        );
        await request.response.close();
    }
  } catch (e) {
    request.response.statusCode = HttpStatus.internalServerError;
    request.response.write(jsonEncode({'error': e.toString()}));
    await request.response.close();
  }
}

Future<void> _handleSearch(HttpRequest request, String apiKey) async {
  final input = request.uri.queryParameters['q']?.trim() ?? '';
  if (input.isEmpty) {
    request.response.statusCode = HttpStatus.badRequest;
    request.response.write(jsonEncode({'error': 'Missing q parameter'}));
    await request.response.close();
    return;
  }

  final lat = request.uri.queryParameters['lat'];
  final lng = request.uri.queryParameters['lng'];
  final country = request.uri.queryParameters['country'] ?? 'us';

  final merged = <String, Map<String, dynamic>>{};
  final addressLike = RegExp(r'\d').hasMatch(input);

  if (addressLike) {
    for (final prediction in await _autocomplete(
      apiKey,
      input,
      types: 'address',
      lat: lat,
      lng: lng,
      country: country,
    )) {
      merged[prediction['place_id'] as String] = prediction;
    }
    for (final prediction in await _autocomplete(
      apiKey,
      input,
      types: 'geocode',
      lat: lat,
      lng: lng,
      country: country,
    )) {
      final id = prediction['place_id'] as String;
      merged.putIfAbsent(id, () => prediction);
    }
  }

  for (final prediction in await _autocomplete(
    apiKey,
    input,
    lat: lat,
    lng: lng,
    country: country,
  )) {
    final id = prediction['place_id'] as String;
    merged.putIfAbsent(id, () => prediction);
  }

  final ranked = merged.values.toList()
    ..sort((a, b) => _rankPrediction(a, input).compareTo(_rankPrediction(b, input)));

  final body = jsonEncode({
    'status': 'OK',
    'predictions': ranked.take(5).toList(),
  });

  request.response.statusCode = HttpStatus.ok;
  request.response.headers.contentType = ContentType.json;
  request.response.write(body);
  await request.response.close();
}

Future<void> _handleDetails(HttpRequest request, String apiKey) async {
  final placeId = request.uri.queryParameters['place_id']?.trim() ?? '';
  if (placeId.isEmpty) {
    request.response.statusCode = HttpStatus.badRequest;
    request.response.write(jsonEncode({'error': 'Missing place_id'}));
    await request.response.close();
    return;
  }

  final uri = Uri.https(
    'maps.googleapis.com',
    '/maps/api/place/details/json',
    {
      'place_id': placeId,
      'fields': 'place_id,name,formatted_address,geometry',
      'key': apiKey,
    },
  );

  final body = await _getJson(uri);
  request.response.statusCode = HttpStatus.ok;
  request.response.headers.contentType = ContentType.json;
  request.response.write(body);
  await request.response.close();
}

Future<List<Map<String, dynamic>>> _autocomplete(
  String apiKey,
  String input, {
  String? types,
  String? lat,
  String? lng,
  required String country,
}) async {
  final params = <String, String>{
    'input': input,
    'key': apiKey,
    'components': 'country:$country',
  };
  if (types != null) {
    params['types'] = types;
  }
  if (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty) {
    params['location'] = '$lat,$lng';
    params['radius'] = '80000';
  }

  final uri = Uri.https(
    'maps.googleapis.com',
    '/maps/api/place/autocomplete/json',
    params,
  );

  final decoded = jsonDecode(await _getJson(uri)) as Map<String, dynamic>;
  final status = decoded['status'] as String? ?? 'UNKNOWN';
  if (status != 'OK' && status != 'ZERO_RESULTS') {
    return [];
  }

  return (decoded['predictions'] as List<dynamic>? ?? [])
      .cast<Map<String, dynamic>>();
}

int _rankPrediction(Map<String, dynamic> prediction, String input) {
  final types = (prediction['types'] as List<dynamic>?)?.cast<String>() ?? [];
  final addressLike = RegExp(r'\d').hasMatch(input);

  if (addressLike) {
    if (types.contains('street_address') || types.contains('premise')) {
      return 0;
    }
    if (types.contains('subpremise') || types.contains('route')) {
      return 1;
    }
    if (types.contains('geocode')) {
      return 2;
    }
    if (types.contains('establishment')) {
      return 10;
    }
    if (types.contains('locality') || types.contains('political')) {
      return 50;
    }
  } else {
    if (types.contains('establishment')) {
      return 0;
    }
    if (types.contains('street_address') || types.contains('premise')) {
      return 2;
    }
  }
  return 25;
}

Future<String> _getJson(Uri uri) async {
  final client = HttpClient();
  final googleRequest = await client.getUrl(uri);
  final googleResponse = await googleRequest.close();
  return googleResponse.transform(utf8.decoder).join();
}

void _cors(HttpRequest request) {
  request.response.headers
    ..add('Access-Control-Allow-Origin', '*')
    ..add('Access-Control-Allow-Methods', 'GET, OPTIONS')
    ..add('Access-Control-Allow-Headers', 'Content-Type');
}

String? _resolveMapsApiKey() {
  final fromEnv = Platform.environment['MAPS_API_KEY'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return fromEnv;
  }

  final envFile = File('.env');
  if (!envFile.existsSync()) {
    return null;
  }

  for (final line in envFile.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('MAPS_API_KEY=')) {
      return trimmed.substring('MAPS_API_KEY='.length).trim();
    }
  }
  return null;
}
