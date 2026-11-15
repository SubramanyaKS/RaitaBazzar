import 'package:flutter/material.dart';
import 'package:raitabazzar/components/tabs/buyer/buyer_marketplace_tab.dart';
import 'package:raitabazzar/components/tabs/buyer/buyer_orders_tab.dart';
import 'package:raitabazzar/components/tabs/buyer/buyer_profile_tab.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/utils/constant.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final pages = [
      const BuyerMarketplaceTab(),
      const BuyerOrdersTab(),
      const BuyerProfileTab(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront, color: AppConstants.primaryGreen),
            label: loc.navMarket,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_bag_outlined),
            selectedIcon: const Icon(Icons.shopping_bag, color: AppConstants.primaryGreen),
            label: loc.navOrders,
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