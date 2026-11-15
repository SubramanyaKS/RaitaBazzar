import 'package:flutter/material.dart';
import 'package:raitabazzar/components/crop_thumbnail.dart';
import 'package:raitabazzar/models/crop_listing.dart';
import 'package:raitabazzar/utils/constant.dart';

class BuyerProduceCard extends StatelessWidget {
  final CropListing listing;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onMakeOffer;

  const BuyerProduceCard({super.key, 
    required this.listing,
    required this.onCall,
    required this.onWhatsApp,
    required this.onMakeOffer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CropThumbnail(listing: listing, size: 64, radius: 12),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.cropName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (listing.description != null && listing.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              listing.description!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Farmer Info & Location Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_pin, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    listing.farmerName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.near_me_outlined, size: 14, color: AppConstants.primaryGreen),
                  const SizedBox(width: 4),
                  Text(
                    listing.location,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Middleman-Free Direct Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone, size: 16, color: AppConstants.primaryGreen),
                  label: const Text('Call', style: TextStyle(color: AppConstants.primaryGreen)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppConstants.primaryGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onWhatsApp,
                  icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white),
                  label: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onMakeOffer,
                  icon: const Icon(Icons.local_offer, size: 16, color: Colors.white),
                  label: const Text('Offer', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}