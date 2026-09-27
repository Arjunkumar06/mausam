import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/weather_observation.dart';

class AlertBannerCard extends StatelessWidget {
  final WeatherAlert alert;

  const AlertBannerCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.alertExtreme.withValues(alpha: 0.1);
    Color border = AppColors.alertExtreme;
    IconData icon = Icons.warning_rounded;

    if (alert.severity == 'severe') {
      bg = AppColors.alertSevere.withValues(alpha: 0.1);
      border = AppColors.alertSevere;
      icon = Icons.error_outline_rounded;
    } else if (alert.severity == 'moderate') {
      bg = AppColors.alertModerate.withValues(alpha: 0.1);
      border = AppColors.alertModerate;
      icon = Icons.info_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: border, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: AppTypography.h3.copyWith(color: border),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(6)),
                      child: Text(alert.severity.toUpperCase(), style: AppTypography.badge),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  alert.description,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
