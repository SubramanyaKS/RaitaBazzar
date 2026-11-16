import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/components/buyer_produce_card.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/models/buyer_offer.dart';
import 'package:raitabazzar/models/crop_listing.dart';
import 'package:raitabazzar/provider/app_provider.dart';
import 'package:raitabazzar/provider/listing_provider.dart';
import 'package:raitabazzar/screens/mandi_rates_screen.dart';
import 'package:raitabazzar/utils/constant.dart';
import 'package:raitabazzar/utils/contact_helper.dart';

class BuyerMarketplaceTab extends StatefulWidget {
  const BuyerMarketplaceTab({super.key});

  @override
  State<BuyerMarketplaceTab> createState() => BuyerMarketplaceTabState();
}

class BuyerMarketplaceTabState extends State<BuyerMarketplaceTab> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  int? _maxDistanceKm;

  final List<Map<String, String>> _categories = [
    {'name': 'All', 'icon': '🌾'},
    {'name': 'Vegetables', 'icon': '🥔'},
    {'name': 'Fruits', 'icon': '🍎'},
    {'name': 'Grains', 'icon': '🌾'},
    {'name': 'Pulses', 'icon': '🌰'},
    {'name': 'Spices', 'icon': '🌶️'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDistanceFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter by Distance / ಅಂತರ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (_maxDistanceKm != null)
                    TextButton(
                      onPressed: () {
                        setState(() => _maxDistanceKm = null);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Reset'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDistanceChip(ctx, null, 'All Karnataka'),
                  _buildDistanceChip(ctx, 15, 'Within 15 km'),
                  _buildDistanceChip(ctx, 30, 'Within 30 km'),
                  _buildDistanceChip(ctx, 50, 'Within 50 km'),
                  _buildDistanceChip(ctx, 100, 'Within 100 km'),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDistanceChip(BuildContext ctx, int? distance, String label) {
    final isSelected = _maxDistanceKm == distance;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppConstants.lightGreenBg,
      labelStyle: TextStyle(
        color: isSelected ? AppConstants.primaryGreen : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        setState(() => _maxDistanceKm = distance);
        Navigator.pop(ctx);
      },
    );
  }

  void _showOfferBottomSheet(BuildContext context, CropListing listing) {
    final priceController = TextEditingController(text: '${listing.pricePerUnit}');
    final qtyController = TextEditingController(text: '${listing.quantity}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                  Expanded(
                    child: Text(
                      'Make Offer: ${listing.cropName}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                'Listed by ${listing.farmerName} • Listed at ${listing.formattedPrice}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text('Your Bid Price (₹) *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
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
              const Text('Quantity Needed *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final double price = double.tryParse(priceController.text.trim()) ?? 0;
                    final double qty = double.tryParse(qtyController.text.trim()) ?? 0;

                    if (price <= 0 || qty <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter valid price and quantity')),
                      );
                      return;
                    }

                    final appProvider = Provider.of<AppProvider>(context, listen: false);

                    final offer = BuyerOffer(
                      id: 'offer_${DateTime.now().millisecondsSinceEpoch}',
                      listingId: listing.id,
                      buyerName: appProvider.buyerName,
                      buyerPhone: appProvider.buyerPhone,
                      buyerLocation: appProvider.buyerLocation,
                      cropName: listing.cropName,
                      offeredPrice: price,
                      unit: listing.unit,
                      requestedQuantity: qty,
                    );

                    Provider.of<ListingProvider>(context, listen: false).submitBuyerOffer(offer);
                    Navigator.pop(ctx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Offer of ₹$price/${listing.unit} sent to ${listing.farmerName}!'),
                        backgroundColor: AppConstants.primaryGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Submit Offer to Farmer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final listingProvider = Provider.of<ListingProvider>(context);
    final selectedCategory = _categories[_selectedCategoryIndex]['name']!;
    final listings = listingProvider.filterMarketListings(
      query: _searchQuery,
      category: selectedCategory,
      maxDistanceKm: _maxDistanceKm,
    );

    final distanceFilterLabel = _maxDistanceKm != null ? '< $_maxDistanceKm km' : 'All Karnataka';

    return SafeArea(
      child: Column(
        children: [
          // Top Location Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppConstants.primaryGreen, size: 20),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Marketplace Reach',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          distanceFilterLabel,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.trending_up, color: AppConstants.primaryGreen),
                      tooltip: 'APMC Mandi Rates',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MandiRatesScreen()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Badge(
                        isLabelVisible: _maxDistanceKm != null,
                        label: Text('$_maxDistanceKm'),
                        child: const Icon(Icons.tune_rounded),
                      ),
                      tooltip: 'Filter by Distance',
                      onPressed: _showDistanceFilterSheet,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: SearchBar(
              controller: _searchController,
              hintText: loc.searchHint,
              leading: const Icon(Icons.search),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              trailing: [
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.mic, color: AppConstants.primaryGreen),
                    onPressed: () {},
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Horizontal Category Chips
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategoryIndex == index;

                return ChoiceChip(
                  avatar: Text(cat['icon']!),
                  label: Text(cat['name']!),
                  selected: isSelected,
                  selectedColor: AppConstants.lightGreenBg,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Marketplace Produce Feed
          Expanded(
            child: listings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.search_off_rounded, size: 54, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No crops found matching your search', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Try clearing filters or search another produce', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: listings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      return BuyerProduceCard(
                        listing: listing,
                        onCall: () {
                          ContactHelper.makePhoneCall(context, listing.farmerPhone);
                        },
                        onWhatsApp: () {
                          ContactHelper.openWhatsApp(
                            context: context,
                            phoneNumber: listing.farmerPhone,
                            cropName: listing.cropName,
                          );
                        },
                        onMakeOffer: () {
                          _showOfferBottomSheet(context, listing);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}