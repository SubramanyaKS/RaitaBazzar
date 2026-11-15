import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/models/buyer_offer.dart';
import 'package:raitabazzar/provider/listing_provider.dart';
import 'package:raitabazzar/utils/constant.dart';

class OfferCard extends StatelessWidget {
  final BuyerOffer offer;

  const OfferCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);
    final isPending = offer.status == 'Pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                offer.buyerName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: offer.status == 'Accepted'
                      ? Colors.green.shade50
                      : offer.status == 'Declined'
                          ? Colors.red.shade50
                          : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  offer.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: offer.status == 'Accepted'
                        ? AppConstants.deepGreen
                        : offer.status == 'Declined'
                            ? Colors.red
                            : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          Text(offer.buyerLocation, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Text('Crop: ${offer.cropName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('Quantity: ${offer.formattedRequestedQuantity}', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 2),
          Text(
            'Bid Price: ${offer.formattedOfferedPrice}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryGreen,
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      listingProvider.respondToOffer(offer.id, 'Declined');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Offer declined')),
                      );
                    },
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      listingProvider.respondToOffer(offer.id, 'Accepted');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎉 Offer accepted! Connect with buyer to arrange pickup.'),
                          backgroundColor: AppConstants.primaryGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen,
                    ),
                    child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
