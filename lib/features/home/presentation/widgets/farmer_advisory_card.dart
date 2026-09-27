import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/weather_observation.dart';

class FarmerAdvisoryCard extends StatelessWidget {
  final WeatherObservation observation;
  final String selectedCrop;
  final ValueChanged<String> onCropChanged;

  const FarmerAdvisoryCard({
    super.key,
    required this.observation,
    required this.selectedCrop,
    required this.onCropChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool rainRisk = observation.rainProbability > 60;

    return Card(
      color: AppColors.farmerGreenLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.farmerGreen, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco_rounded, color: AppColors.farmerGreen, size: 28),
                    const SizedBox(width: 8),
                    Text('Agri-Weather Advisory', style: AppTypography.h3.copyWith(color: AppColors.farmerGreen)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.farmerGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Agri Field',
                    style: TextStyle(
                      color: AppColors.farmerGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: rainRisk ? AppColors.alertSevere : AppColors.farmerGreen),
              ),
              child: Row(
                children: [
                  Icon(
                    rainRisk ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    color: rainRisk ? AppColors.alertSevere : AppColors.farmerGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rainRisk ? 'Spray Postponement Advised' : 'Optimal Field Window',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: rainRisk ? AppColors.alertSevere : AppColors.farmerGreen,
                          ),
                        ),
                        Text(
                          rainRisk
                              ? 'High rain probability (${observation.rainProbability}%). Postpone pesticide & fertilizer application for crops.'
                              : 'Conditions favorable for harvesting, weeding, and crop management.',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAgriTag('Soil Temp', '${observation.soilTemp}°C'),
                _buildAgriTag('Soil Moisture', '${observation.soilMoisture}%'),
                _buildAgriTag('24h Rain', '${observation.rainAmountMm} mm'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgriTag(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.farmerGreen)),
        ],
      ),
    );
  }
}
