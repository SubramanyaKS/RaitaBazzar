import 'package:flutter/material.dart';

class AppConstants {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color deepGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color lightGreenBg = Color(0xFFF1F8E9);
  static const Color warmOrange = Color(0xFFFF9800);

  // Crop Categories
  static const List<String> cropCategories = [
    'Vegetables',
    'Fruits',
    'Grains & Cereals',
    'Pulses',
    'Spices',
    'Oilseeds',
    'Commercial Crops',
  ];

  // Quantity Units
  static const List<String> quantityUnits = [
    'Kg',
    'Quintal (100 kg)',
    'Ton (1000 kg)',
    'Bags (50 kg)',
    'Boxes',
  ];

  // User Roles
  static const String roleFarmer = 'farmer';
  static const String roleBuyer = 'buyer';
}
