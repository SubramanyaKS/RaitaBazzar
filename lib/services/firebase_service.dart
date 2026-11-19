import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:raitabazzar/models/buyer_offer.dart';
import 'package:raitabazzar/models/crop_listing.dart';
import 'package:raitabazzar/services/cloudinary_service.dart';

class FirebaseService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final CloudinaryService _cloudinary = CloudinaryService();

  CollectionReference get _cropsRef => _firestore.collection('crops');
  CollectionReference get _offersRef => _firestore.collection('offers');
  CollectionReference get _usersRef => _firestore.collection('users');

  /// Stream of all active crops for the buyer marketplace
  Stream<List<CropListing>> streamActiveCrops() {
    return _cropsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CropListing.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Automatically seeds sample crops, offers, and verified user profiles if Firestore is empty
  Future<void> seedInitialDataIfEmpty({
    required List<CropListing> seedCrops,
    required List<BuyerOffer> seedOffers,
  }) async {
    try {
      final existingCrops = await _cropsRef.limit(1).get();
      if (existingCrops.docs.isNotEmpty) {
        debugPrint('FirebaseService: Firestore already has crops. Skipping seed.');
        return;
      }

      debugPrint('FirebaseService: Firestore is empty. Migrating sample crops, offers & user profiles to cloud...');

      final batch = _firestore.batch();

      for (final crop in seedCrops) {
        final newDoc = _cropsRef.doc(crop.id);
        batch.set(newDoc, crop.toMap());
      }

      for (final offer in seedOffers) {
        final newDoc = _offersRef.doc(offer.id);
        batch.set(newDoc, offer.toMap());
      }

      // Seed verified default user profiles for instant testing
      final defaultUsers = [
        {
          'id': '+919876543210',
          'phone': '+919876543210',
          'role': 'farmer',
          'name': 'Basavaraj Gowda',
          'location': 'Mandya, Karnataka',
          'fruitsId': 'FID-KA-2024-9843',
          'isKisanVerified': true,
        },
        {
          'id': '+919988776655',
          'phone': '+919988776655',
          'role': 'buyer',
          'name': 'Ramesh Traders',
          'business': 'Wholesale Produce & Retail',
          'location': 'K.R. Market, Bengaluru',
          'apmcLicense': 'APMC-BLR-8841',
        },
        {
          'id': '+919845012345',
          'phone': '+919845012345',
          'role': 'farmer',
          'name': 'Nanjunde Gowda',
          'location': 'K.R. Pete, Mandya',
          'fruitsId': 'FID-KA-2024-1102',
          'isKisanVerified': true,
        },
        {
          'id': '+919731298765',
          'phone': '+919731298765',
          'role': 'farmer',
          'name': 'Shivanna',
          'location': 'Ramanagara, Karnataka',
          'fruitsId': 'FID-KA-2024-5541',
          'isKisanVerified': true,
        },
      ];

      for (final user in defaultUsers) {
        final phoneKey = user['phone'] as String;
        final userDoc = _usersRef.doc(phoneKey);
        batch.set(userDoc, {
          ...user,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('FirebaseService: Successfully migrated sample data and users to Cloud Firestore!');
    } catch (e) {
      debugPrint('FirebaseService: Seeding note/error: $e');
    }
  }

  /// Add new crop listing to Firestore (with optional Cloudinary photo upload)
  Future<String> addCrop(CropListing listing, File? imageFile) async {
    try {
      String? uploadedUrl = listing.imageUrl;

      if (imageFile != null) {
        final cloudUrl = await _cloudinary.uploadImage(imageFile);
        if (cloudUrl != null) {
          uploadedUrl = cloudUrl;
        }
      }

      final docRef = await _cropsRef.add({
        ...listing.toMap(),
        'imageUrl': uploadedUrl,
      });

      return docRef.id;
    } catch (e) {
      debugPrint('Error adding crop to Firestore: $e');
      rethrow;
    }
  }

  /// Toggle status between 'Active' and 'Sold Out'
  Future<void> toggleCropStatus(String cropId, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'Active' ? 'Sold Out' : 'Active';
      await _cropsRef.doc(cropId).update({'status': newStatus});
    } catch (e) {
      debugPrint('Error toggling crop status: $e');
      rethrow;
    }
  }

  /// Update crop price
  Future<void> updateCropPrice(String cropId, double newPrice) async {
    try {
      await _cropsRef.doc(cropId).update({'pricePerUnit': newPrice});
    } catch (e) {
      debugPrint('Error updating crop price: $e');
      rethrow;
    }
  }

  /// Update multiple crop fields (price, quantity, status, etc.)
  Future<void> updateCropListing(String cropId, Map<String, dynamic> updates) async {
    try {
      await _cropsRef.doc(cropId).update(updates);
    } catch (e) {
      debugPrint('Error updating crop listing in Firestore: $e');
      rethrow;
    }
  }

  /// Delete crop listing
  Future<void> deleteCrop(String cropId) async {
    try {
      await _cropsRef.doc(cropId).delete();
    } catch (e) {
      debugPrint('Error deleting crop: $e');
      rethrow;
    }
  }

  /// Stream of all buyer offers
  Stream<List<BuyerOffer>> streamOffers() {
    return _offersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BuyerOffer.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Submit a new buyer offer to Firestore
  Future<String> submitOffer(BuyerOffer offer) async {
    try {
      final docRef = await _offersRef.add(offer.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error submitting offer to Firestore: $e');
      rethrow;
    }
  }

  /// Update offer status ('Accepted' or 'Declined')
  Future<void> updateOfferStatus(String offerId, String status) async {
    try {
      await _offersRef.doc(offerId).update({'status': status});
    } catch (e) {
      debugPrint('Error updating offer status: $e');
      rethrow;
    }
  }

  /// Save or update user profile in Firestore
  Future<void> saveUserProfile(String userId, Map<String, dynamic> userData) async {
    try {
      await _usersRef.doc(userId).set({
        ...userData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('FirebaseService: User profile saved to Firestore for $userId');
    } catch (e) {
      debugPrint('Error saving user profile to Firestore: $e');
    }
  }

  /// Fetch user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile from Firestore: $e');
      return null;
    }
  }
}
