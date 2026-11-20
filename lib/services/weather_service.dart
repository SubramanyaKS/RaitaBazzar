import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raitabazzar/config/app_config.dart';
import 'package:raitabazzar/models/weather_data.dart';

class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  static const List<String> supportedDistricts = [
    'Mandya',
    'Kolar',
    'Bangalore',
    'Mysuru',
    'Hubli',
    'Belagavi',
    'Hassan',
    'Shimoga',
    'Tumakuru',
    'Haveri',
    'Davanagere',
    'Ballari',
  ];

  /// Fetches real-time weather from FastAPI backend.
  /// Gracefully falls back to local district benchmark if offline or unreachable.
  Future<WeatherData> fetchWeather({String district = 'Mandya'}) async {
    final cleanDistrict = district.trim().isEmpty ? 'Mandya' : district.trim();
    final baseUrl = AppConfig.apiBaseUrl.trim();

    if (baseUrl.isNotEmpty) {
      try {
        final normalizedUrl = baseUrl.endsWith('/api/v1')
            ? '$baseUrl/weather'
            : '$baseUrl/api/v1/weather';

        final uri = Uri.parse(normalizedUrl).replace(queryParameters: {
          'district': cleanDistrict,
        });

        final response = await _client.get(uri).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final Map<String, dynamic> json = jsonDecode(response.body);
          return WeatherData.fromJson(json, isLive: true);
        } else {
          debugPrint('WeatherService: Server returned ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('WeatherService: FastAPI unreachable ($e). Using local fallback.');
      }
    }

    return WeatherData.fallback(cleanDistrict);
  }
}
