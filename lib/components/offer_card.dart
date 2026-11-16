import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/models/buyer_offer.dart';
import 'package:raitabazzar/provider/listing_provider.dart';
import 'package:raitabazzar/utils/constant.dart';
import 'package:raitabazzar/utils/contact_helper.dart';

class OfferCard extends StatelessWidget {
  final BuyerOffer offer;

  const OfferCard({super.key, required this.offer});

  void _showDealAgreementDialog(BuildContext context) {
    final double totalAmount = offer.offeredPrice * offer.requestedQuantity;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.verified, color: AppConstants.primaryGreen, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Deal Confirmed / ಒಪ್ಪಂದ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppConstants.lightGreenBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.lightGreen),
                ),
                child: Column(
                  children: [
                    const Text('Total Agreed Payout', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.deepGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildReceiptRow('Buyer', offer.buyerName),
              _buildReceiptRow('Phone', offer.buyerPhone),
              _buildReceiptRow('Crop', offer.cropName),
              _buildReceiptRow('Quantity', '${offer.requestedQuantity} ${offer.unit}'),
              _buildReceiptRow('Rate', '₹${offer.offeredPrice} / ${offer.unit}'),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // WhatsApp Share & Direct Call Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ContactHelper.makePhoneCall(context, offer.buyerPhone);
                      },
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text('Call'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ContactHelper.shareDealAgreement(
                          context: context,
                          buyerPhone: offer.buyerPhone,
                          buyerName: offer.buyerName,
                          cropName: offer.cropName,
                          quantity: offer.requestedQuantity,
                          unit: offer.unit,
                          price: offer.offeredPrice,
                          totalAmount: totalAmount,
                        );
                      },
                      icon: const Icon(Icons.chat, size: 18, color: Colors.white),
                      label: const Text('WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);
    final isPending = offer.status == 'Pending';
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
              Text(
                offer.buyerName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAccepted
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
                      _showDealAgreementDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen,
                    ),
                    child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ] else if (isAccepted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showDealAgreementDialog(context),
                icon: const Icon(Icons.receipt_long, size: 18),
                label: const Text('View Deal Agreement & WhatsApp Receipt'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConstants.primaryGreen,
                  side: const BorderSide(color: AppConstants.primaryGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
