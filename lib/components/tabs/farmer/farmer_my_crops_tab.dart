import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/components/farmer_crop_item.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/provider/listing_provider.dart';
import 'package:raitabazzar/screens/add_produce_screen.dart';
import 'package:raitabazzar/utils/constant.dart';

class FarmerMyCropsTab extends StatefulWidget {
  final VoidCallback? onSwitchToOffers;
  const FarmerMyCropsTab({super.key, this.onSwitchToOffers});

  @override
  State<FarmerMyCropsTab> createState() => _FarmerMyCropsTabState();
}

class _FarmerMyCropsTabState extends State<FarmerMyCropsTab> {
  String _selectedFilter = 'All'; // 'All', 'Active', 'Sold Out'
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final listingProvider = Provider.of<ListingProvider>(context);
    final allListings = listingProvider.myFarmerListings;

    // Metric Calculations
    final activeCount = allListings.where((l) => l.status == 'Active').length;
    final soldCount = allListings.where((l) => l.status == 'Sold Out').length;
    final double totalInventoryValue = allListings
        .where((l) => l.status == 'Active')
        .fold(0.0, (sum, l) => sum + (l.pricePerUnit * l.quantity));

    // Filter by Tab and Search
    final filteredListings = allListings.where((l) {
      final matchesStatus = _selectedFilter == 'All' ||
          (_selectedFilter == 'Active' && l.status == 'Active') ||
          (_selectedFilter == 'Sold Out' && l.status == 'Sold Out');

      final matchesQuery = _searchQuery.isEmpty ||
          l.cropName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.category.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesStatus && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.myListings, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppConstants.primaryGreen, size: 26),
            tooltip: 'Add Produce',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddProduceScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Inventory Summary Card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppConstants.deepGreen, AppConstants.primaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryGreen.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🌾 Farm Inventory Value',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${allListings.length} Total Listed',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${totalInventoryValue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatPill('🟢 Active Stock', '$activeCount Crops', Colors.white),
                    Container(width: 1, height: 24, color: Colors.white24),
                    _buildStatPill('⚪ Sold Out', '$soldCount Crops', Colors.white70),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar & Filter Chips Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search my crops...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppConstants.primaryGreen),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.trim());
                  },
                ),
                const SizedBox(height: 10),

                // Status Filter Chips
                Row(
                  children: [
                    _buildFilterChip('All', allListings.length),
                    const SizedBox(width: 8),
                    _buildFilterChip('Active', activeCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('Sold Out', soldCount),
                  ],
                ),
              ],
            ),
          ),

          // Crops List
          Expanded(
            child: filteredListings.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 14),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No crops found matching "$_searchQuery"'
                                : 'No ${_selectedFilter.toLowerCase()} crops in your inventory',
                            style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AddProduceScreen()),
                              );
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Produce Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                    itemCount: filteredListings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final listing = filteredListings[index];
                      return FarmerCropItem(
                        listing: listing,
                        onNavigateToOffers: widget.onSwitchToOffers,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFilterChip(String filter, int count) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text('$filter ($count)'),
      selected: isSelected,
      selectedColor: AppConstants.lightGreenBg,
      checkmarkColor: AppConstants.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppConstants.primaryGreen : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (_) {
        setState(() => _selectedFilter = filter);
      },
    );
  }
}
