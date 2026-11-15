import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/components/role_card.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/provider/app_provider.dart';
import 'package:raitabazzar/screens/login_screen.dart';
import 'package:raitabazzar/utils/constant.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Language Selector Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.eco_rounded, color: AppConstants.primaryGreen, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'RaithaBazzar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  // Compact Language Switcher Pills
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLangChip(context, 'English', 'EN', appProvider),
                        _buildLangChip(context, 'Kannada', 'ಕನ್ನಡ', appProvider),
                        _buildLangChip(context, 'Hindi', 'हिंदी', appProvider),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Hero Illustration & Greeting
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: const BoxDecoration(
                    color: AppConstants.lightGreenBg,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/images/farmer.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                loc.appTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.deepGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.buySellProduce,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 24),

              // Role Selection Header
              Text(
                loc.whoYouAre,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Visual Role Card: Farmer
              RoleCard(
                icon: Icons.agriculture_rounded,
                title: loc.farmerTitle,
                subtitle: loc.farmerSubtitle,
                isSelected: appProvider.selectedUser == AppConstants.roleFarmer,
                onTap: () => appProvider.setUser(AppConstants.roleFarmer),
              ),

              const SizedBox(height: 10),

              // Visual Role Card: Buyer
              RoleCard(
                icon: Icons.storefront_rounded,
                title: loc.buyerTitle,
                subtitle: loc.buyerSubtitle,
                isSelected: appProvider.selectedUser == AppConstants.roleBuyer,
                onTap: () => appProvider.setUser(AppConstants.roleBuyer),
              ),

              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryGreen,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        loc.continueButton,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangChip(
    BuildContext context,
    String langKey,
    String label,
    AppProvider provider,
  ) {
    final isSelected = provider.selectedLanguage == langKey ||
        (langKey == 'Hindi' && provider.selectedLanguage == 'हिंदी');

    return GestureDetector(
      onTap: () => provider.setLanguage(langKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}


