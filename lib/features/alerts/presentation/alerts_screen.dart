import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/weather_observation.dart';
import '../../home/presentation/widgets/alert_banner_card.dart';

class AlertsScreen extends StatefulWidget {
  final WeatherObservation observation;

  const AlertsScreen({super.key, required this.observation});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool _pushAlertsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final alerts = widget.observation.alerts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlertsHeader(),
          const SizedBox(height: 16),
          _buildAlertNotificationToggle(),
          const SizedBox(height: 20),
          Text('Active Meteorological Warnings', style: AppTypography.h3),
          const SizedBox(height: 12),
          if (alerts.isNotEmpty)
            ...alerts.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AlertBannerCard(alert: a),
                ))
          else
            _buildNoAlertsCard(),
          const SizedBox(height: 20),
          _buildSafetyProtocolsCard(),
        ],
      ),
    );
  }

  Widget _buildAlertsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.alertSevere.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.alertSevere.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Severe Weather Center',
                style: AppTypography.h3.copyWith(color: AppColors.alertSevere),
              ),
              const SizedBox(height: 4),
              Text(
                'Location: ${widget.observation.location}',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
          const Icon(Icons.warning_amber_rounded, color: AppColors.alertSevere, size: 32),
        ],
      ),
    );
  }

  Widget _buildAlertNotificationToggle() {
    return Card(
      child: SwitchListTile(
        title: const Text('Push Weather Warnings', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Receive instant alerts for heavy rain, heatwaves & fog hazards'),
        value: _pushAlertsEnabled,
        activeColor: AppColors.alertSevere,
        onChanged: (val) => setState(() => _pushAlertsEnabled = val),
      ),
    );
  }

  Widget _buildNoAlertsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.farmerGreen),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.farmerGreen, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No Severe Warnings Active', style: AppTypography.h3.copyWith(color: AppColors.farmerGreen)),
                const SizedBox(height: 4),
                Text('Current weather parameters for ${widget.observation.location} are within normal safe limits.', style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyProtocolsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Emergency Safety Guidelines', style: AppTypography.h3),
            const SizedBox(height: 12),
            _buildGuideline('Heavy Rainfall & Floods', 'Avoid low-lying underpasses and waterlogged roads. Move to higher ground.'),
            _buildGuideline('Ghat Fog & Low Visibility', 'Turn on low-beam headlights and hazard fog lamps. Maintain 50m vehicle distance.'),
            _buildGuideline('Thunderstorm & Lightning', 'Stay indoors away from tall solitary trees and metal structures.'),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideline(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(desc, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
