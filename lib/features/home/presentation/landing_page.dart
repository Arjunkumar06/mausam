import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/user_profile.dart';

class LandingPage extends StatelessWidget {
  final Function(UserProfile profile) onStartPersona;
  final VoidCallback onStartCustomOnboarding;

  const LandingPage({
    super.key,
    required this.onStartPersona,
    required this.onStartCustomOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildHeroSection(context),
            _buildFeatureCardsSection(context),
            _buildHowItWorksSection(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cloud_sync_rounded, color: AppColors.primaryBlue, size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mausam', style: AppTypography.h2.copyWith(color: AppColors.primaryBlue)),
                  Text('Personalized Weather Portal', style: AppTypography.caption),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onStartCustomOnboarding,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 64 : 40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryBlue.withOpacity(0.08),
            AppColors.backgroundLight,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: AppColors.primaryBlue, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Personalization Engine',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryBlueDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Weather that understands you.',
            textAlign: TextAlign.center,
            style: isDesktop
                ? AppTypography.heroTemp.copyWith(fontSize: 48)
                : AppTypography.h1.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              'A dynamic, intelligent homepage adapting in real-time to your location, profession, and daily activities — serving general citizens, farmers, and travelers.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => onStartPersona(UserProfile.defaultProfile('general')),
                icon: const Icon(Icons.person_rounded, color: AppColors.primaryBlue),
                label: const Text('Try General Persona'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => onStartPersona(UserProfile.defaultProfile('farmer')),
                icon: const Icon(Icons.eco_rounded, color: Colors.white),
                label: const Text('Try Farmer Persona'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.farmerGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => onStartPersona(UserProfile.defaultProfile('traveller')),
                icon: const Icon(Icons.flight_takeoff_rounded, color: Colors.white),
                label: const Text('Try Traveller Persona'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.travellerAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCardsSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final cards = [
      _FeatureCardData(
        title: 'General Citizen',
        tagline: 'Daily Living & Urban Air Quality',
        description: 'Instant overview of current temperature, rain probability, AQI, UV index, and severe weather warnings.',
        icon: Icons.wb_sunny_rounded,
        accentColor: AppColors.primaryBlue,
        badgeText: 'Urban & Daily',
      ),
      _FeatureCardData(
        title: 'Farmer Persona',
        tagline: 'Agri-Weather & Crop Advisories',
        description: 'Soil moisture, rain timing forecasts, spray window recommendations, and localized agricultural advisories.',
        icon: Icons.grass_rounded,
        accentColor: AppColors.farmerGreen,
        badgeText: 'Agricultural',
      ),
      _FeatureCardData(
        title: 'Traveller Persona',
        tagline: 'Destination & Route Visibility',
        description: 'Multi-destination tracking, ghat road fog warnings, cloud cover, and highway travel hazard alerts.',
        icon: Icons.explore_rounded,
        accentColor: AppColors.travellerAccent,
        badgeText: 'Travel & Mobility',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Tailored Weather Experiences', style: AppTypography.h2),
          const SizedBox(height: 8),
          Text(
            'The engine prioritizes cards based on user needs, not static layouts',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 32),
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cards.map((c) => Expanded(child: _buildCardItem(c))).toList(),
                )
              : Column(
                  children: cards.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCardItem(c),
                  )).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildCardItem(_FeatureCardData data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: data.accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.accentColor, size: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: data.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data.badgeText,
                  style: TextStyle(color: data.accentColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(data.title, style: AppTypography.h3),
          const SizedBox(height: 4),
          Text(data.tagline, style: AppTypography.caption.copyWith(color: data.accentColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(data.description, style: AppTypography.bodyMedium.copyWith(height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Text('How Personalization Works', style: AppTypography.h2),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildStepItem('1', 'User Profile Context', 'Combines user role, selected crops, travel routes, and preferences.'),
              _buildStepItem('2', 'Real-Time Observation', 'Reads local temperature, rainfall, soil moisture, and active warnings.'),
              _buildStepItem('3', 'Rule Engine Ranking', 'Prioritizes critical alerts and crop/travel advisories to top of homepage.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String title, String desc) {
    return SizedBox(
      width: 260,
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryBlue,
            child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.h3, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(desc, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.darkBackground,
      width: double.infinity,
      child: Column(
        children: [
          Text(
            'Mausam — Ministry of Earth Sciences / IMD Simulation',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            'Personalized Weather Platform',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _FeatureCardData {
  final String title;
  final String tagline;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String badgeText;

  _FeatureCardData({
    required this.title,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.badgeText,
  });
}
