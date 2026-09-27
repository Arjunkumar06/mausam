class UserProfile {
  final String id;
  final String name;
  final String email;
  final String userType; // 'general', 'farmer', 'traveller'
  final List<String> interests;
  final String primaryLocation;
  final double latitude;
  final double longitude;
  final String tempUnit; // 'C', 'F'
  final String speedUnit; // 'km/h', 'm/s', 'mph'
  final String selectedCrop; // For Farmer persona
  final List<String> travelDestinations; // For Traveller persona
  final bool isAuthenticated;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.interests,
    required this.primaryLocation,
    required this.latitude,
    required this.longitude,
    this.tempUnit = 'C',
    this.speedUnit = 'km/h',
    this.selectedCrop = '',
    this.travelDestinations = const ['Ooty', 'Bengaluru', 'Chennai'],
    this.isAuthenticated = false,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? userType,
    List<String>? interests,
    String? primaryLocation,
    double? latitude,
    double? longitude,
    String? tempUnit,
    String? speedUnit,
    String? selectedCrop,
    List<String>? travelDestinations,
    bool? isAuthenticated,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      interests: interests ?? this.interests,
      primaryLocation: primaryLocation ?? this.primaryLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tempUnit: tempUnit ?? this.tempUnit,
      speedUnit: speedUnit ?? this.speedUnit,
      selectedCrop: selectedCrop ?? this.selectedCrop,
      travelDestinations: travelDestinations ?? this.travelDestinations,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'userType': userType,
    'interests': interests,
    'primaryLocation': primaryLocation,
    'latitude': latitude,
    'longitude': longitude,
    'tempUnit': tempUnit,
    'speedUnit': speedUnit,
    'selectedCrop': selectedCrop,
    'travelDestinations': travelDestinations,
    'isAuthenticated': isAuthenticated,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] ?? '',
    name: json['name'] ?? 'Guest User',
    email: json['email'] ?? '',
    userType: json['userType'] ?? 'general',
    interests: List<String>.from(json['interests'] ?? ['Rain & Thunderstorms', 'Air Quality (AQI)']),
    primaryLocation: json['primaryLocation'] ?? 'Coimbatore, Tamil Nadu',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 11.0168,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 76.9558,
    tempUnit: json['tempUnit'] ?? 'C',
    speedUnit: json['speedUnit'] ?? 'km/h',
    selectedCrop: json['selectedCrop'] ?? '',
    travelDestinations: List<String>.from(json['travelDestinations'] ?? ['Ooty', 'Bengaluru', 'Chennai']),
    isAuthenticated: json['isAuthenticated'] ?? false,
  );

  static UserProfile defaultProfile(String type) {
    if (type == 'farmer') {
      return UserProfile(
        id: 'demo-farmer-1',
        name: 'Ramu (Farmer)',
        email: 'ramu.farmer@example.com',
        userType: 'farmer',
        interests: ['Agriculture & Soil Moisture', 'Crop Weather Advisories', 'Rain & Thunderstorms', 'Wind Speed & Gusts'],
        primaryLocation: 'Coimbatore Agri Belt, TN',
        latitude: 11.0168,
        longitude: 76.9558,
        selectedCrop: '',
        isAuthenticated: true,
      );
    } else if (type == 'traveller') {
      return UserProfile(
        id: 'demo-traveller-1',
        name: 'Priya (Traveller)',
        email: 'priya.travels@example.com',
        userType: 'traveller',
        interests: ['Travel & Visibility', 'Severe Weather Alerts', 'Rain & Thunderstorms', 'Temperature & Heatwave'],
        primaryLocation: 'Coimbatore Hub, TN',
        latitude: 11.0168,
        longitude: 76.9558,
        travelDestinations: ['Ooty, TN', 'Bengaluru, KA', 'Chennai, TN'],
        isAuthenticated: true,
      );
    } else {
      return UserProfile(
        id: 'demo-general-1',
        name: 'Arjun (General)',
        email: 'arjun.general@example.com',
        userType: 'general',
        interests: ['Rain & Thunderstorms', 'Temperature & Heatwave', 'Air Quality (AQI)', 'Severe Weather Alerts'],
        primaryLocation: 'Coimbatore City, TN',
        latitude: 11.0168,
        longitude: 76.9558,
        isAuthenticated: true,
      );
    }
  }
}
