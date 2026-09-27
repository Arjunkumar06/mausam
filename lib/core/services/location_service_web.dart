import 'dart:html' as html;

Future<Map<String, double>?> getBrowserGpsCoordinates() async {
  try {
    final geolocation = html.window.navigator.geolocation;
    if (geolocation == null) return null;
    final pos = await geolocation.getCurrentPosition(
      enableHighAccuracy: true,
      timeout: const Duration(seconds: 10),
    );
    final coords = pos.coords;
    if (coords != null && coords.latitude != null && coords.longitude != null) {
      return {
        'lat': coords.latitude!.toDouble(),
        'lon': coords.longitude!.toDouble(),
      };
    }
  } catch (_) {}
  return null;
}

void openWebDemo() {
  html.window.open('/demo', '_blank');
}
