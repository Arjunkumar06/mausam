import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/weather_observation.dart';

class ForecastScreen extends StatelessWidget {
  final WeatherObservation observation;

  const ForecastScreen({super.key, required this.observation});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationHeader(),
          const SizedBox(height: 16),
          _buildHourlyForecastStrip(),
          const SizedBox(height: 20),
          _buildWeeklyForecastList(),
          const SizedBox(height: 20),
          _buildAtmosphericParametersGrid(),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '7-Day & 24-Hour Forecast',
                style: AppTypography.h3.copyWith(color: AppColors.primaryBlueDark),
              ),
              const SizedBox(height: 4),
              Text(
                'Location: ${observation.location}',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
          const Icon(Icons.calendar_today_rounded, color: AppColors.primaryBlue, size: 28),
        ],
      ),
    );
  }

  Widget _buildHourlyForecastStrip() {
    final now = DateTime.now();
    final hourlyData = List.generate(12, (index) {
      final hourTime = now.add(Duration(hours: index * 2));
      final hourStr = '${hourTime.hour}:00';
      final tempVal = (observation.temp + ((index % 3) * 0.8) - ((index % 2) * 0.5)).toStringAsFixed(1);
      final rainVal = (observation.rainProbability + ((index * 5) % 30)).clamp(0, 100);
      return {'time': hourStr, 'temp': tempVal, 'rain': rainVal};
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('24-Hour Hourly Trend', style: AppTypography.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyData.length,
            itemBuilder: (context, index) {
              final item = hourlyData[index];
              return Container(
                width: 85,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['time'].toString(), style: AppTypography.caption),
                    Icon(
                      (item['rain'] as int) > 50 ? Icons.water_drop_rounded : Icons.wb_sunny_rounded,
                      color: (item['rain'] as int) > 50 ? AppColors.primaryBlue : Colors.orange,
                      size: 24,
                    ),
                    Text('${item['temp']}°C', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${item['rain']}% rain', style: const TextStyle(fontSize: 10, color: AppColors.primaryBlue)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyForecastList() {
    final days = ['Today', 'Tomorrow', 'Day 3', 'Day 4', 'Day 5', 'Day 6', 'Day 7'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('7-Day Weather Outlook', style: AppTypography.h3),
        const SizedBox(height: 12),
        Column(
          children: List.generate(7, (index) {
            final dayName = days[index];
            final high = (observation.temp + 1.5 + (index % 3)).toStringAsFixed(1);
            final low = (observation.temp - 5.0 - (index % 2)).toStringAsFixed(1);
            final rainProb = (observation.rainProbability + (index * 4) % 40).clamp(10, 95);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Icon(
                        rainProb > 50 ? Icons.water_drop_rounded : Icons.wb_sunny_rounded,
                        color: rainProb > 50 ? AppColors.primaryBlue : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text('$rainProb% rain', style: AppTypography.caption),
                    ],
                  ),
                  Text('$high° / $low°C', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAtmosphericParametersGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Atmospheric & Solar Parameters', style: AppTypography.h3),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildParamCard('Pressure', '1012 hPa', 'Normal Barometric', Icons.speed_rounded),
            _buildParamCard('Dew Point', '${(observation.temp - 3.2).toStringAsFixed(1)}°C', 'High Humidity', Icons.water_rounded),
            _buildParamCard('UV Index', '${observation.uvIndex}', 'Solar Radiation', Icons.wb_sunny_rounded),
            _buildParamCard('Cloud Cover', '${observation.humidity - 10}%', 'INSAT Radiometer', Icons.cloud_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildParamCard(String label, String value, String sub, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.caption),
              Icon(icon, color: AppColors.primaryBlue, size: 20),
            ],
          ),
          Text(value, style: AppTypography.h3),
          Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
