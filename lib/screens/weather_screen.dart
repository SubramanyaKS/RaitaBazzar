import 'package:flutter/material.dart';
import 'package:raitabazzar/components/weather_stats.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/utils/constant.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.weather),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Weather Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.wb_sunny_rounded,
                      size: 64,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '28°C',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Partly Sunny • Ideal for Harvesting',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        WeatherStats(icon: Icons.water_drop, label: 'Humidity', value: '64%'),
                        WeatherStats(icon: Icons.air, label: 'Wind', value: '12 km/h'),
                        WeatherStats(icon: Icons.umbrella, label: 'Rain Chance', value: '10%'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Farm Advisory Section
              const Text(
                'Agricultural Advisory',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildAdvisoryCard(
                icon: Icons.check_circle_outline,
                color: AppConstants.primaryGreen,
                title: 'Good Sowing & Spraying Conditions',
                description: 'Dry weather expected for the next 48 hours. Favorable for pesticide spraying and harvesting standing crops.',
              ),
              const SizedBox(height: 10),
              _buildAdvisoryCard(
                icon: Icons.info_outline,
                color: Colors.orange.shade700,
                title: 'Light Showers Expected This Weekend',
                description: 'Plan grain drying and transport ahead of the weekend.',
              ),
            ],
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
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


