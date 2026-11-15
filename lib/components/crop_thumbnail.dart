import 'dart:io';
import 'package:flutter/material.dart';
import 'package:raitabazzar/models/crop_listing.dart';
import 'package:raitabazzar/utils/constant.dart';

class CropThumbnail extends StatelessWidget {
  final CropListing listing;
  final double size;
  final double radius;

  const CropThumbnail({
    super.key,
    required this.listing,
    this.size = 56,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppConstants.lightGreenBg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: _buildImageContent(),
    );
  }

  Widget _buildImageContent() {
    if (listing.imageUrl != null && listing.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          listing.imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.eco_rounded,
            color: AppConstants.primaryGreen,
            size: size * 0.5,
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      );
    }

    if (listing.imagePath != null && File(listing.imagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.file(
          File(listing.imagePath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    return Icon(
      Icons.eco_rounded,
      color: AppConstants.primaryGreen,
      size: size * 0.5,
    );
  }
}
