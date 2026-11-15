import 'package:flutter/material.dart';
import 'package:raitabazzar/models/buyer_offer.dart';
import 'package:raitabazzar/utils/constant.dart';

class BuyerOrderItem extends StatelessWidget {
  final BuyerOffer offer;

  const BuyerOrderItem({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final isAccepted = offer.status == 'Accepted';

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
              Text(offer.cropName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAccepted
                      ? Colors.green.shade50
                      : offer.status == 'Declined'
                          ? Colors.red.shade50
                          : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  offer.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isAccepted
                        ? AppConstants.deepGreen
                        : offer.status == 'Declined'
                            ? Colors.red
                            : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Your Bid: ${offer.formattedOfferedPrice} • ${offer.formattedRequestedQuantity}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            'Status: ${isAccepted ? 'Accepted! Farmer will contact for dispatch.' : offer.status == 'Declined' ? 'Farmer declined bid.' : 'Awaiting farmer response.'}',
            style: TextStyle(fontSize: 12, color: isAccepted ? AppConstants.deepGreen : Colors.grey),
          ),
        ],
      ),
    );
  }
}
