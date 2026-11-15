import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/components/crop_thumbnail.dart';
import 'package:raitabazzar/models/crop_listing.dart';
import 'package:raitabazzar/provider/listing_provider.dart';
import 'package:raitabazzar/utils/constant.dart';

class FarmerCropItem extends StatelessWidget {
  final CropListing listing;

  const FarmerCropItem({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);
    final isSold = listing.status == 'Sold Out';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CropThumbnail(listing: listing, size: 54, radius: 10),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.cropName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '${listing.formattedQuantity} • ${listing.harvestDate}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  listing.formattedPrice,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryGreen,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSold ? Colors.grey.shade100 : AppConstants.lightGreenBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                listing.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSold ? Colors.grey : AppConstants.deepGreen,
                ),
              ),
            ),
            onSelected: (val) {
              if (val == 'toggle') {
                listingProvider.toggleListingStatus(listing.id);
              } else if (val == 'delete') {
                listingProvider.deleteListing(listing.id);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'toggle',
                child: Text(isSold ? 'Mark as Active' : 'Mark as Sold Out'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Listing', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}