import 'dart:convert';
import 'package:http/http.dart' as http;
import 'location_service_stub.dart'
    if (dart.library.html) 'location_service_web.dart' as loc_impl;

class LocationResult {
  final double latitude;
  final double longitude;
  final String cityName;
  final bool isRealGps;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.isRealGps,
  });
}

class LocationService {
  void openWebDemo() {
    loc_impl.openWebDemo();
  }

  Future<LocationResult?> requestLiveGpsLocation() async {
    try {
      final coords = await loc_impl.getBrowserGpsCoordinates();
      if (coords != null && coords['lat'] != null && coords['lon'] != null) {
        final lat = coords['lat']!;
        final lon = coords['lon']!;
        final cityName = await reverseGeocode(lat, lon);
        return LocationResult(
          latitude: lat,
          longitude: lon,
          cityName: cityName,
          isRealGps: true,
        );
      }
    } catch (_) {}

    try {
      final url = Uri.parse('https://ipapi.co/json/');
      final resp = await http.get(url).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final lat = (data['latitude'] as num?)?.toDouble();
        final lon = (data['longitude'] as num?)?.toDouble();
        final city = data['city'] ?? data['region'];
        final region = data['region'] ?? data['country_name'];

        if (lat != null && lon != null) {
          final locName = city != null ? '$city, $region' : 'Detected IP Location';
          return LocationResult(
            latitude: lat,
            longitude: lon,
            cityName: locName,
            isRealGps: false,
          );
        }
      }
    } catch (_) {}

    return null;
  }

  Future<LocationResult?> searchAndValidateLocation(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;

    final locLower = trimmed.toLowerCase();
    final quickCoords = <String, Map<String, dynamic>>{
      'coimbatore': {'lat': 11.0168, 'lon': 76.9558, 'name': 'Coimbatore, TN'},
      'ooty': {'lat': 11.4102, 'lon': 76.6950, 'name': 'Ooty, TN'},
      'udagamandalam': {'lat': 11.4102, 'lon': 76.6950, 'name': 'Ooty, TN'},
      'chennai': {'lat': 13.0827, 'lon': 80.2707, 'name': 'Chennai, TN'},
      'bengaluru': {'lat': 12.9716, 'lon': 77.5946, 'name': 'Bengaluru, KA'},
      'bangalore': {'lat': 12.9716, 'lon': 77.5946, 'name': 'Bengaluru, KA'},
      'madurai': {'lat': 9.9252, 'lon': 78.1198, 'name': 'Madurai, TN'},
      'mumbai': {'lat': 19.0760, 'lon': 72.8777, 'name': 'Mumbai, MH'},
      'delhi': {'lat': 28.6139, 'lon': 77.2090, 'name': 'Delhi, DL'},
      'new delhi': {'lat': 28.6139, 'lon': 77.2090, 'name': 'New Delhi, DL'},
      'kochi': {'lat': 9.9312, 'lon': 76.2673, 'name': 'Kochi, KL'},
      'hyderabad': {'lat': 17.3850, 'lon': 78.4867, 'name': 'Hyderabad, TS'},
      'kolkata': {'lat': 22.5726, 'lon': 88.3639, 'name': 'Kolkata, WB'},
      'chamarajanagar': {'lat': 11.9261, 'lon': 76.9437, 'name': 'Chamarajanagar, KA'},
    };

    for (final key in quickCoords.keys) {
      if (locLower == key || locLower.contains(key)) {
        final info = quickCoords[key]!;
        return LocationResult(
          latitude: info['lat'] as double,
          longitude: info['lon'] as double,
          cityName: info['name'] as String,
          isRealGps: false,
        );
      }
    }

    try {
      final enc = Uri.encodeComponent(trimmed);
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$enc&format=json&limit=1');
      final resp = await http.get(url, headers: {'User-Agent': 'MausamApp/1.0'}).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List<dynamic>;
        if (list.isNotEmpty) {
          final first = list.first as Map<String, dynamic>;
          final lat = double.tryParse(first['lat']?.toString() ?? '');
          final lon = double.tryParse(first['lon']?.toString() ?? '');
          final name = first['display_name']?.toString() ?? trimmed;
          if (lat != null && lon != null) {
            final parts = name.split(',');
            final simpleName = parts.length >= 2 ? '${parts[0].trim()}, ${parts[1].trim()}' : parts[0].trim();
            return LocationResult(
              latitude: lat,
              longitude: lon,
              cityName: simpleName,
              isRealGps: false,
            );
          }
        }
      }
    } catch (_) {}

    return null;
  }

  Future<String> reverseGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10');
      final resp = await http.get(url, headers: {'User-Agent': 'MausamApp/1.0'}).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final city = address['city'] ?? address['town'] ?? address['village'] ?? address['suburb'] ?? address['county'] ?? address['state_district'];
          final state = address['state'];
          if (city != null && state != null) {
            return '$city, $state';
          } else if (city != null) {
            return city.toString();
          }
        }
      }
    } catch (_) {}
    return '${lat.toStringAsFixed(2)}°N, ${lon.toStringAsFixed(2)}°E';
  }
}
