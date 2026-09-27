import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/weather_observation.dart';

class TravellerDestinationCard extends StatelessWidget {
  final List<String> savedDestinations;
  final ValueChanged<String> onSelectDestination;
  final VoidCallback onAddDestination;
  final ValueChanged<String>? onRemoveDestination;

  const TravellerDestinationCard({
    super.key,
    required this.savedDestinations,
    required this.onSelectDestination,
    required this.onAddDestination,
    this.onRemoveDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.travellerAccentLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.travellerAccent, width: 1.5),
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
                    const Icon(Icons.explore_rounded, color: AppColors.travellerAccent, size: 28),
                    const SizedBox(width: 8),
                    Text('Travel & Route Weather', style: AppTypography.h3.copyWith(color: AppColors.travellerAccent)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_location_alt_rounded, color: AppColors.travellerAccent),
                  onPressed: onAddDestination,
                  tooltip: 'Add Destination',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Saved Trip Routes & Destinations:', style: AppTypography.caption),
            const SizedBox(height: 12),
            if (savedDestinations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'No travel destinations added yet. Tap + to add cities!',
                    style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              Column(
                children: savedDestinations.map((dest) {
                  final isOoty = dest.toLowerCase().contains('ooty');
                  final obs = isOoty ? WeatherObservation.mockOoty() : WeatherObservation.mockBengaluru();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                isOoty ? Icons.foggy : Icons.wb_sunny_rounded,
                                color: isOoty ? AppColors.alertSevere : Colors.orange,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(dest, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                    Text(
                                      '${obs.temp}°C • Vis: ${obs.visibilityKm} km',
                                      style: AppTypography.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => onSelectDestination(dest),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.travellerAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                elevation: 1,
                              ),
                              icon: const Icon(Icons.visibility_rounded, size: 14),
                              label: const Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            if (onRemoveDestination != null) ...[
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                                onPressed: () => onRemoveDestination!(dest),
                                tooltip: 'Remove Destination',
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
