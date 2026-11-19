import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/components/weather_stats.dart';
import 'package:raitabazzar/config/app_config.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/models/weather_data.dart';
import 'package:raitabazzar/provider/app_provider.dart';
import 'package:raitabazzar/services/weather_service.dart';
import 'package:raitabazzar/utils/constant.dart';

class WeatherScreen extends StatefulWidget {
  final String? initialDistrict;

  const WeatherScreen({super.key, this.initialDistrict});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  late String _selectedDistrict;
  WeatherData? _weather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDistrict = widget.initialDistrict ?? 'Mandya';
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() => _isLoading = true);
    final data = await _weatherService.fetchWeather(district: _selectedDistrict);
    if (mounted) {
      setState(() {
        _weather = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);
    final isKannada = appProvider.locale.languageCode == 'kn';

    final weather = _weather ?? WeatherData.fallback(_selectedDistrict);
    final advisory = isKannada ? weather.advisoryKn : weather.advisoryEn;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.weather, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Weather',
            onPressed: _loadWeather,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadWeather,
          color: AppConstants.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // District Selector Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: WeatherService.supportedDistricts.map((district) {
                      final isSelected = _selectedDistrict == district;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(district),
                          selected: isSelected,
                          selectedColor: AppConstants.lightGreenBg,
                          checkmarkColor: AppConstants.primaryGreen,
                          labelStyle: TextStyle(
                            color: isSelected ? AppConstants.primaryGreen : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected && _selectedDistrict != district) {
                              setState(() => _selectedDistrict = district);
                              _loadWeather();
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // Source indicator
                Row(
                  children: [
                    Icon(
                      weather.isLive ? Icons.cloud_done_rounded : Icons.offline_pin_rounded,
                      size: 16,
                      color: weather.isLive ? Colors.teal : Colors.orange.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      weather.isLive
                          ? 'Live Forecast (FastAPI / Open-Meteo)'
                          : (AppConfig.hasBackendUrl
                              ? 'Connecting to FastAPI weather...'
                              : 'District Benchmark (Offline Mode)'),
                      style: TextStyle(
                        fontSize: 12,
                        color: weather.isLive ? Colors.teal.shade800 : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Main Weather Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: weather.rainChancePct > 40
                          ? [const Color(0xFF455A64), const Color(0xFF263238)]
                          : [const Color(0xFF42A5F5), const Color(0xFF1976D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        )
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.white70, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      weather.district,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    weather.condition,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Icon(
                              weather.rainChancePct > 40
                                  ? Icons.grain_rounded
                                  : Icons.wb_sunny_rounded,
                              size: 64,
                              color: weather.rainChancePct > 40 ? Colors.lightBlueAccent : Colors.amber,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${weather.temperatureC.round()}°C',
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${weather.condition} • ${weather.district}',
                              style: const TextStyle(fontSize: 15, color: Colors.white70),
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                WeatherStats(
                                  icon: Icons.water_drop,
                                  label: 'Humidity',
                                  value: '${weather.humidityPct}%',
                                ),
                                WeatherStats(
                                  icon: Icons.air,
                                  label: 'Wind',
                                  value: '${weather.windSpeedKmh.round()} km/h',
                                ),
                                WeatherStats(
                                  icon: Icons.umbrella,
                                  label: 'Rain Chance',
                                  value: '${weather.rainChancePct}%',
                                ),
                              ],
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 24),

                // Farm Advisory Section
                const Text(
                  'Agricultural Advisory / ಕೃಷಿ ಸಲಹೆ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildAdvisoryCard(
                  icon: weather.rainChancePct > 40
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  color: weather.rainChancePct > 40
                      ? Colors.orange.shade700
                      : AppConstants.primaryGreen,
                  title: weather.rainChancePct > 40
                      ? 'Precipitation Alert'
                      : 'Favorable Field Conditions',
                  description: advisory,
                ),
                const SizedBox(height: 10),
                _buildAdvisoryCard(
                  icon: Icons.lightbulb_outline,
                  color: Colors.blue.shade700,
                  title: 'Irrigation & Spraying Guidance',
                  description: weather.rainChancePct > 40
                      ? 'Avoid pesticide spraying and hold off on surface irrigation to prevent chemical runoff.'
                      : 'Optimal window for foliar fertilizer and preventative bio-pesticide spraying.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvisoryCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
