import 'package:flutter_test/flutter_test.dart';
import 'package:raitabazzar/provider/app_provider.dart';
import 'package:raitabazzar/provider/listing_provider.dart';
import 'package:raitabazzar/provider/theme_provider.dart';
import 'package:raitabazzar/utils/contact_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phone Normalization Tests', () {
    test('normalizePhone10 handles +91, spaces, and 10-digit formats consistently', () {
      expect(ContactHelper.normalizePhone10('+91 98765 43210'), equals('9876543210'));
      expect(ContactHelper.normalizePhone10('+919876543210'), equals('9876543210'));
      expect(ContactHelper.normalizePhone10('919876543210'), equals('9876543210'));
      expect(ContactHelper.normalizePhone10('9876543210'), equals('9876543210'));
    });

    test('formatIndianPhone produces canonical E.164 format', () {
      expect(ContactHelper.formatIndianPhone('9876543210'), equals('+919876543210'));
      expect(ContactHelper.formatIndianPhone('+91 98765 43210'), equals('+919876543210'));
    });
  });

  group('Session & Theme Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('AppProvider persists login, role, language, and onboarding across restarts', () async {
      final provider1 = AppProvider();
      provider1.setLanguage('Kannada');
      await provider1.loginWithPhone('9900112233', 'farmer');
      await provider1.completeOnboarding(name: 'Mahesh Gowda', location: 'Kolar, Karnataka');

      // Simulate app restart with a fresh AppProvider instance
      final provider2 = AppProvider();
      await provider2.loadSession();

      expect(provider2.isLoggedIn, isTrue);
      expect(provider2.selectedUser, equals('farmer'));
      expect(provider2.selectedLanguage, equals('Kannada'));
      expect(provider2.locale.languageCode, equals('kn'));
      expect(provider2.farmerName, equals('Mahesh Gowda'));
      expect(provider2.farmerPhone, equals('+919900112233'));
      expect(provider2.farmerLocation, equals('Kolar, Karnataka'));

      // Logout clears isLoggedIn but keeps preferred language
      await provider2.logout();
      final provider3 = AppProvider();
      await provider3.loadSession();
      expect(provider3.isLoggedIn, isFalse);
      expect(provider3.selectedLanguage, equals('Kannada'));
    });

    test('ThemeProvider persists dark mode preference', () async {
      final theme1 = ThemeProvider();
      await theme1.toggleTheme(true);

      final theme2 = ThemeProvider();
      await theme2.loadTheme();
      expect(theme2.isDarkMode, isTrue);
    });
  });

  group('User-Scoped Data Filtering Tests', () {
    test('ListingProvider isolates farmer listings and offers by phone number', () {
      final provider = ListingProvider();

      // Basavaraj (+919876543210) owns crop_1 and crop_4 in seed data
      final basavarajCrops = provider.getListingsForFarmer('+91 98765 43210');
      expect(basavarajCrops.length, equals(2));
      expect(basavarajCrops.every((c) => c.farmerPhone.contains('9876543210')), isTrue);

      // Basavaraj should only see offer_1 (for crop_1), not offer_2 (for crop_2 owned by Nanjunde)
      final basavarajOffers = provider.getOffersForFarmer('9876543210');
      expect(basavarajOffers.length, equals(1));
      expect(basavarajOffers.first.listingId, equals('crop_1'));

      // Buyer Ramesh Wholesale Mart (+919886011223) only sees their own bid (offer_1)
      final buyerOffers = provider.getOffersForBuyer('9886011223');
      expect(buyerOffers.length, equals(1));
      expect(buyerOffers.first.id, equals('offer_1'));

      // A brand new farmer with no crops sees 0 listings and 0 offers
      expect(provider.getListingsForFarmer('9000000001'), isEmpty);
      expect(provider.getOffersForFarmer('9000000001'), isEmpty);
    });
  });
}
