enum CardType {
  heroCurrentWeather,
  alertBanner,
  hourlyForecastStrip,
  agriWeatherSummary,
  cropAdvisory,
  farmerMetricsGrid,
  travelDestinationSummary,
  travelRoadConditions,
  generalStatsGrid,
  weatherMapPreview,
  weeklyForecastList,
}

class PersonalizedCard {
  final String id;
  final CardType type;
  final String title;
  final String subtitle;
  final int priorityScore; // Lower number = higher priority on homepage
  final Map<String, dynamic> metadata;

  PersonalizedCard({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.priorityScore,
    this.metadata = const {},
  });
}
