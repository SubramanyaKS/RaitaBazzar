import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Central application configuration.
/// Credentials can be supplied either via:
/// 1. `--dart-define-from-file=secrets.json` (Flutter 3.7+)
/// 2. `--dart-define=API_BASE_URL=...`
/// 3. Local `assets/config/secrets.json` (gitignored, automatically loaded at startup)
class AppConfig {
  static String cloudinaryCloudName = const String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
  static String cloudinaryUploadPreset = const String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET');
  static String apiBaseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://raitabazzar-api.onrender.com/api/v1',
  );

  static bool get isCloudinaryConfigured =>
      cloudinaryCloudName.isNotEmpty &&
      cloudinaryCloudName != 'YOUR_CLOUD_NAME' &&
      cloudinaryUploadPreset.isNotEmpty &&
      cloudinaryUploadPreset != 'YOUR_UPLOAD_PRESET';

  static bool get hasBackendUrl => apiBaseUrl.trim().isNotEmpty;

  /// Initializes credentials from `assets/config/secrets.json` if not provided via dart-define.
  static Future<void> initialize() async {
    try {
      final jsonString = await rootBundle.loadString('assets/config/secrets.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);

      final cloudName = data['CLOUDINARY_CLOUD_NAME']?.toString().trim();
      final uploadPreset = data['CLOUDINARY_UPLOAD_PRESET']?.toString().trim();
      final backendUrl = data['API_BASE_URL']?.toString().trim();

      if ((cloudinaryCloudName.isEmpty || cloudinaryCloudName == 'YOUR_CLOUD_NAME') &&
          cloudName != null &&
          cloudName.isNotEmpty) {
        cloudinaryCloudName = cloudName;
      }
      if ((cloudinaryUploadPreset.isEmpty || cloudinaryUploadPreset == 'YOUR_UPLOAD_PRESET') &&
          uploadPreset != null &&
          uploadPreset.isNotEmpty) {
        cloudinaryUploadPreset = uploadPreset;
      }
      if (apiBaseUrl.isEmpty && backendUrl != null && backendUrl.isNotEmpty) {
        apiBaseUrl = backendUrl;
      }
      debugPrint('AppConfig: Loaded config with apiBaseUrl="$apiBaseUrl"');
    } catch (_) {
      // Local secrets.json not present or cannot be read; safe fallback to default
    }

    // Trigger non-blocking cloud warm-up
    warmUpBackend();
  }

  /// Non-blocking background ping to wake up free-tier cloud instances (e.g. Render cold start)
  static void warmUpBackend() {
    if (apiBaseUrl.isNotEmpty) {
      try {
        final healthUrl = apiBaseUrl.endsWith('/api/v1')
            ? '$apiBaseUrl/health'
            : '$apiBaseUrl/api/v1/health';
        http.get(Uri.parse(healthUrl)).timeout(const Duration(seconds: 45)).then((resp) {
          if (resp.statusCode == 200) {
            debugPrint('AppConfig: Cloud backend is warm and ready.');
          }
        }).catchError((e) {
          debugPrint('AppConfig: Warm-up ping error (expected if starting up): $e');
        });
      } catch (_) {
        // Safe ignore
      }
    }
  }
}
