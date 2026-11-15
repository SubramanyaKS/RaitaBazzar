class BuyerOffer {
  final String id;
  final String listingId;
  final String buyerName;
  final String buyerPhone;
  final String buyerLocation;
  final String cropName;
  final double offeredPrice;
  final String unit;
  final double requestedQuantity;
  String status; // 'Pending', 'Accepted', 'Declined'
  final DateTime createdAt;

  BuyerOffer({
    required this.id,
    required this.listingId,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerLocation,
    required this.cropName,
    required this.offeredPrice,
    required this.unit,
    required this.requestedQuantity,
    this.status = 'Pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get formattedOfferedPrice =>
      '₹${offeredPrice.toStringAsFixed(offeredPrice.truncateToDouble() == offeredPrice ? 0 : 2)} / $unit';
  String get formattedRequestedQuantity =>
      '${requestedQuantity.toStringAsFixed(requestedQuantity.truncateToDouble() == requestedQuantity ? 0 : 1)} $unit';

  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerLocation': buyerLocation,
      'cropName': cropName,
      'offeredPrice': offeredPrice,
      'unit': unit,
      'requestedQuantity': requestedQuantity,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BuyerOffer.fromMap(Map<String, dynamic> map, String docId) {
    return BuyerOffer(
      id: docId,
      listingId: map['listingId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      buyerPhone: map['buyerPhone'] ?? '',
      buyerLocation: map['buyerLocation'] ?? '',
      cropName: map['cropName'] ?? '',
      offeredPrice: (map['offeredPrice'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? 'Kg',
      requestedQuantity: (map['requestedQuantity'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Pending',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
