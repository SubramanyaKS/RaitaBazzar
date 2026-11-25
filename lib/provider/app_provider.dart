import 'package:flutter/material.dart';
import 'package:raitabazzar/services/firebase_service.dart';
import 'package:raitabazzar/utils/contact_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  static const String _prefIsLoggedIn = 'is_logged_in';
  static const String _prefSelectedRole = 'selected_role';
  static const String _prefSelectedLang = 'selected_language';
  static const String _prefFarmerName = 'farmer_name';
  static const String _prefFarmerPhone = 'farmer_phone';
  static const String _prefFarmerLocation = 'farmer_location';
  static const String _prefFruitsId = 'fruits_id';
  static const String _prefBuyerName = 'buyer_name';
  static const String _prefBuyerPhone = 'buyer_phone';
  static const String _prefBuyerBusiness = 'buyer_business';
  static const String _prefBuyerLocation = 'buyer_location';
  static const String _prefApmcLicense = 'apmc_license';

  bool _isLoggedIn = false;
  String _selectedLanguage = 'English';
  String _selectedUser = 'farmer';
  Locale _locale = const Locale('en');

  // Farmer Profile State
  String _farmerName = 'Basavaraj Gowda';
  String _farmerPhone = '+919876543210';
  String _farmerLocation = 'Mandya, Karnataka';
  String _fruitsId = 'FID-KA-2024-9843';
  bool _isKisanVerified = true;

  // Buyer Profile State
  String _buyerName = 'Ramesh Traders';
  String _buyerPhone = '+919988776655';
  String _buyerBusiness = 'Wholesale Produce & Retail';
  String _buyerLocation = 'K.R. Market, Bengaluru';
  String _apmcLicense = 'APMC-BLR-8841';

  bool get isLoggedIn => _isLoggedIn;
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

  String get activePhone => _selectedUser == 'buyer' ? _buyerPhone : _farmerPhone;

  /// Restores persisted login session, role, language, and profile from local storage.
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_prefIsLoggedIn) ?? false;
      _selectedUser = prefs.getString(_prefSelectedRole) ?? 'farmer';

      final savedLang = prefs.getString(_prefSelectedLang);
      if (savedLang != null && savedLang.isNotEmpty) {
        _applyLanguageState(savedLang);
      }

      _farmerName = prefs.getString(_prefFarmerName) ?? _farmerName;
      _farmerPhone = prefs.getString(_prefFarmerPhone) ?? _farmerPhone;
      _farmerLocation = prefs.getString(_prefFarmerLocation) ?? _farmerLocation;
      _fruitsId = prefs.getString(_prefFruitsId) ?? _fruitsId;
      _isKisanVerified = _fruitsId.isNotEmpty;

      _buyerName = prefs.getString(_prefBuyerName) ?? _buyerName;
      _buyerPhone = prefs.getString(_prefBuyerPhone) ?? _buyerPhone;
      _buyerBusiness = prefs.getString(_prefBuyerBusiness) ?? _buyerBusiness;
      _buyerLocation = prefs.getString(_prefBuyerLocation) ?? _buyerLocation;
      _apmcLicense = prefs.getString(_prefApmcLicense) ?? _apmcLicense;

      notifyListeners();
    } catch (e) {
      debugPrint('AppProvider: Could not restore local session: $e');
    }
  }

  Future<void> _persistSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefIsLoggedIn, _isLoggedIn);
      await prefs.setString(_prefSelectedRole, _selectedUser);
      await prefs.setString(_prefSelectedLang, _selectedLanguage);
      await prefs.setString(_prefFarmerName, _farmerName);
      await prefs.setString(_prefFarmerPhone, _farmerPhone);
      await prefs.setString(_prefFarmerLocation, _farmerLocation);
      await prefs.setString(_prefFruitsId, _fruitsId);
      await prefs.setString(_prefBuyerName, _buyerName);
      await prefs.setString(_prefBuyerPhone, _buyerPhone);
      await prefs.setString(_prefBuyerBusiness, _buyerBusiness);
      await prefs.setString(_prefBuyerLocation, _buyerLocation);
      await prefs.setString(_prefApmcLicense, _apmcLicense);
    } catch (e) {
      debugPrint('AppProvider: Could not persist local session: $e');
    }
  }

  void _applyLanguageState(String language) {
    _selectedLanguage = language;
    if (language == 'English') {
      _locale = const Locale('en');
    } else if (language == 'Kannada') {
      _locale = const Locale('kn');
    } else if (language == 'Hindi' || language == 'हिंदी') {
      _locale = const Locale('hi');
    }
  }

  void setLanguage(String language) {
    _applyLanguageState(language);
    notifyListeners();
    _persistSession();
  }

  void setUser(String user) {
    final previousRole = _selectedUser;
    _selectedUser = user;

    // Keep phone identity seamless when an authenticated user switches roles
    if (_isLoggedIn && previousRole != user) {
      if (user == 'buyer' && _buyerPhone == '+919988776655' && _farmerPhone != '+919876543210') {
        _buyerPhone = _farmerPhone;
      } else if (user == 'farmer' && _farmerPhone == '+919876543210' && _buyerPhone != '+919988776655') {
        _farmerPhone = _buyerPhone;
      }
    }

    notifyListeners();
    _persistSession();
  }

  /// Logs in a user by phone number and syncs with Cloud Firestore `/users/{phone}`.
  /// Returns `true` if this is a brand-new user who needs quick profile setup,
  /// or `false` if an existing cloud profile was found and loaded.
  Future<bool> loginWithPhone(String rawPhone, String role) async {
    final canonicalPhone = ContactHelper.formatIndianPhone(rawPhone);
    final digits10 = ContactHelper.normalizePhone10(rawPhone);

    _selectedUser = role;
    _isLoggedIn = true;

    if (role == 'farmer') {
      _farmerPhone = canonicalPhone;
    } else {
      _buyerPhone = canonicalPhone;
    }
    notifyListeners();

    bool isNewUser = true;
    try {
      // Look up canonical E.164 key first, then spaced legacy key if any
      Map<String, dynamic>? cloudProfile = await _firebaseService.getUserProfile(canonicalPhone);
      cloudProfile ??= await _firebaseService.getUserProfile('+91 $digits10');

      if (cloudProfile != null) {
        isNewUser = false;
        if (role == 'farmer') {
          _farmerName = cloudProfile['name']?.toString() ?? _farmerName;
          _farmerLocation = cloudProfile['location']?.toString() ?? _farmerLocation;
          _fruitsId = cloudProfile['fruitsId']?.toString() ?? _fruitsId;
          _isKisanVerified = cloudProfile['isKisanVerified'] == true || _fruitsId.isNotEmpty;
        } else {
          _buyerName = cloudProfile['name']?.toString() ?? _buyerName;
          _buyerBusiness = cloudProfile['business']?.toString() ?? _buyerBusiness;
          _buyerLocation = cloudProfile['location']?.toString() ?? _buyerLocation;
          _apmcLicense = cloudProfile['apmcLicense']?.toString() ?? _apmcLicense;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error syncing login profile with Firestore: $e');
    }

    await _persistSession();
    return isNewUser;
  }

  /// Saves a new user's name and location during first-time registration.
  Future<void> completeOnboarding({
    required String name,
    required String location,
    String? business,
  }) async {
    _isLoggedIn = true;
    if (_selectedUser == 'farmer') {
      await updateFarmerProfile(
        name: name,
        location: location,
        fruitsId: '',
      );
    } else {
      await updateBuyerProfile(
        name: name,
        location: location,
        business: (business != null && business.isNotEmpty) ? business : 'Produce Buyer',
        license: '',
      );
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefIsLoggedIn, false);
    } catch (e) {
      debugPrint('AppProvider: Error during logout: $e');
    }
  }

  Future<void> updateFarmerProfile({
    String? name,
    String? phone,
    String? location,
    String? fruitsId,
  }) async {
    if (name != null && name.isNotEmpty) _farmerName = name;
    if (phone != null && phone.isNotEmpty) {
      _farmerPhone = ContactHelper.formatIndianPhone(phone);
    }
    if (location != null && location.isNotEmpty) _farmerLocation = location;
    if (fruitsId != null) {
      _fruitsId = fruitsId;
      _isKisanVerified = fruitsId.isNotEmpty;
    }
    notifyListeners();
    await _persistSession();

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

  Future<void> updateBuyerProfile({
    String? name,
    String? phone,
    String? business,
    String? location,
    String? license,
  }) async {
    if (name != null && name.isNotEmpty) _buyerName = name;
    if (phone != null && phone.isNotEmpty) {
      _buyerPhone = ContactHelper.formatIndianPhone(phone);
    }
    if (business != null && business.isNotEmpty) _buyerBusiness = business;
    if (location != null && location.isNotEmpty) _buyerLocation = location;
    if (license != null) _apmcLicense = license;
    notifyListeners();
    await _persistSession();

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
