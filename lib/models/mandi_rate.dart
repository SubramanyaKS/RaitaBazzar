class MandiRate {
  final String id;
  final String commodity;
  final String variety;
  final String market;
  final String district;
  final String state;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final String unit; // 'Kg' or 'Quintal'
  final String trend; // 'up', 'down', 'stable'
  final double trendPct;
  final String arrivalDate;

  const MandiRate({
    required this.id,
    required this.commodity,
    required this.variety,
    required this.market,
    required this.district,
    this.state = 'Karnataka',
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    this.unit = 'Kg',
    this.trend = 'stable',
    this.trendPct = 0.0,
    required this.arrivalDate,
  });

  bool get isTrendingUp => trend == 'up';
  bool get isTrendingDown => trend == 'down';

  String get formattedModalPrice => '₹${modalPrice.toStringAsFixed(modalPrice.truncateToDouble() == modalPrice ? 0 : 2)}/$unit';
  String get formattedRange => '₹${minPrice.toStringAsFixed(0)} - ₹${maxPrice.toStringAsFixed(0)}/$unit';

  factory MandiRate.fromJson(Map<String, dynamic> json) {
    return MandiRate(
      id: json['id']?.toString() ?? '',
      commodity: json['commodity']?.toString() ?? 'Unknown Crop',
      variety: json['variety']?.toString() ?? 'Common',
      market: json['market']?.toString() ?? 'APMC Yard',
      district: json['district']?.toString() ?? 'Karnataka',
      state: json['state']?.toString() ?? 'Karnataka',
      minPrice: (json['min_price'] ?? json['minPrice'] ?? 0).toDouble(),
      maxPrice: (json['max_price'] ?? json['maxPrice'] ?? 0).toDouble(),
      modalPrice: (json['modal_price'] ?? json['modalPrice'] ?? 0).toDouble(),
      unit: json['unit']?.toString() ?? 'Kg',
      trend: json['trend']?.toString() ?? 'stable',
      trendPct: (json['trend_pct'] ?? json['trendPct'] ?? 0).toDouble(),
      arrivalDate: json['arrival_date'] ?? json['arrivalDate'] ?? 'Today',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commodity': commodity,
      'variety': variety,
      'market': market,
      'district': district,
      'state': state,
      'min_price': minPrice,
      'max_price': maxPrice,
      'modal_price': modalPrice,
      'unit': unit,
      'trend': trend,
      'trend_pct': trendPct,
      'arrival_date': arrivalDate,
    };
  }
}
