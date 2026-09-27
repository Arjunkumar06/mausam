import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/weather_observation.dart';

class EnvironmentalStatsGrid extends StatelessWidget {
  final WeatherObservation observation;

  const EnvironmentalStatsGrid({super.key, required this.observation});

  String _getUvCategory(int uv) {
    if (uv <= 2) return 'Low Risk';
    if (uv <= 5) return 'Moderate';
    if (uv <= 7) return 'High Hazard';
    if (uv <= 10) return 'Very High';
    return 'Extreme Radiation';
  }

  Color _getUvColor(int uv) {
    if (uv <= 2) return AppColors.farmerGreen;
    if (uv <= 5) return Colors.orange;
    if (uv <= 7) return Colors.deepOrange;
    return AppColors.alertSevere;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isSmallMobile = width < 380;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Live Environmental & Sensor Grid',
                style: AppTypography.h3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Location: ${observation.location}',
                style: AppTypography.caption.copyWith(color: AppColors.primaryBlueDark, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: isMobile ? 2 : (width > 900 ? 3 : 2),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: isSmallMobile ? 1.45 : (isMobile ? 1.55 : 1.65),
          children: [
            _buildStatCard(
              'Air Quality (AQI)',
              '${observation.aqi}',
              observation.aqiStatus,
              Icons.air_rounded,
              observation.aqi <= 50
                  ? AppColors.farmerGreen
                  : (observation.aqi <= 100 ? Colors.orange : AppColors.alertSevere),
            ),
            _buildStatCard(
              'UV Index',
              '${observation.uvIndex}',
              _getUvCategory(observation.uvIndex),
              Icons.wb_sunny_rounded,
              _getUvColor(observation.uvIndex),
            ),
            _buildStatCard(
              'Visibility',
              '${observation.visibilityKm} km',
              observation.visibilityKm >= 8.0 ? 'Clear Highway' : 'Reduced Visibility',
              Icons.visibility_rounded,
              observation.visibilityKm >= 8.0 ? AppColors.primaryBlue : Colors.orange,
            ),
            _buildStatCard(
              'Rainfall & Prob',
              '${observation.rainAmountMm} mm',
              '${observation.rainProbability}% Probability',
              Icons.water_drop_rounded,
              AppColors.secondaryCyan,
            ),
            _buildStatCard(
              'Soil Moisture',
              '${observation.soilMoisture.toStringAsFixed(1)}%',
              'Soil Temp: ${observation.soilTemp.toStringAsFixed(1)}°C',
              Icons.grass_rounded,
              AppColors.farmerGreen,
            ),
            _buildStatCard(
              'Wind Telemetry',
              '${observation.windSpeed} km/h',
              'Direction: ${observation.windDirection}',
              Icons.air_rounded,
              AppColors.primaryBlue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String subtext, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          Text(
            subtext,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
