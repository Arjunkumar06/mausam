import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/weather_observation.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final WeatherObservation observation;
  final ValueChanged<UserProfile> onProfileUpdated;
  final VoidCallback onSignOut;
  final VoidCallback onOpenOnboarding;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.observation,
    required this.onProfileUpdated,
    required this.onSignOut,
    required this.onOpenOnboarding,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _currentProfile;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _locationController = TextEditingController(text: _currentProfile.primaryLocation);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _updateProfile(UserProfile updated) {
    setState(() {
      _currentProfile = updated;
    });
    widget.onProfileUpdated(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 16),
          _buildPersonaSection(),
          const SizedBox(height: 16),
          _buildLocationSection(),
          const SizedBox(height: 16),
          _buildPreferencesSection(),
          const SizedBox(height: 16),
          _buildPersonaSpecificSettings(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryBlue,
            child: Text(
              _currentProfile.userType[0].toUpperCase(),
              style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Profile & Preferences',
                  style: AppTypography.h3.copyWith(color: AppColors.primaryBlueDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Persona: ${_currentProfile.userType.toUpperCase()} | Location: ${_currentProfile.primaryLocation}',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  'Live Sensor: ${widget.observation.source}',
                  style: const TextStyle(fontSize: 11, color: AppColors.farmerGreen, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active Persona Mode', style: AppTypography.h3),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPersonaChip('general', 'General', Icons.person_rounded, AppColors.primaryBlue),
                const SizedBox(width: 8),
                _buildPersonaChip('farmer', 'Farmer', Icons.eco_rounded, AppColors.farmerGreen),
                const SizedBox(width: 8),
                _buildPersonaChip('traveller', 'Traveller', Icons.explore_rounded, AppColors.travellerAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaChip(String type, String label, IconData icon, Color color) {
    final isSelected = _currentProfile.userType == type;
    return Expanded(
      child: ChoiceChip(
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
        onSelected: (_) {
          final newProfile = UserProfile.defaultProfile(type).copyWith(
            primaryLocation: _currentProfile.primaryLocation,
            latitude: _currentProfile.latitude,
            longitude: _currentProfile.longitude,
          );
          _updateProfile(newProfile);
        },
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location & Geofencing', style: AppTypography.h3),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Primary Location',
                prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primaryBlue),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check_circle_rounded, color: AppColors.farmerGreen),
                  onPressed: () {
                    final updated = _currentProfile.copyWith(primaryLocation: _locationController.text.trim());
                    _updateProfile(updated);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Updated primary location to ${_locationController.text}'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coordinates: ${_currentProfile.latitude.toStringAsFixed(4)}°N, ${_currentProfile.longitude.toStringAsFixed(4)}°E',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Units & Preferences', style: AppTypography.h3),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Temperature Unit'),
              subtitle: Text(_currentProfile.tempUnit == 'F' ? 'Fahrenheit (°F)' : 'Celsius (°C)'),
              trailing: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'C', label: Text('°C')),
                  ButtonSegment(value: 'F', label: Text('°F')),
                ],
                selected: {_currentProfile.tempUnit},
                onSelectionChanged: (val) {
                  _updateProfile(_currentProfile.copyWith(tempUnit: val.first));
                },
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Wind Speed Unit'),
              subtitle: Text(_currentProfile.speedUnit),
              trailing: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'km/h', label: Text('km/h')),
                  ButtonSegment(value: 'm/s', label: Text('m/s')),
                ],
                selected: {_currentProfile.speedUnit == 'm/s' ? 'm/s' : 'km/h'},
                onSelectionChanged: (val) {
                  _updateProfile(_currentProfile.copyWith(speedUnit: val.first));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaSpecificSettings() {
    if (_currentProfile.userType == 'farmer') {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agricultural Weather Advisories', style: AppTypography.h3),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.eco_rounded, color: AppColors.farmerGreen, size: 28),
                title: const Text('Real-Time Field Advisories Active', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Monitoring soil temperature, moisture levels, and optimal spraying/harvesting windows.'),
              ),
            ],
          ),
        ),
      );
    } else if (_currentProfile.userType == 'traveller') {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saved Travel Destinations', style: AppTypography.h3),
              const SizedBox(height: 12),
              ..._currentProfile.travelDestinations.map(
                (d) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_rounded, color: AppColors.travellerAccent),
                  title: Text(d),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () {
                      final updated = List<String>.from(_currentProfile.travelDestinations)..remove(d);
                      _updateProfile(_currentProfile.copyWith(travelDestinations: updated));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Re-run Onboarding Setup'),
            onPressed: widget.onOpenOnboarding,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: widget.onSignOut,
          ),
        ),
      ],
    );
  }
}
