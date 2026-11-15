class CropListing {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String cropName;
  final String category;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String location;
  final int distanceKm;
  final String harvestDate;
  final String? description;
  final String? imagePath;
  final String? imageUrl;
  String status; // 'Active' or 'Sold Out'
  final DateTime createdAt;

  CropListing({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.cropName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.location,
    required this.distanceKm,
    required this.harvestDate,
    this.description,
    this.imagePath,
    this.imageUrl,
    this.status = 'Active',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isActive => status == 'Active';

  String get formattedPrice =>
      '₹${pricePerUnit.toStringAsFixed(pricePerUnit.truncateToDouble() == pricePerUnit ? 0 : 2)} / $unit';
  String get formattedQuantity =>
      '${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 1)} $unit';

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'cropName': cropName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'location': location,
      'distanceKm': distanceKm,
      'harvestDate': harvestDate,
      'description': description,
      'imageUrl': imageUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CropListing.fromMap(Map<String, dynamic> map, String docId) {
    return CropListing(
      id: docId,
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      farmerPhone: map['farmerPhone'] ?? '',
      cropName: map['cropName'] ?? '',
      category: map['category'] ?? 'Vegetables',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? 'Kg',
      pricePerUnit: (map['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      location: map['location'] ?? '',
      distanceKm: (map['distanceKm'] as num?)?.toInt() ?? 10,
      harvestDate: map['harvestDate'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      status: map['status'] ?? 'Active',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  CropListing copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    String? farmerPhone,
    String? cropName,
    String? category,
    double? quantity,
    String? unit,
    double? pricePerUnit,
    String? location,
    int? distanceKm,
    String? harvestDate,
    String? description,
    String? imagePath,
    String? imageUrl,
    String? status,
    DateTime? createdAt,
  }) {
    return CropListing(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      cropName: cropName ?? this.cropName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      location: location ?? this.location,
      distanceKm: distanceKm ?? this.distanceKm,
      harvestDate: harvestDate ?? this.harvestDate,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
