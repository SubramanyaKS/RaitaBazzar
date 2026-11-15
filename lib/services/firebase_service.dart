import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:raitabazzar/models/buyer_offer.dart';
import 'package:raitabazzar/models/crop_listing.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _cropsRef => _firestore.collection('crops');
  CollectionReference get _offersRef => _firestore.collection('offers');

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

  /// Upload crop photo to Firebase Storage and return download URL
  Future<String?> uploadCropPhoto(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.uri.pathSegments.last}';
      final storageRef = _storage.ref().child('crop_images/$fileName');

      final uploadTask = await storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading photo to Firebase Storage: $e');
      return null;
    }
  }

  /// Add new crop listing to Firestore
  Future<String> addCrop(CropListing listing, File? imageFile) async {
    try {
      String? uploadedUrl;
      if (imageFile != null) {
        uploadedUrl = await uploadCropPhoto(imageFile);
      }

      final docRef = await _cropsRef.add({
        ...listing.toMap(),
        'imageUrl': uploadedUrl ?? listing.imageUrl,
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
}
