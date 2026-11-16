import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/components/crop_thumbnail.dart';
import 'package:raitabazzar/models/crop_listing.dart';
import 'package:raitabazzar/models/mandi_rate.dart';
import 'package:raitabazzar/provider/listing_provider.dart';
import 'package:raitabazzar/services/mandi_service.dart';
import 'package:raitabazzar/utils/constant.dart';

class FarmerCropItem extends StatelessWidget {
  final CropListing listing;
  final VoidCallback? onNavigateToOffers;

  const FarmerCropItem({
    super.key,
    required this.listing,
    this.onNavigateToOffers,
  });

  void _showEditSheet(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);
    final priceController = TextEditingController(text: listing.pricePerUnit.toStringAsFixed(0));
    final qtyController = TextEditingController(text: listing.quantity.toStringAsFixed(0));
    final MandiRate? benchmark = MandiService().findBenchmarkForCrop(listing.cropName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit ${listing.cropName}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Mandi Benchmark Advisor Hint
                  if (benchmark != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.lightGreenBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppConstants.lightGreen),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insights, color: AppConstants.primaryGreen, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'APMC Benchmark: ${benchmark.market}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppConstants.deepGreen),
                                ),
                                Text(
                                  'Modal Avg: ${benchmark.formattedModalPrice} (Range: ${benchmark.formattedRange})',
                                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                priceController.text = benchmark.modalPrice.toStringAsFixed(0);
                              });
                            },
                            child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryGreen)),
                          ),
                        ],
                      ),
                    ),

                  // Expected Price Field
                  const Text('Price per Unit *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      suffixText: '/ ${listing.unit}',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Available Quantity Field
                  const Text('Available Quantity *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: qtyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    decoration: InputDecoration(
                      suffixText: listing.unit,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Save Changes Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final newPrice = double.tryParse(priceController.text.trim()) ?? listing.pricePerUnit;
                        final newQty = double.tryParse(qtyController.text.trim()) ?? listing.quantity;

                        listingProvider.updateListingDetails(
                          listing.id,
                          price: newPrice,
                          quantity: newQty,
                        );

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Produce details updated successfully!'),
                            backgroundColor: AppConstants.primaryGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Listing?'),
        content: Text('Are you sure you want to remove "${listing.cropName}" from the marketplace?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              listingProvider.deleteListing(listing.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ "${listing.cropName}" removed from listings.'),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);
    final isSold = listing.status == 'Sold Out';
    final offers = listingProvider.getOffersForCrop(listing.id);
    final pendingOffers = offers.where((o) => o.status == 'Pending').toList();
    final double totalLotValue = listing.pricePerUnit * listing.quantity;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Thumbnail + Title + Status Pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CropThumbnail(listing: listing, size: 60, radius: 12),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              listing.cropName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSold ? Colors.grey.shade200 : AppConstants.lightGreenBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSold ? Colors.grey.shade400 : AppConstants.lightGreen,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSold ? Icons.block : Icons.check_circle,
                                  size: 12,
                                  color: isSold ? Colors.grey.shade700 : AppConstants.deepGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  listing.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSold ? Colors.grey.shade700 : AppConstants.deepGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Category: ${listing.category}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Harvest: ${listing.harvestDate}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Price & Quantity Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Unit Price', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      listing.formattedPrice,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppConstants.deepGreen),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Stock Quantity', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      listing.formattedQuantity,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Lot Value', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      '₹${totalLotValue.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppConstants.warmOrange),
                    ),
                  ],
                ),
              ],
            ),

            // Offers Banner (if any)
            if (offers.isNotEmpty) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: onNavigateToOffers,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: pendingOffers.isNotEmpty ? Colors.orange.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: pendingOffers.isNotEmpty ? Colors.orange.shade200 : Colors.blue.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_offer,
                        size: 16,
                        color: pendingOffers.isNotEmpty ? Colors.orange.shade800 : Colors.blue.shade800,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pendingOffers.isNotEmpty
                              ? '📩 ${pendingOffers.length} Pending Offer(s) from Buyers'
                              : '✅ ${offers.length} Offer(s) recorded',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: pendingOffers.isNotEmpty ? Colors.orange.shade900 : Colors.blue.shade900,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: pendingOffers.isNotEmpty ? Colors.orange.shade800 : Colors.blue.shade800,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Quick Actions Row
            Row(
              children: [
                // Quick Edit Price & Qty
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditSheet(context),
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Edit Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.primaryGreen,
                      side: const BorderSide(color: AppConstants.primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Toggle Active / Sold Out Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      listingProvider.toggleListingStatus(listing.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isSold ? 'Produce re-listed as Active!' : 'Produce marked as Sold Out!'),
                          backgroundColor: isSold ? AppConstants.primaryGreen : Colors.grey.shade800,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(isSold ? Icons.replay : Icons.check_circle_outline, size: 18),
                    label: Text(isSold ? 'Re-list' : 'Mark Sold'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSold ? AppConstants.primaryGreen : Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Delete Button
                IconButton(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Delete Crop Listing',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
