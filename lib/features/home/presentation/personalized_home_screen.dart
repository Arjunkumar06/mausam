import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/network/weather_api_service.dart';
import '../../../core/services/location_service.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/weather_observation.dart';
import '../../../shared/models/personalized_card.dart';
import '../../personalization/domain/personalization_engine.dart';
import '../../weather/presentation/forecast_screen.dart';
import '../../alerts/presentation/alerts_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'widgets/hero_weather_card.dart';
import 'widgets/alert_banner_card.dart';
import 'widgets/farmer_advisory_card.dart';
import 'widgets/traveller_destination_card.dart';
import 'widgets/environmental_stats_grid.dart';

class PersonalizedHomeScreen extends StatefulWidget {
  final UserProfile initialProfile;
  final VoidCallback onOpenOnboarding;
  final VoidCallback onSignOut;

  const PersonalizedHomeScreen({
    super.key,
    required this.initialProfile,
    required this.onOpenOnboarding,
    required this.onSignOut,
  });

  @override
  State<PersonalizedHomeScreen> createState() => _PersonalizedHomeScreenState();
}

class _PersonalizedHomeScreenState extends State<PersonalizedHomeScreen> {
  late UserProfile _currentProfile;
  late WeatherObservation _observation;
  late PersonalizationEngine _engine;
  final WeatherApiService _weatherApiService = WeatherApiService();
  final LocationService _locationService = LocationService();
  bool _isLoadingWeather = true;
  bool _isDetectingGps = false;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.initialProfile;
    _observation = WeatherObservation.mockCoimbatore();
    _engine = RuleBasedPersonalizationEngine();
    _loadLiveWeatherData();
    _autoDetectLiveGpsLocation();
  }

  Future<void> _loadLiveWeatherData() async {
    setState(() => _isLoadingWeather = true);
    try {
      final liveObs = await _weatherApiService.fetchLiveWeather(
        locationName: _currentProfile.primaryLocation,
        lat: _currentProfile.latitude,
        lon: _currentProfile.longitude,
      );
      if (mounted) {
        setState(() {
          _observation = liveObs;
          _isLoadingWeather = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingWeather = false);
      }
    }
  }

  Future<void> _autoDetectLiveGpsLocation() async {
    setState(() => _isDetectingGps = true);
    final result = await _locationService.requestLiveGpsLocation();
    if (mounted) {
      setState(() => _isDetectingGps = false);
      if (result != null) {
        setState(() {
          _currentProfile = _currentProfile.copyWith(
            primaryLocation: result.cityName,
            latitude: result.latitude,
            longitude: result.longitude,
          );
        });
        await _loadLiveWeatherData();
        if (mounted) {
          _showToastNotification(
            'Live Location detected: ${result.cityName} (${result.latitude.toStringAsFixed(2)}°, ${result.longitude.toStringAsFixed(2)}°)',
            backgroundColor: AppColors.farmerGreen,
          );
        }
      }
    }
  }

  void _showToastNotification(String message, {Color? backgroundColor, String? actionLabel, VoidCallback? onAction}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final snackBar = SnackBar(
      content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      backgroundColor: backgroundColor ?? AppColors.primaryBlueDark,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.amberAccent,
              onPressed: () {
                messenger.hideCurrentSnackBar();
                onAction();
              },
            )
          : null,
    );

    messenger.showSnackBar(snackBar);

    // Explicit 3-second timer fallback to guarantee pop up never gets stuck
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        messenger.hideCurrentSnackBar();
      }
    });
  }

  void _switchPersona(String type) {
    if (_currentProfile.userType == type) return;
    setState(() {
      _currentProfile = _currentProfile.copyWith(userType: type);
    });
  }

  void _showLocationSearchDialog() {
    final searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Text('Search Any Location'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Enter city (e.g. Coimbatore, Ooty, Bengaluru)',
                  prefixIcon: Icon(Icons.location_city_rounded),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    Navigator.pop(context);
                    _onSelectLocation(val.trim());
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Quick Select Popular Cities:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: ['Coimbatore', 'Ooty', 'Chennai', 'Bengaluru', 'Madurai', 'Mumbai', 'Delhi', 'Kochi']
                    .map((city) => ActionChip(
                          label: Text(city, style: const TextStyle(fontSize: 12)),
                          onPressed: () {
                            Navigator.pop(context);
                            _onSelectLocation(city);
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (searchController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  _onSelectLocation(searchController.text.trim());
                }
              },
              child: const Text('Search & Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onSelectLocation(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _showToastNotification('Validating location "$trimmed"...');

    final validated = await _locationService.searchAndValidateLocation(trimmed);

    if (!mounted) return;

    if (validated == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.alertSevere),
              SizedBox(width: 8),
              Text("Can't Fetch Location"),
            ],
          ),
          content: Text(
            "Could not fetch weather data for '$trimmed'.\n\nPlease check the spelling or try searching for a valid city name (e.g. Coimbatore, Ooty, Bengaluru, Chennai).",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _currentProfile = _currentProfile.copyWith(
        primaryLocation: validated.cityName,
        latitude: validated.latitude,
        longitude: validated.longitude,
      );
    });

    final liveObs = await _weatherApiService.fetchLiveWeather(
      locationName: validated.cityName,
      lat: validated.latitude,
      lon: validated.longitude,
    );

    if (mounted) {
      setState(() {
        _observation = liveObs;
      });
      _showToastNotification('Updated live location to ${validated.cityName}', backgroundColor: AppColors.farmerGreen);
    }
  }

  void _showAddCustomDestinationDialog() {
    final destController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_location_alt_rounded, color: AppColors.travellerAccent),
            SizedBox(width: 8),
            Text('Add Travel Destination'),
          ],
        ),
        content: TextField(
          controller: destController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'City Name of Your Choice',
            hintText: 'e.g. Kodaikanal, Munnar, Mysuru, Goa, Chennai',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (val) {
            Navigator.pop(context);
            _addTravelDestination(val);
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addTravelDestination(destController.text);
            },
            child: const Text('Add Destination'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTravelDestination(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return;

    _showToastNotification('Validating city "$trimmed"...');

    final validated = await _locationService.searchAndValidateLocation(trimmed);
    if (!mounted) return;

    if (validated == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.alertSevere),
              SizedBox(width: 8),
              Text("Can't Fetch City"),
            ],
          ),
          content: Text(
            "Could not fetch destination for '$trimmed'.\n\nPlease check spelling or enter a valid city name.",
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    if (!_currentProfile.travelDestinations.contains(validated.cityName)) {
      final updatedList = List<String>.from(_currentProfile.travelDestinations)..add(validated.cityName);
      setState(() {
        _currentProfile = _currentProfile.copyWith(travelDestinations: updatedList);
      });
      _showToastNotification('Added "${validated.cityName}" to travel routes!', backgroundColor: AppColors.farmerGreen);
    }
  }

  void _removeTravelDestination(String destination) {
    if (_currentProfile.travelDestinations.contains(destination)) {
      final updatedList = List<String>.from(_currentProfile.travelDestinations)..remove(destination);
      setState(() {
        _currentProfile = _currentProfile.copyWith(travelDestinations: updatedList);
      });
      _showToastNotification(
        'Removed "$destination" from saved travel routes.',
        actionLabel: 'Undo',
        onAction: () {
          if (!mounted) return;
          setState(() {
            _currentProfile = _currentProfile.copyWith(
              travelDestinations: [..._currentProfile.travelDestinations, destination],
            );
          });
        },
      );
    }
  }

  void _showDestinationDetailsModal(String destination) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final screenWidth = MediaQuery.of(dialogContext).size.width;
        final isMobileModal = screenWidth < 500;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: EdgeInsets.all(isMobileModal ? 16 : 24),
            child: FutureBuilder<WeatherObservation>(
              future: _weatherApiService.fetchLiveWeather(locationName: destination),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(color: AppColors.travellerAccent),
                      const SizedBox(height: 20),
                      Text('Fetching live meteorological data for $destination...', style: AppTypography.bodyMedium),
                      const SizedBox(height: 20),
                    ],
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.alertSevere, size: 48),
                      const SizedBox(height: 12),
                      Text('Could not load details for $destination', style: AppTypography.h3),
                      const SizedBox(height: 8),
                      Text('Please check spelling or network connection.', style: AppTypography.caption),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext, rootNavigator: true).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                }

                final obs = snapshot.data!;
                final visKm = obs.visibilityKm;
                final isGhatFog = visKm < 5.0;
                final visColor = isGhatFog ? AppColors.alertSevere : (visKm < 8.0 ? Colors.orange : AppColors.farmerGreen);
                final visStatusText = isGhatFog
                    ? '⚠️ Ghat Road / Hill Fog Alert: Low Visibility ($visKm km). Drive with fog lights!'
                    : (visKm < 8.0 ? '⚡ Moderate Visibility ($visKm km). Drive carefully.' : '✅ Clear Road Visibility ($visKm km). Ideal for Highway Travel');

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Modal Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.travellerAccentLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.flight_takeoff_rounded, color: AppColors.travellerAccent, size: 24),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(obs.location, style: AppTypography.h3, overflow: TextOverflow.ellipsis),
                                      Text(
                                        'Live Destination Weather & Route Info',
                                        style: AppTypography.caption.copyWith(color: AppColors.travellerAccent, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.of(dialogContext, rootNavigator: true).pop(),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      // Main Temp & Travel Driving Conditions Box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.travellerAccentLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.travellerAccent.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${obs.temp.toStringAsFixed(1)}°C',
                                          style: AppTypography.h1.copyWith(color: AppColors.travellerAccent),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Feels like ${obs.feelsLike.toStringAsFixed(1)}°C',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Rain Chance: ${obs.rainProbability}%',
                                              style: AppTypography.caption,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isGhatFog ? Icons.foggy : (obs.rainProbability > 50 ? Icons.umbrella_rounded : Icons.wb_sunny_rounded),
                                  color: isGhatFog ? AppColors.alertSevere : (obs.rainProbability > 50 ? AppColors.primaryBlue : Colors.orange),
                                  size: 34,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: visColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: visColor),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.alt_route_rounded, color: visColor, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      visStatusText,
                                      style: TextStyle(color: visColor, fontSize: 11, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Detailed Grid
                      Text('Destination Route & Weather Metrics:', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: isMobileModal ? 2 : 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: isMobileModal ? 1.75 : 1.6,
                        children: [
                          _buildMetricTile('Visibility', '${obs.visibilityKm} km', Icons.remove_red_eye_rounded, AppColors.primaryBlue),
                          _buildMetricTile('Wind Speed', '${obs.windSpeed} km/h', Icons.air_rounded, Colors.teal),
                          _buildMetricTile('Wind Dir', obs.windDirection, Icons.explore_rounded, Colors.indigo),
                          _buildMetricTile('Humidity', '${obs.humidity}%', Icons.water_drop_rounded, AppColors.primaryBlue),
                          _buildMetricTile('AQI Index', '${obs.aqi} (${obs.aqiStatus})', Icons.cloud_rounded, Colors.purple),
                          _buildMetricTile('UV Index', '${obs.uvIndex}', Icons.wb_sunny_rounded, Colors.orange),
                        ],
                      ),
                      if (obs.alerts.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.alertSevere.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.alertSevere),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_rounded, color: AppColors.alertSevere, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${obs.alerts.first.title}: ${obs.alerts.first.description}',
                                  style: const TextStyle(color: AppColors.alertSevere, fontSize: 11, fontWeight: FontWeight.bold, height: 1.3),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Responsive Modal Actions
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 420) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(dialogContext, rootNavigator: true).pop();
                                    _onSelectLocation(destination);
                                  },
                                  icon: const Icon(Icons.my_location_rounded, size: 18),
                                  label: const Text('Set as Primary Location'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.travellerAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(dialogContext, rootNavigator: true).pop();
                                    _removeTravelDestination(destination);
                                  },
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                                  label: const Text('Remove Destination', style: TextStyle(color: Colors.red)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ],
                            );
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(dialogContext, rootNavigator: true).pop();
                                  _removeTravelDestination(destination);
                                },
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                                label: const Text('Remove', style: TextStyle(color: Colors.red)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(dialogContext, rootNavigator: true).pop();
                                  _onSelectLocation(destination);
                                },
                                icon: const Icon(Icons.my_location_rounded, size: 18),
                                label: const Text('Set as Primary Location'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.travellerAccent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rankedCards = _engine.rankCards(
      profile: _currentProfile,
      observation: _observation,
    );

    return PopScope(
      canPop: _currentNavIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentNavIndex != 0) {
          setState(() => _currentNavIndex = 0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: _currentNavIndex != 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Back to Home',
                  onPressed: () => setState(() => _currentNavIndex = 0),
                )
              : null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getAppBarTitle(),
                style: AppTypography.h2.copyWith(color: AppColors.primaryBlue),
              ),
              Text(
                'Live Location: ${_observation.location} (${_currentProfile.userType.toUpperCase()})',
                style: AppTypography.caption,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: _showLocationSearchDialog,
              tooltip: 'Search City / Location (Extra)',
            ),
            IconButton(
              icon: _isDetectingGps
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.farmerGreen),
                    )
                  : const Icon(Icons.my_location_rounded, color: AppColors.farmerGreen),
              onPressed: _autoDetectLiveGpsLocation,
              tooltip: 'Detect Live Location',
            ),
            IconButton(
              icon: const Icon(Icons.code_rounded),
              onPressed: () => _locationService.openWebDemo(),
              tooltip: 'Open HTML Web Demo (/demo)',
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadLiveWeatherData,
              tooltip: 'Refresh Live Weather',
            ),
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: widget.onOpenOnboarding,
              tooltip: 'Customize Preferences',
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: widget.onSignOut,
              tooltip: 'Sign Out',
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentNavIndex,
          children: [
            // Tab 0: Home
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 960),
                child: RefreshIndicator(
                  onRefresh: _loadLiveWeatherData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLiveLocationBanner(),
                        const SizedBox(height: 12),
                        _buildPersonaSwitcherBar(),
                        const SizedBox(height: 16),
                        if (_isLoadingWeather)
                          const LinearProgressIndicator(color: AppColors.primaryBlue),
                        const SizedBox(height: 8),
                        ...rankedCards.map((card) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildCardContent(card),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Tab 1: Forecast
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 960),
                child: ForecastScreen(observation: _observation),
              ),
            ),
            // Tab 2: Alerts
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 960),
                child: AlertsScreen(observation: _observation),
              ),
            ),
            // Tab 3: Profile
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 960),
                child: ProfileScreen(
                  profile: _currentProfile,
                  observation: _observation,
                  onProfileUpdated: (updatedProfile) {
                    setState(() => _currentProfile = updatedProfile);
                    _loadLiveWeatherData();
                  },
                  onSignOut: widget.onSignOut,
                  onOpenOnboarding: widget.onOpenOnboarding,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textMuted,
          onTap: (index) => setState(() => _currentNavIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Forecast'),
            BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentNavIndex) {
      case 1:
        return 'Mausam - Forecast';
      case 2:
        return 'Mausam - Severe Alerts';
      case 3:
        return 'Mausam - Profile & Setup';
      case 0:
      default:
        return 'Mausam';
    }
  }

  Widget _buildLiveLocationBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.farmerGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.farmerGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.sensors_rounded, color: AppColors.farmerGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Live Location: ${_observation.location} (${_observation.temp}°C, Humidity ${_observation.humidity}%, Rain ${_observation.rainProbability}%)',
                    style: const TextStyle(color: AppColors.farmerGreen, fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _autoDetectLiveGpsLocation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.farmerGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Detect Location', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaSwitcherBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Live Personalization Engine Controls',
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlueDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _personaChoiceChip('general', 'General', Icons.person_rounded, AppColors.primaryBlue),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _personaChoiceChip('farmer', 'Farmer', Icons.eco_rounded, AppColors.farmerGreen),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _personaChoiceChip('traveller', 'Traveller', Icons.explore_rounded, AppColors.travellerAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _personaChoiceChip(String type, String label, IconData icon, Color color) {
    final isSelected = _currentProfile.userType == type;
    return ChoiceChip(
      avatar: Icon(icon, color: isSelected ? Colors.white : color, size: 18),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: color.withValues(alpha: 0.1),
      onSelected: (_) => _switchPersona(type),
    );
  }

  Widget _buildCardContent(PersonalizedCard card) {
    switch (card.type) {
      case CardType.heroCurrentWeather:
        return HeroWeatherCard(observation: _observation, userType: _currentProfile.userType);
      case CardType.alertBanner:
        return AlertBannerCard(
          alert: _observation.alerts.isNotEmpty
              ? _observation.alerts.first
              : WeatherAlert(
                  id: 'alt-default',
                  title: 'Live Weather Monitoring Active',
                  description: 'No active severe weather warnings for ${_observation.location}.',
                  severity: 'minor',
                  category: 'General',
                  issuedAt: DateTime.now(),
                  expiresAt: DateTime.now().add(const Duration(hours: 6)),
                ),
        );
      case CardType.cropAdvisory:
        return FarmerAdvisoryCard(
          observation: _observation,
          selectedCrop: _currentProfile.selectedCrop,
          onCropChanged: (newCrop) {
            setState(() {
              _currentProfile = _currentProfile.copyWith(selectedCrop: newCrop);
            });
          },
        );
      case CardType.travelDestinationSummary:
        return TravellerDestinationCard(
          savedDestinations: _currentProfile.travelDestinations,
          onSelectDestination: (dest) {
            _showDestinationDetailsModal(dest);
          },
          onAddDestination: () {
            _showAddCustomDestinationDialog();
          },
          onRemoveDestination: (dest) {
            _removeTravelDestination(dest);
          },
        );
      case CardType.generalStatsGrid:
      case CardType.farmerMetricsGrid:
        return EnvironmentalStatsGrid(observation: _observation);
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.title, style: AppTypography.h3),
              Text(card.subtitle, style: AppTypography.bodyMedium),
            ],
          ),
        );
    }
  }
}
