import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactHelper {
  static Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          _showError(context, 'Could not open phone dialer for $phoneNumber');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Phone dialer error: $e');
      }
    }
  }

  static Future<void> openWhatsApp({
    required BuildContext context,
    required String phoneNumber,
    required String cropName,
  }) async {
    // Strip everything except digits
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.length == 10) {
      cleanNumber = '91$cleanNumber'; // Default to India country code
    }

    final message = 'Hello, I saw your listing for "$cropName" on RaitaBazzar. Is it still available?';
    final urlString = 'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}';
    final Uri whatsappUri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showError(context, 'Could not open WhatsApp for +$cleanNumber');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'WhatsApp error: $e');
      }
    }
  }

  static void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }
}
