import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raitabazzar/config/app_config.dart';
import 'package:raitabazzar/models/mandi_rate.dart';
import 'package:raitabazzar/utils/crop_dictionary.dart';

class MandiService {
  final http.Client _client;

  MandiService({http.Client? client}) : _client = client ?? http.Client();

  /// Default baseline data for key Karnataka APMCs (Mandya, Kolar, Bangalore, Mysuru, Hubli)
  static final List<MandiRate> defaultRates = [
    const MandiRate(
      id: 'mandya_tomato',
      commodity: 'Tomato',
      variety: 'Hybrid',
      market: 'Mandya APMC',
      district: 'Mandya',
      minPrice: 18.0,
      maxPrice: 26.0,
      modalPrice: 22.0,
      unit: 'Kg',
      trend: 'up',
      trendPct: 8.5,
      arrivalDate: 'Today',
    ),
    const MandiRate(
      id: 'kolar_tomato',
      commodity: 'Tomato',
      variety: 'Local',
      market: 'Kolar APMC',
      district: 'Kolar',
      minPrice: 16.0,
      maxPrice: 23.0,
      modalPrice: 20.0,
      unit: 'Kg',
      trend: 'down',
      trendPct: -4.2,
      arrivalDate: 'Today',
    ),
    const MandiRate(
      id: 'bangalore_onion',
      commodity: 'Red Onion',
      variety: 'Bellary',
      market: 'Yeshwanthpur APMC',
      district: 'Bangalore',
      minPrice: 28.0,
      maxPrice: 38.0,
      modalPrice: 34.0,
      unit: 'Kg',
      trend: 'stable',
      trendPct: 0.0,
      arrivalDate: 'Today',
    ),
    const MandiRate(
      id: 'mysuru_ragi',
      commodity: 'Ragi',
      variety: 'Local Red',
      market: 'Bandipalya APMC',
      district: 'Mysuru',
      minPrice: 3000.0,
      maxPrice: 3500.0,
      modalPrice: 3250.0,
      unit: 'Quintal',
      trend: 'up',
      trendPct: 3.1,
      arrivalDate: 'Today',
    ),
    const MandiRate(
      id: 'hubli_chilli',
      commodity: 'Green Chilies',
      variety: 'Guntur',
      market: 'Amaragol APMC',
      district: 'Hubli',
      minPrice: 42.0,
      maxPrice: 58.0,
      modalPrice: 50.0,
      unit: 'Kg',
      trend: 'up',
      trendPct: 12.0,
      arrivalDate: 'Today',
    ),
    const MandiRate(
      id: 'belagavi_potato',
      commodity: 'Potatoes',
      variety: 'Jyoti',
      market: 'Belagavi APMC',
      district: 'Belagavi',
      minPrice: 20.0,
      maxPrice: 28.0,
      modalPrice: 24.0,
      unit: 'Kg',
      trend: 'stable',
      trendPct: 0.0,
      arrivalDate: 'Today',
    ),
    const MandiRate(
      id: 'mandya_sugarcane',
      commodity: 'Sugarcane',
      variety: 'CO 86032',
      market: 'Pandavapura APMC',
      district: 'Mandya',
      minPrice: 3100.0,
      maxPrice: 3400.0,
      modalPrice: 3200.0,
      unit: 'Tonne',
      trend: 'stable',
      trendPct: 0.0,
      arrivalDate: 'Today',
    ),
    const MandiRate(
      id: 'ramanagara_silk',
      commodity: 'Banana (Robusta)',
      variety: 'Robusta',
      market: 'Channapatna APMC',
      district: 'Ramanagara',
      minPrice: 15.0,
      maxPrice: 22.0,
      modalPrice: 18.0,
      unit: 'Kg',
      trend: 'down',
      trendPct: -5.0,
      arrivalDate: 'Today',
    ),
  ];

  /// Fetches Mandi rates. If FastAPI backend URL is configured and responsive,
  /// returns live backend data; otherwise gracefully falls back to default APMC rates.
  Future<List<MandiRate>> fetchRates({String? district, String? commodity}) async {
    final baseUrl = AppConfig.apiBaseUrl;

    if (baseUrl.isNotEmpty) {
      try {
        final queryParams = <String, String>{};
        if (district != null && district.isNotEmpty && district != 'All') {
          queryParams['district'] = district;
        }
        if (commodity != null && commodity.isNotEmpty) {
          queryParams['commodity'] = commodity;
        }

        final normalizedUrl = baseUrl.endsWith('/api/v1')
            ? '$baseUrl/mandi-rates'
            : '$baseUrl/api/v1/mandi-rates';
        final uri = Uri.parse(normalizedUrl).replace(queryParameters: queryParams);
        final response = await _client.get(uri).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final Map<String, dynamic> body = jsonDecode(response.body);
          final List<dynamic> list = body['data'] ?? [];
          final rates = list.map((item) => MandiRate.fromJson(item as Map<String, dynamic>)).toList();
          if (rates.isNotEmpty) {
            return rates;
          }
        }
      } catch (e) {
        debugPrint('MandiService: Backend unreachable ($e). Using local APMC benchmark dataset.');
      }
    }

    // Filter local benchmark dataset
    return defaultRates.where((rate) {
      final matchesDistrict = district == null ||
          district.isEmpty ||
          district == 'All' ||
          rate.district.toLowerCase() == district.toLowerCase();

      final matchesCommodity = commodity == null ||
          commodity.isEmpty ||
          CropDictionary.matches(commodity, rate.commodity);

      return matchesDistrict && matchesCommodity;
    }).toList();
  }

  /// Calculates a recommended modal benchmark price for a given crop name.
  MandiRate? findBenchmarkForCrop(String cropName, {String? district}) {
    if (cropName.trim().isEmpty) return null;

    // 1. Try exact, partial, or vernacular synonym match with district
    final matches = defaultRates.where((r) {
      final matchName = CropDictionary.matches(cropName, r.commodity);
      if (!matchName) return false;
      if (district != null && district.isNotEmpty && district != 'All') {
        return r.district.toLowerCase() == district.toLowerCase();
      }
      return true;
    }).toList();

    if (matches.isNotEmpty) return matches.first;

    // 2. Try match without district restriction
    final fallbackMatches = defaultRates.where((r) {
      return CropDictionary.matches(cropName, r.commodity);
    }).toList();

    return fallbackMatches.isNotEmpty ? fallbackMatches.first : null;
  }
}
