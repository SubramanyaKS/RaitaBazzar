import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:raitabazzar/utils/constant.dart';

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  CloudinaryService({
    String? cloudName,
    String? uploadPreset,
  })  : cloudName = cloudName ?? AppConstants.cloudinaryCloudName,
        uploadPreset = uploadPreset ?? AppConstants.cloudinaryUploadPreset;

  bool get isConfigured =>
      cloudName.isNotEmpty &&
      cloudName != 'YOUR_CLOUD_NAME' &&
      uploadPreset.isNotEmpty &&
      uploadPreset != 'YOUR_UPLOAD_PRESET';

  /// Uploads a photo to Cloudinary and returns the secure HTTPS CDN URL.
  Future<String?> uploadImage(File imageFile) async {
    if (!isConfigured) {
      debugPrint('CloudinaryService: Cloudinary not configured yet. Skipping upload.');
      return null;
    }

    try {
      final uploadUri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uploadUri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(responseBody);
        final secureUrl = data['secure_url'] as String?;
        debugPrint('CloudinaryService: Image successfully uploaded -> $secureUrl');
        return secureUrl;
      } else {
        debugPrint('CloudinaryService: Upload failed with status ${response.statusCode}: $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('CloudinaryService: Network error during upload: $e');
      return null;
    }
  }
}
