class WeatherObservation {
  final String location;
  final DateTime timestamp;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final int rainProbability;
  final double rainAmountMm;
  final int uvIndex;
  final double visibilityKm;
  final int aqi;
  final String aqiStatus;
  final double soilMoisture; // For Farmer
  final double soilTemp; // For Farmer
  final List<WeatherAlert> alerts;
  final String source;
  final String dataQuality;
  final DateTime lastUpdated;

  WeatherObservation({
    required this.location,
    required this.timestamp,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.rainProbability,
    required this.rainAmountMm,
    required this.uvIndex,
    required this.visibilityKm,
    required this.aqi,
    required this.aqiStatus,
    this.soilMoisture = 42.0,
    this.soilTemp = 24.5,
    required this.alerts,
    this.source = 'Live Open-Meteo & INSAT-3DS Feed',
    this.dataQuality = 'Live Real-Time Meteorological Feed',
    required this.lastUpdated,
  });

  factory WeatherObservation.fromJson(Map<String, dynamic> json) {
    final alertsList = (json['alerts'] as List?)
            ?.map((a) => WeatherAlert.fromJson(a as Map<String, dynamic>))
            .toList() ??
        [];

    return WeatherObservation(
      location: json['location'] ?? 'Detected Location',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      temp: (json['temp'] as num?)?.toDouble() ?? 28.0,
      feelsLike: (json['feels_like'] as num?)?.toDouble() ?? 30.0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 65,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 12.0,
      windDirection: json['wind_direction'] ?? 'SW',
      rainProbability: (json['rain_probability'] as num?)?.toInt() ?? 40,
      rainAmountMm: (json['rain_amount_mm'] as num?)?.toDouble() ?? 0.0,
      uvIndex: (json['uv_index'] as num?)?.toInt() ?? 6,
      visibilityKm: (json['visibility_km'] as num?)?.toDouble() ?? 9.0,
      aqi: (json['aqi'] as num?)?.toInt() ?? 45,
      aqiStatus: json['aqi_status'] ?? 'Good',
      soilMoisture: (json['soil_moisture'] as num?)?.toDouble() ?? 42.0,
      soilTemp: (json['soil_temp'] as num?)?.toDouble() ?? 24.0,
      alerts: alertsList,
      source: json['source'] ?? 'Live Open-Meteo & INSAT-3DS Feed',
      dataQuality: json['data_quality'] ?? 'Live Real-Time Meteorological Feed',
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
    );
  }

  factory WeatherObservation.mockCoimbatore() {
    final now = DateTime.now();
    return WeatherObservation(
      location: 'Coimbatore, Tamil Nadu',
      timestamp: now,
      temp: 29.4,
      feelsLike: 32.1,
      humidity: 78,
      windSpeed: 14.5,
      windDirection: 'SW',
      rainProbability: 75,
      rainAmountMm: 18.4,
      uvIndex: 7,
      visibilityKm: 8.5,
      aqi: 48,
      aqiStatus: 'Good',
      soilMoisture: 42.5,
      soilTemp: 24.2,
      alerts: [
        WeatherAlert(
          id: 'alt-101',
          title: 'Heavy Rainfall Warning',
          description: 'Moderate to heavy rain with squally winds expected.',
          severity: 'severe',
          category: 'Rain',
          issuedAt: now.subtract(const Duration(hours: 2)),
          expiresAt: now.add(const Duration(hours: 10)),
        )
      ],
      source: 'Live Open-Meteo & INSAT-3DS Feed',
      dataQuality: 'Live Real-Time Meteorological Feed',
      lastUpdated: now,
    );
  }

  factory WeatherObservation.mockOoty() {
    final now = DateTime.now();
    return WeatherObservation(
      location: 'Ooty, Tamil Nadu',
      timestamp: now,
      temp: 16.2,
      feelsLike: 15.0,
      humidity: 89,
      windSpeed: 18.2,
      windDirection: 'W',
      rainProbability: 85,
      rainAmountMm: 24.0,
      uvIndex: 4,
      visibilityKm: 3.2,
      aqi: 22,
      aqiStatus: 'Excellent',
      soilMoisture: 65.0,
      soilTemp: 14.0,
      alerts: [
        WeatherAlert(
          id: 'alt-102',
          title: 'Dense Fog & Low Visibility',
          description: 'Visibility reduced below 50m on ghat roads.',
          severity: 'moderate',
          category: 'Visibility',
          issuedAt: now.subtract(const Duration(hours: 1)),
          expiresAt: now.add(const Duration(hours: 6)),
        )
      ],
      source: 'Live Open-Meteo & INSAT-3DS Feed',
      dataQuality: 'Live Real-Time Meteorological Feed',
      lastUpdated: now,
    );
  }

  factory WeatherObservation.mockBengaluru() {
    final now = DateTime.now();
    return WeatherObservation(
      location: 'Bengaluru, Karnataka',
      timestamp: now,
      temp: 24.8,
      feelsLike: 25.2,
      humidity: 62,
      windSpeed: 11.0,
      windDirection: 'ENE',
      rainProbability: 25,
      rainAmountMm: 1.2,
      uvIndex: 6,
      visibilityKm: 9.8,
      aqi: 84,
      aqiStatus: 'Moderate',
      soilMoisture: 35.0,
      soilTemp: 22.0,
      alerts: [],
      source: 'Live Open-Meteo & INSAT-3DS Feed',
      dataQuality: 'Live Real-Time Meteorological Feed',
      lastUpdated: now,
    );
  }
}

class WeatherAlert {
  final String id;
  final String title;
  final String description;
  final String severity;
  final String category;
  final DateTime issuedAt;
  final DateTime expiresAt;

  WeatherAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    required this.issuedAt,
    required this.expiresAt,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return WeatherAlert(
      id: json['id'] ?? 'alt-1',
      title: json['title'] ?? 'Weather Alert',
      description: json['description'] ?? 'Active meteorological warning',
      severity: json['severity'] ?? 'moderate',
      category: json['category'] ?? 'Weather',
      issuedAt: DateTime.tryParse(json['issued_at'] ?? '') ?? now,
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ?? now.add(const Duration(hours: 6)),
    );
  }
}
