import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactHelper {
  /// Extracts the canonical 10-digit Indian mobile number for reliable matching.
  /// e.g. '+91 98765 43210' -> '9876543210'
  static String normalizePhone10(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10 && digits.startsWith('91')) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  /// Formats any Indian mobile number into canonical E.164 format (+91XXXXXXXXXX).
  static String formatIndianPhone(String phoneNumber) {
    final normalized = normalizePhone10(phoneNumber);
    if (normalized.length == 10) {
      return '+91$normalized';
    }
    return phoneNumber.trim();
  }

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

  static Future<void> shareDealAgreement({
    required BuildContext context,
    required String buyerPhone,
    required String buyerName,
    required String cropName,
    required double quantity,
    required String unit,
    required double price,
    required double totalAmount,
  }) async {
    String cleanNumber = buyerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.length == 10) {
      cleanNumber = '91$cleanNumber';
    }

    final message = '''
🌾 *RaitaBazzar Deal Agreement / ಒಪ್ಪಂದ* 🌾

✅ *Deal Status:* Accepted by Farmer
🛒 *Buyer:* $buyerName
📦 *Crop:* $cropName
⚖️ *Quantity:* $quantity $unit
💰 *Agreed Rate:* ₹$price / $unit
💵 *Total Payout:* ₹${totalAmount.toStringAsFixed(0)}

Direct farmer-to-buyer deal confirmed via RaitaBazzar. Please confirm pickup schedule!
''';

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
