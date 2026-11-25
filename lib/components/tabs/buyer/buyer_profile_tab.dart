import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/provider/app_provider.dart';
import 'package:raitabazzar/provider/theme_provider.dart';
import 'package:raitabazzar/screens/farmer_home_screen.dart';
import 'package:raitabazzar/screens/welcome_screen.dart';
import 'package:raitabazzar/utils/constant.dart';
import 'package:raitabazzar/utils/contact_helper.dart';

class BuyerProfileTab extends StatelessWidget {
  const BuyerProfileTab({super.key});

  void _showEditProfileDialog(BuildContext context, AppProvider appProvider) {
    final nameCtrl = TextEditingController(text: appProvider.buyerName);
    final phoneCtrl = TextEditingController(text: appProvider.buyerPhone);
    final businessCtrl = TextEditingController(text: appProvider.buyerBusiness);
    final locCtrl = TextEditingController(text: appProvider.buyerLocation);
    final licenseCtrl = TextEditingController(text: appProvider.apmcLicense);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Buyer Profile / ವ್ಯಾಪಾರಿ ವಿವರಗಳು', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Trade / Business Name', prefixIcon: Icon(Icons.storefront)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Contact Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: businessCtrl,
                decoration: const InputDecoration(labelText: 'Business Type (Wholesale/Retail)', prefixIcon: Icon(Icons.business_center_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locCtrl,
                decoration: const InputDecoration(labelText: 'Delivery Hub / Market Location', prefixIcon: Icon(Icons.location_on_outlined)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: licenseCtrl,
                decoration: const InputDecoration(labelText: 'APMC Trader License / GST (Optional)', prefixIcon: Icon(Icons.verified_outlined)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              appProvider.updateBuyerProfile(
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                business: businessCtrl.text.trim(),
                location: locCtrl.text.trim(),
                license: licenseCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Buyer profile updated successfully!'), backgroundColor: AppConstants.primaryGreen),
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
            Icon(Icons.agriculture, color: AppConstants.primaryGreen, size: 26),
            SizedBox(width: 8),
            Text('Switch to Farmer Mode?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'You will be switched to the Farmer Dashboard where you can take crop photos, list harvests, track APMC prices, and accept buyer offers.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Stay as Buyer')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              appProvider.setUser('farmer');
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const FarmerHomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryGreen),
            child: const Text('Switch to Farmer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          // Buyer Profile Header Card
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
                      child: const Icon(Icons.storefront, size: 40, color: AppConstants.primaryGreen),
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
                        appProvider.buyerName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appProvider.buyerBusiness,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppConstants.primaryGreen),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              appProvider.buyerLocation,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (appProvider.apmcLicense.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppConstants.lightGreenBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppConstants.lightGreen),
                          ),
                          child: Text(
                            'APMC: ${appProvider.apmcLicense}',
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

          // Instant Role Switcher Banner (To Farmer Mode)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.teal.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.agriculture, color: AppConstants.primaryGreen, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Are you also a farmer?',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Switch to Farmer mode to list and sell crops',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showRoleSwitchConfirmation(context, appProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Farmer Mode'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Preferences & Display
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
                  title: const Text('New Crop Arrival Alerts'),
                  subtitle: const Text('Get notified when nearby farmers list produce'),
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

          // Procurement & Trade Desk Support
          _buildSectionHeader('Trade Support & Procurement / ವ್ಯಾಪಾರ ಸಹಾಯ'),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.headset_mic_outlined, color: AppConstants.primaryGreen),
                  title: const Text('Bulk Procurement Desk'),
                  subtitle: const Text('Help sourcing large volumes (> 10 Tonnes)'),
                  trailing: const Icon(Icons.call, color: AppConstants.primaryGreen, size: 20),
                  onTap: () => ContactHelper.makePhoneCall(context, '18001801551'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
                  title: const Text('Buyer Trade Desk on WhatsApp'),
                  subtitle: const Text('Resolve transaction or logistics queries'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => ContactHelper.openWhatsApp(
                    context: context,
                    phoneNumber: '919876543210',
                    cropName: 'Buyer Support',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Logout Action
          OutlinedButton.icon(
            onPressed: () async {
              await appProvider.logout();
              if (!context.mounted) return;
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
              'RaitaBazzar v1.2.0 • Direct From Farm To Fork',
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
