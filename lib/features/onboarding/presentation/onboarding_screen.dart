import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/location_service.dart';
import '../../../shared/models/user_profile.dart';

class OnboardingScreen extends StatefulWidget {
  final Function(UserProfile profile) onOnboardingComplete;
  final VoidCallback? onCancelOnboarding;

  const OnboardingScreen({
    super.key,
    required this.onOnboardingComplete,
    this.onCancelOnboarding,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final LocationService _locationService = LocationService();
  bool _isDetectingGps = false;

  // Form State
  final _nameController = TextEditingController(text: 'New User');
  late TextEditingController _locationController;
  final _customDestinationController = TextEditingController();

  String _selectedUserType = AppConstants.userTypeGeneral;
  final Set<String> _selectedInterests = {
    'Rain & Thunderstorms',
    'Temperature & Heatwave',
    'Air Quality (AQI)'
  };
  String _location = AppConstants.defaultLocation;
  double _latitude = AppConstants.defaultLat;
  double _longitude = AppConstants.defaultLon;
  String _tempUnit = 'C';
  String _speedUnit = 'km/h';
  String _crop = '';
  final List<String> _destinations = ['Ooty, TN', 'Bengaluru, KA'];

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: _location);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _customDestinationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _finishOnboarding();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      if (widget.onCancelOnboarding != null) {
        widget.onCancelOnboarding!();
      } else if (Navigator.canPop(context)) {
        Navigator.maybePop(context);
      }
    }
  }

  Future<void> _detectLiveGpsLocation() async {
    setState(() => _isDetectingGps = true);
    final result = await _locationService.requestLiveGpsLocation();
    if (mounted) {
      setState(() => _isDetectingGps = false);
      if (result != null) {
        setState(() {
          _location = result.cityName;
          _latitude = result.latitude;
          _longitude = result.longitude;
          _locationController.text = result.cityName;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Live GPS Location detected: ${result.cityName} (${result.latitude.toStringAsFixed(2)}°, ${result.longitude.toStringAsFixed(2)}°)'),
            backgroundColor: AppColors.farmerGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not access GPS. Please check location permissions or enter city manually.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _validateAndSetLocation(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return;

    final validated = await _locationService.searchAndValidateLocation(trimmed);
    if (mounted) {
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
              "Could not fetch location for '$trimmed'.\n\nPlease check spelling or try a valid city (e.g. Coimbatore, Ooty, Bengaluru, Chennai).",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _location = validated.cityName;
          _latitude = validated.latitude;
          _longitude = validated.longitude;
          _locationController.text = validated.cityName;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location updated to ${validated.cityName}'),
            backgroundColor: AppColors.farmerGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _addCustomDestination(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Validating city "$trimmed"...'),
        duration: const Duration(seconds: 2),
      ),
    );

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
            "Could not fetch destination for '$trimmed'.\n\nPlease check spelling or enter a valid city name (e.g. Kodaikanal, Munnar, Mysuru, Goa, Chennai).",
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

    if (!_destinations.contains(validated.cityName)) {
      setState(() {
        _destinations.add(validated.cityName);
        _customDestinationController.clear();
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${validated.cityName}" to travel routes!'),
          backgroundColor: AppColors.farmerGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _finishOnboarding() {
    final profile = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim().isEmpty ? 'User' : _nameController.text.trim(),
      email: 'user@example.com',
      userType: _selectedUserType,
      interests: _selectedInterests.toList(),
      primaryLocation: _location,
      latitude: _latitude,
      longitude: _longitude,
      tempUnit: _tempUnit,
      speedUnit: _speedUnit,
      selectedCrop: _crop,
      travelDestinations: _destinations,
      isAuthenticated: true,
    );

    widget.onOnboardingComplete(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Mausam Experience'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevStep,
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              backgroundColor: AppColors.borderLight,
              color: AppColors.primaryBlue,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(),
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildNameAndRoleStep();
      case 1:
        return _buildInterestsStep();
      case 2:
        return _buildLocationStep();
      case 3:
        return _buildPersonaDetailsStep();
      case 4:
        return _buildUnitsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 0: Name & Role
  Widget _buildNameAndRoleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1 of 5: Profile & Persona', style: AppTypography.caption.copyWith(color: AppColors.primaryBlue)),
        const SizedBox(height: 8),
        Text('Who are you using Mausam for?', style: AppTypography.h2),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 24),
        Text('Select Primary Persona:', style: AppTypography.h3),
        const SizedBox(height: 12),
        _buildRoleTile('general', 'General Citizen', 'City weather, AQI, UV Index, daily forecast', Icons.person_rounded, AppColors.primaryBlue),
        _buildRoleTile('farmer', 'Farmer / Agriculture', 'Soil moisture, spray weather advisories, rainfall timing', Icons.eco_rounded, AppColors.farmerGreen),
        _buildRoleTile('traveller', 'Traveler / Driver', 'Ghat road fog, multi-destination monitoring, highway alerts', Icons.explore_rounded, AppColors.travellerAccent),
      ],
    );
  }

  Widget _buildRoleTile(String value, String title, String subtitle, IconData icon, Color color) {
    final isSelected = _selectedUserType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedUserType = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : AppColors.borderLight, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.h3),
                  Text(subtitle, style: AppTypography.bodyMedium),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, color: color),
          ],
        ),
      ),
    );
  }

  // Step 1: Interests
  Widget _buildInterestsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2 of 5: Weather Interests', style: AppTypography.caption.copyWith(color: AppColors.primaryBlue)),
        const SizedBox(height: 8),
        Text('What information matters to you most?', style: AppTypography.h2),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: AppConstants.masterInterests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              selectedColor: AppColors.primaryBlue.withOpacity(0.15),
              checkmarkColor: AppColors.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryBlueDark : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedInterests.add(interest);
                  } else {
                    _selectedInterests.remove(interest);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Step 2: Location
  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3 of 5: Location Setup', style: AppTypography.caption.copyWith(color: AppColors.primaryBlue)),
        const SizedBox(height: 8),
        Text('Detect or enter your location', style: AppTypography.h2),
        const SizedBox(height: 8),
        Text('Mausam uses your exact location to deliver localized rainfall alerts, agricultural spray advisories, and route visibility warnings.', style: AppTypography.bodyMedium),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _isDetectingGps ? null : _detectLiveGpsLocation,
          icon: _isDetectingGps
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.gps_fixed),
          label: Text(_isDetectingGps ? 'Detecting Live Location...' : 'Detect & Use My GPS Location'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('OR SEARCH MANUALLY', style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Search City / Town',
            hintText: 'e.g. Coimbatore, Ooty, Chennai, Bengaluru, Delhi',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.check_circle_rounded, color: AppColors.farmerGreen),
              onPressed: () => _validateAndSetLocation(_locationController.text),
              tooltip: 'Validate & Apply Location',
            ),
          ),
          onSubmitted: _validateAndSetLocation,
        ),
      ],
    );
  }

  // Step 3: Persona Specific Details
  Widget _buildPersonaDetailsStep() {
    if (_selectedUserType == 'farmer') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 4 of 5: Agricultural Weather Advisories', style: AppTypography.caption.copyWith(color: AppColors.farmerGreen)),
          const SizedBox(height: 8),
          Text('Agri-Weather & Soil Advisory Services:', style: AppTypography.h2),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.farmerGreenLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.farmerGreen.withOpacity(0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.eco_rounded, color: AppColors.farmerGreen, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agri Weather Intelligence Active',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.farmerGreen, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Automated soil moisture tracking, rainfall windows, and localized field alerts enabled for your location.',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_selectedUserType == 'traveller') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 4 of 5: Travel Destinations', style: AppTypography.caption.copyWith(color: AppColors.travellerAccent)),
          const SizedBox(height: 8),
          Text('Add saved travel routes & destinations:', style: AppTypography.h2),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _destinations.map((dest) => Chip(
              avatar: const Icon(Icons.place_rounded, color: AppColors.travellerAccent, size: 18),
              label: Text(dest, style: const TextStyle(fontWeight: FontWeight.bold)),
              deleteIcon: const Icon(Icons.cancel_rounded, size: 18),
              onDeleted: () => setState(() => _destinations.remove(dest)),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Text('Add City of Your Perception:', style: AppTypography.h3),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customDestinationController,
                  decoration: const InputDecoration(
                    labelText: 'Type City Name',
                    hintText: 'e.g. Kodaikanal, Munnar, Mysuru, Goa',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.add_location_alt_rounded, color: AppColors.travellerAccent),
                  ),
                  onSubmitted: _addCustomDestination,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _addCustomDestination(_customDestinationController.text),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add City'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.travellerAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 4 of 5: General Preferences', style: AppTypography.caption.copyWith(color: AppColors.primaryBlue)),
          const SizedBox(height: 8),
          Text('Configure notification alerts:', style: AppTypography.h2),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('High Severity Weather Warnings'),
            subtitle: const Text('Receive push alerts for heavy rain & heatwaves'),
            value: true,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: const Text('Daily Morning Forecast Summary'),
            value: true,
            onChanged: (_) {},
          ),
        ],
      );
    }
  }

  // Step 4: Units
  Widget _buildUnitsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 5 of 5: Measurement Units', style: AppTypography.caption.copyWith(color: AppColors.primaryBlue)),
        const SizedBox(height: 8),
        Text('Choose preferred units', style: AppTypography.h2),
        const SizedBox(height: 16),
        Text('Temperature Unit:', style: AppTypography.h3),
        Row(
          children: [
            Radio<String>(value: 'C', groupValue: _tempUnit, onChanged: (v) => setState(() => _tempUnit = v!)),
            const Text('Celsius (°C)'),
            const SizedBox(width: 24),
            Radio<String>(value: 'F', groupValue: _tempUnit, onChanged: (v) => setState(() => _tempUnit = v!)),
            const Text('Fahrenheit (°F)'),
          ],
        ),
        const SizedBox(height: 16),
        Text('Wind Speed Unit:', style: AppTypography.h3),
        Row(
          children: [
            Radio<String>(value: 'km/h', groupValue: _speedUnit, onChanged: (v) => setState(() => _speedUnit = v!)),
            const Text('km/h'),
            const SizedBox(width: 24),
            Radio<String>(value: 'm/s', groupValue: _speedUnit, onChanged: (v) => setState(() => _speedUnit = v!)),
            const Text('m/s'),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _prevStep,
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(_currentStep == 4 ? 'Finish Setup' : 'Continue'),
          ),
        ],
      ),
    );
  }
}
