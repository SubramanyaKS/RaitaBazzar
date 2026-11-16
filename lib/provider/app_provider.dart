import 'package:flutter/material.dart';
import 'package:raitabazzar/services/firebase_service.dart';

class AppProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  String _selectedLanguage = 'English';
  String _selectedUser = 'farmer';
  Locale _locale = const Locale('en');

  // Farmer Profile State
  String _farmerName = 'Basavaraj Gowda';
  String _farmerPhone = '+91 98765 43210';
  String _farmerLocation = 'Mandya, Karnataka';
  String _fruitsId = 'FID-KA-2024-9843';
  bool _isKisanVerified = true;

  // Buyer Profile State
  String _buyerName = 'Ramesh Traders';
  String _buyerPhone = '+91 99887 76655';
  String _buyerBusiness = 'Wholesale Produce & Retail';
  String _buyerLocation = 'K.R. Market, Bengaluru';
  String _apmcLicense = 'APMC-BLR-8841';

  Locale get locale => _locale;
  String get selectedLanguage => _selectedLanguage;
  String get selectedUser => _selectedUser;

  String get farmerName => _farmerName;
  String get farmerPhone => _farmerPhone;
  String get farmerLocation => _farmerLocation;
  String get fruitsId => _fruitsId;
  bool get isKisanVerified => _isKisanVerified;

  String get buyerName => _buyerName;
  String get buyerPhone => _buyerPhone;
  String get buyerBusiness => _buyerBusiness;
  String get buyerLocation => _buyerLocation;
  String get apmcLicense => _apmcLicense;

  void setLanguage(String language) {
    _selectedLanguage = language;

    if (language == 'English') {
      _locale = const Locale('en');
    } else if (language == 'Kannada') {
      _locale = const Locale('kn');
    } else if (language == 'Hindi' || language == 'हिंदी') {
      _locale = const Locale('hi');
    }
    notifyListeners();
  }

  void setUser(String user) {
    _selectedUser = user;
    notifyListeners();
  }

  Future<void> loginWithPhone(String rawPhone, String role) async {
    String cleanNumber = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (!cleanNumber.startsWith('+91') && cleanNumber.length == 10) {
      cleanNumber = '+91 $cleanNumber';
    }

    _selectedUser = role;
    if (role == 'farmer') {
      _farmerPhone = cleanNumber;
    } else {
      _buyerPhone = cleanNumber;
    }
    notifyListeners();

    try {
      final cloudProfile = await _firebaseService.getUserProfile(cleanNumber);
      if (cloudProfile != null) {
        if (role == 'farmer') {
          _farmerName = cloudProfile['name'] ?? _farmerName;
          _farmerLocation = cloudProfile['location'] ?? _farmerLocation;
          _fruitsId = cloudProfile['fruitsId'] ?? _fruitsId;
          _isKisanVerified = cloudProfile['isKisanVerified'] ?? _isKisanVerified;
        } else {
          _buyerName = cloudProfile['name'] ?? _buyerName;
          _buyerBusiness = cloudProfile['business'] ?? _buyerBusiness;
          _buyerLocation = cloudProfile['location'] ?? _buyerLocation;
          _apmcLicense = cloudProfile['apmcLicense'] ?? _apmcLicense;
        }
        notifyListeners();
      } else {
        if (role == 'farmer') {
          await updateFarmerProfile();
        } else {
          await updateBuyerProfile();
        }
      }
    } catch (e) {
      debugPrint('Error syncing login profile with Firestore: $e');
    }
  }

  Future<void> updateFarmerProfile({String? name, String? phone, String? location, String? fruitsId}) async {
    if (name != null && name.isNotEmpty) _farmerName = name;
    if (phone != null && phone.isNotEmpty) _farmerPhone = phone;
    if (location != null && location.isNotEmpty) _farmerLocation = location;
    if (fruitsId != null) {
      _fruitsId = fruitsId;
      _isKisanVerified = fruitsId.isNotEmpty;
    }
    notifyListeners();

    try {
      await _firebaseService.saveUserProfile(_farmerPhone, {
        'role': 'farmer',
        'name': _farmerName,
        'phone': _farmerPhone,
        'location': _farmerLocation,
        'fruitsId': _fruitsId,
        'isKisanVerified': _isKisanVerified,
      });
    } catch (e) {
      debugPrint('Error saving farmer profile to Firestore: $e');
    }
  }

  Future<void> updateBuyerProfile({String? name, String? phone, String? business, String? location, String? license}) async {
    if (name != null && name.isNotEmpty) _buyerName = name;
    if (phone != null && phone.isNotEmpty) _buyerPhone = phone;
    if (business != null && business.isNotEmpty) _buyerBusiness = business;
    if (location != null && location.isNotEmpty) _buyerLocation = location;
    if (license != null) _apmcLicense = license;
    notifyListeners();

    try {
      await _firebaseService.saveUserProfile(_buyerPhone, {
        'role': 'buyer',
        'name': _buyerName,
        'phone': _buyerPhone,
        'business': _buyerBusiness,
        'location': _buyerLocation,
        'apmcLicense': _apmcLicense,
      });
    } catch (e) {
      debugPrint('Error saving buyer profile to Firestore: $e');
    }
  }
}
