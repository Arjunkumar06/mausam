class AppConstants {
  static const String appName = 'Mausam';
  static const String appTagline = 'Weather that understands you';
  static const String apiBaseUrl = 'http://127.0.0.1:4005'; // Unified single port 4005
  
  // User Types
  static const String userTypeGeneral = 'general';
  static const String userTypeFarmer = 'farmer';
  static const String userTypeTraveller = 'traveller';
  
  // Master Interest List
  static const List<String> masterInterests = [
    'Rain & Thunderstorms',
    'Temperature & Heatwave',
    'Air Quality (AQI)',
    'Severe Weather Alerts',
    'Agriculture & Soil Moisture',
    'Crop Weather Advisories',
    'Travel & Visibility',
    'Wind Speed & Gusts',
    'UV Index & Solar Radiation',
    'Humidity & Dew Point',
  ];

  // Demo Locations
  static const String defaultLocation = 'Coimbatore, Tamil Nadu';
  static const double defaultLat = 11.0168;
  static const double defaultLon = 76.9558;
}
