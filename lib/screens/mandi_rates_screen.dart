import 'package:flutter/material.dart';
import 'package:raitabazzar/config/app_config.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/models/mandi_rate.dart';
import 'package:raitabazzar/screens/add_produce_screen.dart';
import 'package:raitabazzar/services/mandi_service.dart';
import 'package:raitabazzar/utils/constant.dart';

class MandiRatesScreen extends StatefulWidget {
  final String? initialDistrict;
  const MandiRatesScreen({super.key, this.initialDistrict});

  @override
  State<MandiRatesScreen> createState() => _MandiRatesScreenState();
}

class _MandiRatesScreenState extends State<MandiRatesScreen> {
  final MandiService _mandiService = MandiService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedDistrict = 'All';
  List<MandiRate> _rates = [];
  bool _isLoading = true;

  final List<String> _districts = [
    'All',
    'Mandya',
    'Kolar',
    'Bangalore',
    'Mysuru',
    'Hubli',
    'Belagavi',
    'Ramanagara',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialDistrict != null && _districts.contains(widget.initialDistrict)) {
      _selectedDistrict = widget.initialDistrict!;
    }
    _loadRates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRates() async {
    setState(() => _isLoading = true);
    final rates = await _mandiService.fetchRates(
      district: _selectedDistrict,
      commodity: _searchController.text.trim(),
    );
    if (mounted) {
      setState(() {
        _rates = rates;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.mandiRates,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Rates',
            onPressed: _loadRates,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Backend status header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search crop (Tomato, ಈರುಳ್ಳಿ, आलू)...',
                    prefixIcon: const Icon(Icons.search, color: AppConstants.primaryGreen),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _loadRates();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _loadRates(),
                  textInputAction: TextInputAction.search,
                ),
                const SizedBox(height: 10),

                // District Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _districts.map((district) {
                      final isSelected = _selectedDistrict == district;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(district),
                          selected: isSelected,
                          selectedColor: AppConstants.lightGreenBg,
                          checkmarkColor: AppConstants.primaryGreen,
                          labelStyle: TextStyle(
                            color: isSelected ? AppConstants.primaryGreen : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedDistrict = district;
                            });
                            _loadRates();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Source indicator bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      AppConfig.hasBackendUrl ? Icons.cloud_done : Icons.storage_rounded,
                      size: 14,
                      color: AppConfig.hasBackendUrl ? Colors.green : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppConfig.hasBackendUrl ? 'FastAPI APMC Stream' : 'Karnataka APMC Benchmark',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text(
                  '${_rates.length} commodities',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Rates List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryGreen))
                : _rates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No mandi rates found for "$_selectedDistrict"',
                              style: const TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDistrict = 'All';
                                  _searchController.clear();
                                });
                                _loadRates();
                              },
                              child: const Text('Show All Districts'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRates,
                        color: AppConstants.primaryGreen,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _rates.length,
                          itemBuilder: (context, index) {
                            final rate = _rates[index];
                            return _buildMandiCard(context, rate);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandiCard(BuildContext context, MandiRate rate) {
    Color trendColor = Colors.grey.shade600;
    IconData trendIcon = Icons.trending_flat;
    String trendText = 'Stable';

    if (rate.isTrendingUp) {
      trendColor = Colors.green.shade700;
      trendIcon = Icons.trending_up;
      trendText = '+${rate.trendPct.toStringAsFixed(1)}%';
    } else if (rate.isTrendingDown) {
      trendColor = Colors.red.shade700;
      trendIcon = Icons.trending_down;
      trendText = '${rate.trendPct.toStringAsFixed(1)}%';
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Commodity & Trend Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rate.commodity,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Variety: ${rate.variety}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: trendColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, size: 14, color: trendColor),
                      const SizedBox(width: 4),
                      Text(
                        trendText,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: trendColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Market Location Info
            Row(
              children: [
                const Icon(Icons.storefront, size: 16, color: AppConstants.primaryGreen),
                const SizedBox(width: 6),
                Text(
                  rate.market,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    rate.district,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Prices Grid (Min, Modal, Max)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceColumn('Min Price', '₹${rate.minPrice.toStringAsFixed(0)}/${rate.unit}', Colors.grey.shade700),
                _buildPriceColumn(
                  'Modal (Avg)',
                  rate.formattedModalPrice,
                  AppConstants.deepGreen,
                  isHighlight: true,
                ),
                _buildPriceColumn('Max Price', '₹${rate.maxPrice.toStringAsFixed(0)}/${rate.unit}', Colors.grey.shade700),
              ],
            ),

            const SizedBox(height: 14),

            // Action: Sell this produce button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddProduceScreen(
                        initialCropName: rate.commodity,
                        initialSuggestedPrice: rate.modalPrice,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: Text('List ${rate.commodity} at Suggested Price'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConstants.primaryGreen,
                  side: const BorderSide(color: AppConstants.primaryGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceColumn(String label, String value, Color color, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: isHighlight ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 17 : 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
