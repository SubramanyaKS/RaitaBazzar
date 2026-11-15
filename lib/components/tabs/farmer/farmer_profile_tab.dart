import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/provider/app_provider.dart';
import 'package:raitabazzar/screens/welcome_screen.dart';
import 'package:raitabazzar/utils/constant.dart';

class FarmerProfileTab extends StatelessWidget {
  const FarmerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.navProfile)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppConstants.lightGreenBg,
              child: const Icon(Icons.person, size: 48, color: AppConstants.primaryGreen),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Basavaraj Gowda',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: Text(
              '+91 98765 43210 • Mandya',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language, color: AppConstants.primaryGreen),
            title: Text(loc.selectLanguage),
            subtitle: Text(appProvider.selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showLanguageDialog(context, appProvider);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppConstants.primaryGreen),
            title: const Text('Kisan Helpline / Help Center'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
 void _showLanguageDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Select Language / ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              provider.setLanguage('English');
              Navigator.pop(context);
            },
            child: const Text('English', style: TextStyle(fontSize: 16)),
          ),
          SimpleDialogOption(
            onPressed: () {
              provider.setLanguage('Kannada');
              Navigator.pop(context);
            },
            child: const Text('ಕನ್ನಡ (Kannada)', style: TextStyle(fontSize: 16)),
          ),
          SimpleDialogOption(
            onPressed: () {
              provider.setLanguage('Hindi');
              Navigator.pop(context);
            },
            child: const Text('हिंदी (Hindi)', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
