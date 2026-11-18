class WeatherData {
  final String district;
  final double temperatureC;
  final int humidityPct;
  final double windSpeedKmh;
  final int rainChancePct;
  final String condition;
  final String advisoryEn;
  final String advisoryKn;
  final bool isLive;

  const WeatherData({
    required this.district,
    required this.temperatureC,
    required this.humidityPct,
    required this.windSpeedKmh,
    required this.rainChancePct,
    required this.condition,
    required this.advisoryEn,
    required this.advisoryKn,
    this.isLive = false,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, {bool isLive = true}) {
    return WeatherData(
      district: json['district']?.toString() ?? 'Mandya',
      temperatureC: (json['temperature_c'] as num?)?.toDouble() ?? 28.0,
      humidityPct: (json['humidity_pct'] as num?)?.toInt() ?? 64,
      windSpeedKmh: (json['wind_speed_kmh'] as num?)?.toDouble() ?? 12.0,
      rainChancePct: (json['rain_chance_pct'] as num?)?.toInt() ?? 10,
      condition: json['condition']?.toString() ?? 'Partly Sunny',
      advisoryEn: json['advisory_en']?.toString() ??
          'Dry weather expected for the next 48 hours. Favorable for pesticide spraying and harvesting standing crops.',
      advisoryKn: json['advisory_kn']?.toString() ??
          'ಮುಂದಿನ 48 ಗಂಟೆಗಳ ಕಾಲ ಒಣ ಹವೆ ಇರಲಿದೆ. ಕೀಟನಾಶಕ ಸಿಂಪಡಣೆ ಮತ್ತು ಕಟಾವಿಗೆ ಸೂಕ್ತ ಕಾಲ.',
      isLive: isLive,
    );
  }

  /// Safe local benchmark fallback when backend is unreachable or offline
  static WeatherData fallback(String district) {
    return WeatherData(
      district: district,
      temperatureC: 28.0,
      humidityPct: 62,
      windSpeedKmh: 11.5,
      rainChancePct: 15,
      condition: 'Partly Sunny',
      advisoryEn:
          'Favorable conditions for vegetable harvest and grain drying. Normal seasonal weather across Karnataka.',
      advisoryKn:
          'ತರಕಾರಿ ಕಟಾವು ಮತ್ತು ಧಾನ್ಯ ಒಣಗಿಸಲು ಸೂಕ್ತ ಹವಾಮಾನ. ರಾಜ್ಯಾದ್ಯಂತ ಸಾಮಾನ್ಯ ಕಾಲಿಕ ವಾತಾವರಣ.',
      isLive: false,
    );
  }
}
