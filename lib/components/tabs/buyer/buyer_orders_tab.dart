import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/components/buyer_order_item.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/provider/listing_provider.dart';

class BuyerOrdersTab extends StatelessWidget {
  const BuyerOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final listingProvider = Provider.of<ListingProvider>(context);
    final myOffers = listingProvider.offers;

    return Scaffold(
      appBar: AppBar(title: Text(loc.navOrders)),
      body: myOffers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No bids or orders placed yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: myOffers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final offer = myOffers[index];
                return BuyerOrderItem(offer: offer);
              },
            ),
    );
  }
}