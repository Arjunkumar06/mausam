import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/weather_observation.dart';

class RadarScreen extends StatefulWidget {
  final WeatherObservation observation;

  const RadarScreen({super.key, required this.observation});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  String _activeLayer = 'Rainfall Radar';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRadarHeader(),
          const SizedBox(height: 16),
          _buildLayerSelector(),
          const SizedBox(height: 16),
          _buildInteractiveRadarMap(),
          const SizedBox(height: 16),
          _buildRadarLegend(),
          const SizedBox(height: 20),
          _buildSatelliteTelemetryCard(),
        ],
      ),
    );
  }

  Widget _buildRadarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryCyan.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doppler Radar & Satellite View',
                  style: AppTypography.h3.copyWith(color: AppColors.travellerAccent),
                ),
                const SizedBox(height: 4),
                Text(
                  'Live Doppler Radar Centered on ${widget.observation.location}',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.satellite_alt_rounded, color: AppColors.secondaryCyan, size: 32),
        ],
      ),
    );
  }

  Widget _buildLayerSelector() {
    final layers = ['Rainfall Radar', 'Cloud Cover', 'Wind Vectors', 'Surface Temp'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: layers.map((layer) {
          final isSelected = _activeLayer == layer;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(layer),
              selected: isSelected,
              selectedColor: AppColors.secondaryCyan,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) => setState(() => _activeLayer = layer),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInteractiveRadarMap() {
    Color activeColor = AppColors.secondaryCyan;
    IconData activeIcon = Icons.radar_rounded;
    String layerDesc = 'Precipitation reflectivity dBZ feed';

    if (_activeLayer == 'Cloud Cover') {
      activeColor = Colors.lightBlueAccent;
      activeIcon = Icons.cloud_rounded;
      layerDesc = 'INSAT Thermal IR Cloud Top Height';
    } else if (_activeLayer == 'Wind Vectors') {
      activeColor = Colors.tealAccent;
      activeIcon = Icons.air_rounded;
      layerDesc = 'Surface & Streamline Wind Vectors (${widget.observation.windSpeed} km/h ${widget.observation.windDirection})';
    } else if (_activeLayer == 'Surface Temp') {
      activeColor = Colors.orangeAccent;
      activeIcon = Icons.thermostat_rounded;
      layerDesc = 'Surface Infrared Radiometer (${widget.observation.temp}°C)';
    }

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activeColor, width: 2),
        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 12)],
      ),
      child: Stack(
        children: [
          // Radar Range Rings Visual
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: activeColor.withValues(alpha: 0.3), width: 1.5),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: activeColor.withValues(alpha: 0.4), width: 1.5),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(activeIcon, color: activeColor, size: 56),
                const SizedBox(height: 12),
                Text(
                  'Active Layer: $_activeLayer',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  layerDesc,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '100 km Radar Range • ${widget.observation.location}',
                  style: TextStyle(color: activeColor, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 12),
                  SizedBox(width: 6),
                  Text('LIVE INSAT-3DS RADAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Temp: ${widget.observation.temp}°C | Rain: ${widget.observation.rainProbability}%',
                style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Echo Reflectivity Scale (dBZ)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              _legendColorBlock(Colors.blue, 'Light (10-25)'),
              _legendColorBlock(Colors.green, 'Mod (25-40)'),
              _legendColorBlock(Colors.orange, 'Heavy (40-50)'),
              _legendColorBlock(Colors.red, 'Severe (50+)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendColorBlock(Color color, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSatelliteTelemetryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Satellite Telemetry & Sensor Details', style: AppTypography.h3),
            const SizedBox(height: 12),
            _buildTelemetryRow('Satellite Instrument', 'INSAT-3DS Imager Channel 4'),
            _buildTelemetryRow('Orbital Slot', '74.0° East (Geostationary)'),
            _buildTelemetryRow('Spatial Resolution', '1.0 km (Thermal Infrared)'),
            _buildTelemetryRow('Data Provider', widget.observation.source),
            _buildTelemetryRow('Active Location', widget.observation.location),
            _buildTelemetryRow('Data Quality', widget.observation.dataQuality),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
