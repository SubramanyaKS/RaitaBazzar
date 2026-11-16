import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/provider/app_provider.dart';
import 'package:raitabazzar/provider/theme_provider.dart';
import 'package:raitabazzar/screens/buyer_home_screen.dart';
import 'package:raitabazzar/screens/welcome_screen.dart';
import 'package:raitabazzar/utils/constant.dart';
import 'package:raitabazzar/utils/contact_helper.dart';

class FarmerProfileTab extends StatelessWidget {
  const FarmerProfileTab({super.key});

  void _showEditProfileDialog(BuildContext context, AppProvider appProvider) {
    final nameCtrl = TextEditingController(text: appProvider.farmerName);
    final phoneCtrl = TextEditingController(text: appProvider.farmerPhone);
    final locCtrl = TextEditingController(text: appProvider.farmerLocation);
    final fruitsCtrl = TextEditingController(text: appProvider.fruitsId);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Farmer Profile / ವಿವರಗಳನ್ನು ನವೀಕರಿಸಿ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Farmer Name / ಹೆಸರು', prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone Number / ಮೊಬೈಲ್', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locCtrl,
                decoration: const InputDecoration(labelText: 'Farm Location / ಊರು, ಜಿಲ್ಲೆ', prefixIcon: Icon(Icons.location_on_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: fruitsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Karnataka FRUITS ID / PM-Kisan ID',
                  prefixIcon: Icon(Icons.verified_outlined),
                  hintText: 'e.g. FID-KA-2024-XXXX',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              appProvider.updateFarmerProfile(
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                location: locCtrl.text.trim(),
                fruitsId: fruitsCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Profile updated successfully!'), backgroundColor: AppConstants.primaryGreen),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRoleSwitchConfirmation(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.storefront, color: AppConstants.primaryGreen, size: 26),
            SizedBox(width: 8),
            Text('Switch to Buyer Mode?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'You will be switched to the Buyer Marketplace where you can browse local harvests, compare prices, and make offers directly to farmers.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Stay as Farmer')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              appProvider.setUser('buyer');
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const BuyerHomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryGreen),
            child: const Text('Switch to Buyer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Language / ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        children: [
          _buildLanguageOption(context, provider, 'English', 'English (English)'),
          _buildLanguageOption(context, provider, 'Kannada', 'ಕನ್ನಡ (Kannada)'),
          _buildLanguageOption(context, provider, 'Hindi', 'हिंदी (Hindi)'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, AppProvider provider, String langKey, String display) {
    final isSelected = provider.selectedLanguage == langKey;
    return SimpleDialogOption(
      onPressed: () {
        provider.setLanguage(langKey);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(display, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            if (isSelected) const Icon(Icons.check, color: AppConstants.primaryGreen),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.navProfile, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () => _showEditProfileDialog(context, appProvider),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Farmer Profile Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppConstants.lightGreenBg,
                      child: const Icon(Icons.agriculture, size: 40, color: AppConstants.primaryGreen),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppConstants.primaryGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.verified, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appProvider.farmerName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appProvider.farmerPhone,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppConstants.primaryGreen),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              appProvider.farmerLocation,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (appProvider.isKisanVerified) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppConstants.lightGreenBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppConstants.lightGreen),
                          ),
                          child: Text(
                            'FRUITS: ${appProvider.fruitsId}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Instant Role Switcher Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.amber.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.swap_horiz, color: Colors.orange.shade800, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Want to buy produce?',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Switch to Buyer mode to explore harvests',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showRoleSwitchConfirmation(context, appProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Buyer Mode'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Settings & Preferences Card
          _buildSectionHeader('Preferences & Display / ಸೆಟ್ಟಿಂಗ್ಸ್'),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: AppConstants.primaryGreen),
                  title: Text(loc.selectLanguage),
                  subtitle: Text(appProvider.selectedLanguage, style: const TextStyle(color: AppConstants.deepGreen, fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _showLanguageDialog(context, appProvider),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined, color: AppConstants.primaryGreen),
                  title: const Text('Dark Mode / ಡಾರ್ಕ್ ಮೋಡ್'),
                  value: themeProvider.isDarkMode,
                  activeThumbColor: AppConstants.primaryGreen,
                  onChanged: (val) => themeProvider.toggleTheme(val),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined, color: AppConstants.primaryGreen),
                  title: const Text('Daily Mandi Rate Alerts'),
                  subtitle: const Text('Get morning price updates for Mandya'),
                  trailing: Switch(
                    value: true,
                    activeThumbColor: AppConstants.primaryGreen,
                    onChanged: (val) {},
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Kisan Helplines & Direct Support
          _buildSectionHeader('Farmer Helplines & Support / ಸಹಾಯವಾಣಿ'),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone_in_talk, color: Colors.green),
                  title: const Text('Kisan Call Center (Toll Free)'),
                  subtitle: const Text('1800-180-1551 (6 AM - 10 PM)'),
                  trailing: const Icon(Icons.call, color: AppConstants.primaryGreen, size: 20),
                  onTap: () => ContactHelper.makePhoneCall(context, '18001801551'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.support_agent, color: AppConstants.primaryGreen),
                  title: const Text('RaitaBazzar Farmer Support'),
                  subtitle: const Text('Direct assistance on WhatsApp'),
                  trailing: const Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
                  onTap: () => ContactHelper.openWhatsApp(
                    context: context,
                    phoneNumber: '919876543210',
                    cropName: 'Support',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Logout Action
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Logout / ಲಾಗೌಟ್', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 16),

          // Version Footer
          Center(
            child: Text(
              'RaitaBazzar v1.2.0 • Made with ❤️ for Karnataka Farmers',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}
