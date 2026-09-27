import '../../../shared/models/user_profile.dart';
import '../../../shared/models/weather_observation.dart';
import '../../../shared/models/personalized_card.dart';

abstract class PersonalizationEngine {
  List<PersonalizedCard> rankCards({
    required UserProfile profile,
    required WeatherObservation observation,
  });
}

class RuleBasedPersonalizationEngine implements PersonalizationEngine {
  @override
  List<PersonalizedCard> rankCards({
    required UserProfile profile,
    required WeatherObservation observation,
  }) {
    final cards = <PersonalizedCard>[];
    final userType = profile.userType.toLowerCase();

    // 1. Alert Banner - Highest priority if severe weather warning exists
    if (observation.alerts.isNotEmpty) {
      final hasSevere = observation.alerts.any((a) => a.severity == 'severe' || a.severity == 'extreme');
      cards.add(PersonalizedCard(
        id: 'card-alert-banner',
        type: CardType.alertBanner,
        title: observation.alerts.first.title,
        subtitle: observation.alerts.first.description,
        priorityScore: hasSevere ? 1 : 15,
        metadata: {'alert': observation.alerts.first},
      ));
    }

    // 2. Hero Current Weather Card
    cards.add(PersonalizedCard(
      id: 'card-hero-current',
      type: CardType.heroCurrentWeather,
      title: 'Current Weather Conditions',
      subtitle: '${observation.temp}°C • Feels like ${observation.feelsLike}°C',
      priorityScore: userType == 'general' ? 2 : 10,
    ));

    // 3. Persona Specific Cards (No duplicate cards, no radar, no redundant outlook)
    if (userType == 'farmer') {
      final avoidSpraying = observation.rainProbability > 60;
      cards.add(PersonalizedCard(
        id: 'card-crop-advisory',
        type: CardType.cropAdvisory,
        title: '${profile.selectedCrop} Spray & Irrigation Advisory',
        subtitle: avoidSpraying
            ? 'Avoid pesticide/fertilizer spraying today due to ${observation.rainProbability}% precipitation probability.'
            : 'Favorable conditions for field activities and irrigation.',
        priorityScore: 3,
        metadata: {
          'crop': profile.selectedCrop,
          'soil_moisture': '${observation.soilMoisture}%',
          'soil_temp': '${observation.soilTemp}°C',
          'spray_condition': avoidSpraying ? 'Unfavorable' : 'Optimal',
        },
      ));

      cards.add(PersonalizedCard(
        id: 'card-farmer-metrics',
        type: CardType.farmerMetricsGrid,
        title: 'Soil & Environmental Sensors',
        subtitle: 'Real-time ground sensors for agricultural planning',
        priorityScore: 4,
      ));
    } else if (userType == 'traveller') {
      cards.add(PersonalizedCard(
        id: 'card-travel-summary',
        type: CardType.travelDestinationSummary,
        title: 'Saved Destinations & Route Hazards',
        subtitle: 'Monitoring ${profile.travelDestinations.join(", ")}',
        priorityScore: 3,
        metadata: {'destinations': profile.travelDestinations},
      ));

      cards.add(PersonalizedCard(
        id: 'card-general-grid',
        type: CardType.generalStatsGrid,
        title: 'Route Weather & Environmental Metrics',
        subtitle: 'Visibility: ${observation.visibilityKm} km • AQI: ${observation.aqi}',
        priorityScore: 4,
      ));
    } else {
      // General persona
      cards.add(PersonalizedCard(
        id: 'card-general-grid',
        type: CardType.generalStatsGrid,
        title: 'Environmental Sensors & Metrics',
        subtitle: 'AQI: ${observation.aqi} (${observation.aqiStatus}) • UV: ${observation.uvIndex}',
        priorityScore: 3,
      ));
    }

    // Sort by priorityScore ascending
    cards.sort((a, b) => a.priorityScore.compareTo(b.priorityScore));
    return cards;
  }
}
