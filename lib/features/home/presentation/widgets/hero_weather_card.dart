import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/weather_observation.dart';

class HeroWeatherCard extends StatelessWidget {
  final WeatherObservation observation;
  final String userType;

  const HeroWeatherCard({
    super.key,
    required this.observation,
    required this.userType,
  });

  IconData _getWeatherIcon(int rainProb) {
    if (rainProb > 70) return Icons.thunderstorm_rounded;
    if (rainProb > 40) return Icons.umbrella_rounded;
    if (rainProb > 20) return Icons.cloud_rounded;
    return Icons.wb_sunny_rounded;
  }

  String _getWeatherConditionText(int rainProb, double temp) {
    if (rainProb > 70) return 'Thunderstorms & Rain';
    if (rainProb > 40) return 'Moderate Rain Likely';
    if (rainProb > 20) return 'Partly Cloudy';
    if (temp > 32) return 'Hot & Sunny';
    return 'Clear & Pleasant';
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = AppColors.primaryBlue;
    if (userType == 'farmer') accentColor = AppColors.farmerGreen;
    if (userType == 'traveller') accentColor = AppColors.travellerAccent;

    final conditionText = _getWeatherConditionText(observation.rainProbability, observation.temp);
    final weatherIcon = _getWeatherIcon(observation.rainProbability);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor,
            accentColor.withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Colors.white70, size: 20),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        observation.location,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  observation.dataQuality,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Temperature & Condition Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${observation.temp.toStringAsFixed(1)}°C',
                        style: AppTypography.heroTemp.copyWith(color: Colors.white),
                      ),
                    ),
                    Text(
                      'Feels like ${observation.feelsLike.toStringAsFixed(1)}°C • $conditionText',
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(weatherIcon, color: Colors.white, size: 52),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          // Metric Strip
          Row(
            children: [
              Expanded(child: _buildMetric('Rain Prob', '${observation.rainProbability}% (${observation.rainAmountMm} mm)', Icons.water_drop_outlined)),
              Expanded(child: _buildMetric('Wind Speed', '${observation.windSpeed} km/h ${observation.windDirection}', Icons.air_rounded)),
              Expanded(child: _buildMetric('Humidity', '${observation.humidity}%', Icons.water_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}
