import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/components/image_option.dart';
import 'package:raitabazzar/models/crop_listing.dart';
import 'package:raitabazzar/models/mandi_rate.dart';
import 'package:raitabazzar/provider/app_provider.dart';
import 'package:raitabazzar/provider/listing_provider.dart';
import 'package:raitabazzar/services/mandi_service.dart';
import 'package:raitabazzar/utils/constant.dart';

class AddProduceScreen extends StatefulWidget {
  final String? initialCropName;
  final String? initialCategory;
  final double? initialSuggestedPrice;

  const AddProduceScreen({
    super.key,
    this.initialCropName,
    this.initialCategory,
    this.initialSuggestedPrice,
  });

  @override
  State<AddProduceScreen> createState() => _AddProduceScreenState();
}

class _AddProduceScreenState extends State<AddProduceScreen> {
  final _formKey = GlobalKey<FormState>();
  final MandiService _mandiService = MandiService();

  final TextEditingController _cropNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(text: 'Mandya, Karnataka');
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = AppConstants.cropCategories.first;
  String _selectedUnit = 'Quintal (100 kg)';
  String _selectedHarvestTime = 'Harvested Today';
  File? _pickedImage;
  bool _isLocating = false;
  MandiRate? _benchmarkRate;

  final ImagePicker _picker = ImagePicker();

  final List<String> _quickCropSuggestions = [
    'Tomatoes',
    'Red Onions',
    'Sona Masoori Paddy',
    'Ragi',
    'Green Chilies',
    'Potatoes',
    'Bananas',
    'Sweet Corn',
  ];

  final List<String> _harvestTimeOptions = [
    'Harvested Today',
    'Harvested 1-2 days ago',
    'Ready for harvest in 2-3 days',
    'Ready next week',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCropName != null && widget.initialCropName!.isNotEmpty) {
      _cropNameController.text = widget.initialCropName!;
      _updateBenchmark(widget.initialCropName!);
    }
    if (widget.initialCategory != null && AppConstants.cropCategories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory!;
    }
    if (widget.initialSuggestedPrice != null && widget.initialSuggestedPrice! > 0) {
      _priceController.text = widget.initialSuggestedPrice!.toStringAsFixed(0);
    }

    _cropNameController.addListener(_onCropNameChanged);
  }

  void _onCropNameChanged() {
    _updateBenchmark(_cropNameController.text);
  }

  void _updateBenchmark(String cropName) {
    final benchmark = _mandiService.findBenchmarkForCrop(cropName, district: 'Mandya');
    if (benchmark != _benchmarkRate) {
      setState(() {
        _benchmarkRate = benchmark;
      });
    }
  }

  Future<void> _detectGpsLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
        setState(() {
          _locationController.text = 'Mandya, Karnataka (${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)})';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📍 GPS location captured successfully!'),
              backgroundColor: AppConstants.primaryGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is needed to auto-fetch GPS.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch GPS: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  @override
  void dispose() {
    _cropNameController.removeListener(_onCropNameChanged);
    _cropNameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick photo: $e')),
        );
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Crop Photo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ImageOptionButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Take Photo',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    ImageOptionButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Choose Gallery',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double quantity = double.tryParse(_quantityController.text.trim()) ?? 0;
    final double price = double.tryParse(_priceController.text.trim()) ?? 0;
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final newListing = CropListing(
      id: 'crop_${DateTime.now().millisecondsSinceEpoch}',
      farmerId: 'farmer_${appProvider.farmerPhone.replaceAll(RegExp(r'[^0-9]'), '')}',
      farmerName: appProvider.farmerName,
      farmerPhone: appProvider.farmerPhone,
      cropName: _cropNameController.text.trim(),
      category: _selectedCategory,
      quantity: quantity,
      unit: _selectedUnit,
      pricePerUnit: price,
      location: _locationController.text.trim(),
      distanceKm: 15,
      harvestDate: _selectedHarvestTime,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      imagePath: _pickedImage?.path,
      status: 'Active',
      createdAt: DateTime.now(),
    );

    Provider.of<ListingProvider>(context, listen: false).addListing(
      newListing,
      imageFile: _pickedImage,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🌾 Crop successfully listed on RaitaBazzar! Buyers can now discover it.'),
        backgroundColor: AppConstants.primaryGreen,
        duration: Duration(seconds: 3),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List New Produce / ಬೆಳೆ ಸೇರಿಸಿ'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo Picker Card
                InkWell(
                  onTap: _showImagePickerModal,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppConstants.lightGreenBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppConstants.primaryGreen.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: _pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  _pickedImage!,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  right: 10,
                                  top: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_a_photo_rounded,
                                size: 48,
                                color: AppConstants.primaryGreen,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to add harvest photo',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.deepGreen,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Clear photo helps buyers buy faster',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Crop Name Field
                const Text(
                  'Crop Name / ಬೆಳೆಯ ಹೆಸರು *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cropNameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Sona Masoori Paddy, Tomato',
                    prefixIcon: const Icon(Icons.eco_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter crop name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // Quick Crop Suggestions
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickCropSuggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final crop = _quickCropSuggestions[index];
                      return ActionChip(
                        label: Text(crop, style: const TextStyle(fontSize: 12)),
                        onPressed: () {
                          setState(() {
                            _cropNameController.text = crop;
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Category Selector
                const Text(
                  'Category / ವರ್ಗ *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.category_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: AppConstants.cropCategories.map((String cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (String? val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                // Quantity & Unit Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quantity / ಪ್ರಮಾಣ *',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                            decoration: InputDecoration(
                              hintText: 'e.g. 50',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter quantity';
                              }
                              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unit / ಘಟಕ *',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: AppConstants.quantityUnits.map((String u) {
                              return DropdownMenuItem<String>(
                                value: u,
                                child: Text(u, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (String? val) {
                              if (val != null) {
                                setState(() {
                                  _selectedUnit = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Expected Price Field
                const Text(
                  'Expected Price / ನಿರೀಕ್ಷಿತ ಬೆಲೆ *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Text('₹', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    hintText: 'Price per $_selectedUnit',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter expected price';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),

                if (_benchmarkRate != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.lightGreenBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppConstants.lightGreen),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insights, color: AppConstants.primaryGreen, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mandi Benchmark: ${_benchmarkRate!.market}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppConstants.deepGreen),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Modal Avg: ${_benchmarkRate!.formattedModalPrice} (Range: ${_benchmarkRate!.formattedRange})',
                                style: const TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _priceController.text = _benchmarkRate!.modalPrice.toStringAsFixed(0);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Use Price'),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Harvest Readiness / Date
                const Text(
                  'Harvest Date / ಕೊಯ್ಲು ದಿನಾಂಕ *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedHarvestTime,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _harvestTimeOptions.map((String time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                  onChanged: (String? val) {
                    if (val != null) {
                      setState(() {
                        _selectedHarvestTime = val;
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                // Farm Location
                const Text(
                  'Farm Location / ಸ್ಥಳ *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    hintText: 'e.g. Village, Mandya District',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    suffixIcon: IconButton(
                      icon: _isLocating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppConstants.primaryGreen),
                            )
                          : const Icon(Icons.my_location, color: AppConstants.primaryGreen),
                      tooltip: 'Auto-detect GPS Location',
                      onPressed: _isLocating ? null : _detectGpsLocation,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Description (Optional)
                const Text(
                  'Additional Notes / ವಿಶೇಷತೆಗಳು (Optional)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'e.g. Naturally ripened, Grade-A, organic fertilizer used...',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Publish Crop Listing / ಬೆಳೆ ಪ್ರಕಟಿಸಿ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

