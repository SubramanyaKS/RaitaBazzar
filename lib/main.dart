import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/config/app_config.dart';
import 'package:raitabazzar/firebase_options.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/provider/app_provider.dart';
import 'package:raitabazzar/provider/listing_provider.dart';
import 'package:raitabazzar/provider/theme_provider.dart';
import 'package:raitabazzar/screens/buyer_home_screen.dart';
import 'package:raitabazzar/screens/farmer_home_screen.dart';
import 'package:raitabazzar/screens/welcome_screen.dart';
import 'package:raitabazzar/utils/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  final appProvider = AppProvider();
  final themeProvider = ThemeProvider();
  await Future.wait([
    appProvider.loadSession(),
    themeProvider.loadTheme(),
  ]);

  runApp(MyApp(appProvider: appProvider, themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final AppProvider? appProvider;
  final ThemeProvider? themeProvider;

  const MyApp({super.key, this.appProvider, this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        if (appProvider != null)
          ChangeNotifierProvider<AppProvider>.value(value: appProvider!)
        else
          ChangeNotifierProvider(create: (_) => AppProvider()),
        if (themeProvider != null)
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider!)
        else
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
      ],
      child: Consumer2<AppProvider, ThemeProvider>(
        builder: (context, appLang, themeProv, _) {
          Widget startScreen = const WelcomeScreen();
          if (appLang.isLoggedIn) {
            startScreen = appLang.selectedUser == AppConstants.roleBuyer
                ? const BuyerHomeScreen()
                : const FarmerHomeScreen();
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'RaitaBazzar',
            locale: appLang.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: themeProv.lightTheme,
            darkTheme: themeProv.darkTheme,
            themeMode: themeProv.themeMode,
            home: startScreen,
          );
        },
      ),
    );
  }
}
