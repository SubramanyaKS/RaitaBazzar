import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/components/tabs/farmer/farmer_dashboard_tab.dart';
import 'package:raitabazzar/components/tabs/farmer/farmer_my_crops_tab.dart';
import 'package:raitabazzar/components/tabs/farmer/farmer_offer_tab.dart';
import 'package:raitabazzar/components/tabs/farmer/farmer_profile_tab.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/provider/listing_provider.dart';
import 'package:raitabazzar/screens/add_produce_screen.dart';
import 'package:raitabazzar/utils/constant.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final listingProvider = Provider.of<ListingProvider>(context);

    final pages = [
      const FarmerDashboardTab(),
      FarmerMyCropsTab(onSwitchToOffers: () {
        setState(() {
          _currentIndex = 2;
        });
      }),
      const FarmerOffersTab(),
      const FarmerProfileTab(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddProduceScreen()),
                );
              },
              backgroundColor: AppConstants.primaryGreen,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(loc.addProduce, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: AppConstants.primaryGreen),
            label: loc.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.agriculture_outlined),
            selectedIcon: const Icon(Icons.agriculture, color: AppConstants.primaryGreen),
            label: loc.navMyCrops,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: listingProvider.pendingOffersCount > 0,
              label: Text('${listingProvider.pendingOffersCount}'),
              child: const Icon(Icons.local_offer_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: listingProvider.pendingOffersCount > 0,
              label: Text('${listingProvider.pendingOffersCount}'),
              child: const Icon(Icons.local_offer, color: AppConstants.primaryGreen),
            ),
            label: loc.navOffers,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: AppConstants.primaryGreen),
            label: loc.navProfile,
          ),
        ],
      ),
    );
  }
}

 