import 'package:flutter_test/flutter_test.dart';
import 'package:raitabazzar/models/weather_data.dart';
import 'package:raitabazzar/services/weather_service.dart';

void main() {
  group('WeatherService & WeatherData Tests', () {
    test('WeatherData fallback provides complete Karnataka baseline values', () {
      final fallback = WeatherData.fallback('Mandya');
      expect(fallback.district, equals('Mandya'));
      expect(fallback.temperatureC, equals(28.0));
      expect(fallback.humidityPct, equals(62));
      expect(fallback.rainChancePct, equals(15));
      expect(fallback.advisoryEn.isNotEmpty, isTrue);
      expect(fallback.advisoryKn.isNotEmpty, isTrue);
      expect(fallback.isLive, isFalse);
    });

    test('WeatherData.fromJson correctly deserializes FastAPI payload', () {
      final json = {
        'success': true,
        'district': 'Kolar',
        'temperature_c': 26.5,
        'humidity_pct': 70,
        'wind_speed_kmh': 14.2,
        'rain_chance_pct': 60,
        'condition': 'Rain Expected',
        'advisory_en': 'High chance of rain.',
        'advisory_kn': 'ಮಳೆಯ ಸಾಧ್ಯತೆ ಹೆಚ್ಚಿದೆ.',
      };

      final data = WeatherData.fromJson(json, isLive: true);
      expect(data.district, equals('Kolar'));
      expect(data.temperatureC, equals(26.5));
      expect(data.humidityPct, equals(70));
      expect(data.windSpeedKmh, equals(14.2));
      expect(data.rainChancePct, equals(60));
      expect(data.condition, equals('Rain Expected'));
      expect(data.advisoryEn, equals('High chance of rain.'));
      expect(data.advisoryKn, equals('ಮಳೆಯ ಸಾಧ್ಯತೆ ಹೆಚ್ಚಿದೆ.'));
      expect(data.isLive, isTrue);
    });

    test('WeatherService supported districts contains core APMC regions', () {
      expect(WeatherService.supportedDistricts, contains('Mandya'));
      expect(WeatherService.supportedDistricts, contains('Kolar'));
      expect(WeatherService.supportedDistricts, contains('Bangalore'));
      expect(WeatherService.supportedDistricts, contains('Mysuru'));
      expect(WeatherService.supportedDistricts, contains('Hubli'));
    });

    test('WeatherService.fetchWeather returns valid fallback when backend unconfigured', () async {
      final service = WeatherService();
      final result = await service.fetchWeather(district: 'Mandya');
      expect(result.district, equals('Mandya'));
      expect(result.temperatureC, isNotNull);
      expect(result.advisoryEn, isNotEmpty);
      expect(result.advisoryKn, isNotEmpty);
    });
  });
}
