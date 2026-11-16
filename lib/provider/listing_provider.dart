import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:raitabazzar/models/buyer_offer.dart';
import 'package:raitabazzar/models/crop_listing.dart';
import 'package:raitabazzar/services/firebase_service.dart';

class ListingProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  StreamSubscription<List<CropListing>>? _cropsSub;
  StreamSubscription<List<BuyerOffer>>? _offersSub;

  List<CropListing> _listings = [
    CropListing(
      id: 'crop_1',
      farmerId: 'farmer_1',
      farmerName: 'Basavaraj Gowda',
      farmerPhone: '+919876543210',
      cropName: 'Bangalore Fresh Tomatoes',
      category: 'Vegetables',
      quantity: 1500,
      unit: 'Kg',
      pricePerUnit: 26,
      location: 'Mandya (28 km away)',
      distanceKm: 28,
      harvestDate: 'Harvested yesterday',
      description: 'Grade-A farm fresh tomatoes, naturally ripened, ready for immediate pickup.',
      status: 'Active',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    CropListing(
      id: 'crop_2',
      farmerId: 'farmer_2',
      farmerName: 'Nanjunde Gowda',
      farmerPhone: '+919845012345',
      cropName: 'Mysuru Sona Masoori Paddy',
      category: 'Grains & Cereals',
      quantity: 40,
      unit: 'Quintal (100 kg)',
      pricePerUnit: 2400,
      location: 'K.R. Pete (42 km away)',
      distanceKm: 42,
      harvestDate: 'Harvested 3 days ago',
      description: 'Premium quality Sona Masoori paddy with 12% moisture content. Stored in dry warehouse.',
      status: 'Active',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    CropListing(
      id: 'crop_3',
      farmerId: 'farmer_3',
      farmerName: 'Shivanna',
      farmerPhone: '+919731298765',
      cropName: 'Organically Grown Red Onions',
      category: 'Vegetables',
      quantity: 800,
      unit: 'Kg',
      pricePerUnit: 34,
      location: 'Ramanagara (18 km away)',
      distanceKm: 18,
      harvestDate: 'Harvested 2 days ago',
      description: 'Medium to large size red onions, sun-dried and sorted for long shelf life.',
      status: 'Active',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CropListing(
      id: 'crop_4',
      farmerId: 'farmer_1',
      farmerName: 'Basavaraj Gowda',
      farmerPhone: '+919876543210',
      cropName: 'Mandya Organic Ragi (Finger Millet)',
      category: 'Grains & Cereals',
      quantity: 25,
      unit: 'Quintal (100 kg)',
      pricePerUnit: 3200,
      location: 'Mandya (28 km away)',
      distanceKm: 28,
      harvestDate: 'Harvested 1 week ago',
      description: 'Cleaned and stone-free organic ragi, ideal for flour mills and retail packing.',
      status: 'Active',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  List<BuyerOffer> _offers = [
    BuyerOffer(
      id: 'offer_1',
      listingId: 'crop_1',
      buyerName: 'Ramesh Wholesale Mart',
      buyerPhone: '+919886011223',
      buyerLocation: 'Bengaluru (65 km)',
      cropName: 'Bangalore Fresh Tomatoes',
      offeredPrice: 24,
      unit: 'Kg',
      requestedQuantity: 1000,
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    BuyerOffer(
      id: 'offer_2',
      listingId: 'crop_2',
      buyerName: 'Sri Krishna Retailers',
      buyerPhone: '+919844055667',
      buyerLocation: 'Mysuru (35 km)',
      cropName: 'Mysuru Sona Masoori Paddy',
      offeredPrice: 2350,
      unit: 'Quintal (100 kg)',
      requestedQuantity: 40,
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
  ];

  bool _isFirebaseSynced = false;
  bool get isFirebaseSynced => _isFirebaseSynced;

  ListingProvider() {
    _initFirebaseSync();
  }

  void _initFirebaseSync() {
    try {
      // Trigger automatic migration to Cloud Firestore if cloud is empty
      _firebaseService.seedInitialDataIfEmpty(
        seedCrops: _listings,
        seedOffers: _offers,
      );

      _cropsSub = _firebaseService.streamActiveCrops().listen(
        (firestoreCrops) {
          if (firestoreCrops.isNotEmpty) {
            _listings = firestoreCrops;
            _isFirebaseSynced = true;
            notifyListeners();
          }
        },
        onError: (e) {
          debugPrint('Firestore crops stream note (using offline fallback): $e');
        },
      );

      _offersSub = _firebaseService.streamOffers().listen(
        (firestoreOffers) {
          if (firestoreOffers.isNotEmpty) {
            _offers = firestoreOffers;
            notifyListeners();
          }
        },
        onError: (e) {
          debugPrint('Firestore offers stream note: $e');
        },
      );
    } catch (e) {
      debugPrint('Firebase not available in current environment: $e');
    }
  }

  @override
  void dispose() {
    _cropsSub?.cancel();
    _offersSub?.cancel();
    super.dispose();
  }

  List<CropListing> get allListings => List.unmodifiable(_listings);
  List<CropListing> get activeMarketListings => _listings.where((l) => l.isActive).toList();
  List<CropListing> get myFarmerListings => _listings;
  List<BuyerOffer> get offers => List.unmodifiable(_offers);
  int get pendingOffersCount => _offers.where((o) => o.status == 'Pending').length;

  Future<void> addListing(CropListing listing, {File? imageFile}) async {
    // Optimistic local add
    _listings.insert(0, listing);
    notifyListeners();

    try {
      await _firebaseService.addCrop(listing, imageFile);
    } catch (e) {
      debugPrint('Failed to sync new crop to Firestore: $e');
    }
  }

  Future<void> updateListingPrice(String id, double newPrice) async {
    final index = _listings.indexWhere((l) => l.id == id);
    if (index != -1) {
      _listings[index] = _listings[index].copyWith(pricePerUnit: newPrice);
      notifyListeners();
    }

    try {
      await _firebaseService.updateCropPrice(id, newPrice);
    } catch (e) {
      debugPrint('Failed to sync price update to Firestore: $e');
    }
  }

  Future<void> updateListingDetails(String id, {double? price, double? quantity, String? status}) async {
    final index = _listings.indexWhere((l) => l.id == id);
    if (index != -1) {
      final current = _listings[index];
      final updated = current.copyWith(
        pricePerUnit: price ?? current.pricePerUnit,
        quantity: quantity ?? current.quantity,
        status: status ?? current.status,
      );
      _listings[index] = updated;
      notifyListeners();

      final Map<String, dynamic> updates = {};
      if (price != null) updates['pricePerUnit'] = price;
      if (quantity != null) updates['quantity'] = quantity;
      if (status != null) updates['status'] = status;

      try {
        await _firebaseService.updateCropListing(id, updates);
      } catch (e) {
        debugPrint('Failed to sync listing updates to Firestore: $e');
      }
    }
  }

  List<BuyerOffer> getOffersForCrop(String cropId) {
    return _offers.where((o) => o.listingId == cropId).toList();
  }

  Future<void> toggleListingStatus(String id) async {
    final index = _listings.indexWhere((l) => l.id == id);
    if (index != -1) {
      final current = _listings[index];
      final newStatus = current.status == 'Active' ? 'Sold Out' : 'Active';
      _listings[index] = current.copyWith(status: newStatus);
      notifyListeners();

      try {
        await _firebaseService.toggleCropStatus(id, current.status);
      } catch (e) {
        debugPrint('Failed to sync status toggle to Firestore: $e');
      }
    }
  }

  Future<void> deleteListing(String id) async {
    _listings.removeWhere((l) => l.id == id);
    notifyListeners();

    try {
      await _firebaseService.deleteCrop(id);
    } catch (e) {
      debugPrint('Failed to sync delete to Firestore: $e');
    }
  }

  Future<void> respondToOffer(String offerId, String status) async {
    final index = _offers.indexWhere((o) => o.id == offerId);
    if (index != -1) {
      _offers[index].status = status;
      notifyListeners();
    }

    try {
      await _firebaseService.updateOfferStatus(offerId, status);
    } catch (e) {
      debugPrint('Failed to sync offer status to Firestore: $e');
    }
  }

  Future<void> submitBuyerOffer(BuyerOffer offer) async {
    _offers.insert(0, offer);
    notifyListeners();

    try {
      await _firebaseService.submitOffer(offer);
    } catch (e) {
      debugPrint('Failed to sync buyer offer to Firestore: $e');
    }
  }

  List<CropListing> filterMarketListings({
    required String query,
    required String category,
    int? maxDistanceKm,
  }) {
    return _listings.where((listing) {
      final matchesActive = listing.isActive;
      final matchesCategory = category == 'All' || listing.category.toLowerCase().contains(category.toLowerCase());
      final matchesQuery = query.isEmpty ||
          listing.cropName.toLowerCase().contains(query.toLowerCase()) ||
          listing.location.toLowerCase().contains(query.toLowerCase());
      final matchesDistance = maxDistanceKm == null || listing.distanceKm <= maxDistanceKm;
      return matchesActive && matchesCategory && matchesQuery && matchesDistance;
    }).toList();
  }
}
