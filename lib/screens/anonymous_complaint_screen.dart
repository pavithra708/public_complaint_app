import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/complaint_service.dart';
import '../services/location_service.dart';
import '../services/image_service.dart';
import '../models/complaint_model.dart';
import 'package:public_complaint_app/generated/app_localizations.dart';

class AnonymousComplaintScreen extends StatefulWidget {
  const AnonymousComplaintScreen({Key? key}) : super(key: key);

  @override
  _AnonymousComplaintScreenState createState() => _AnonymousComplaintScreenState();
}

class _AnonymousComplaintScreenState extends State<AnonymousComplaintScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String selectedCategory = 'Road Issues';
  bool isSubmitting = false;
  bool isGettingLocation = false;
  File? _selectedImage;
  String? _locationAddress;
  double? _latitude;
  double? _longitude;

  final ComplaintService _complaintService = ComplaintService();
  final LocationService _locationService = LocationService();
  final ImageService _imageService = ImageService();

  // Pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imageService.pickImageFromCamera();
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imageService.pickImageFromGallery();
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      isGettingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final address = await _locationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationAddress = address;
        isGettingLocation = false;
      });
    } catch (e) {
      setState(() {
        isGettingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  // Remove selected image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // Submit anonymous complaint
  Future<void> _submitComplaint() async {
    final l10n = AppLocalizations.of(context)!;
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseFillAllFields)),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Create anonymous complaint object
      final complaint = Complaint(
        title: titleController.text,
        description: descriptionController.text,
        category: selectedCategory,
        isAnonymous: true,
        createdAt: DateTime.now(),
        location: _locationAddress,
        latitude: _latitude,
        longitude: _longitude,
      );

      // Submit complaint (no authentication required)
      await _complaintService.createAnonymousComplaint(complaint);
      
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.anonymousComplaintFiledSuccess),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear form and go back
      titleController.clear();
      descriptionController.clear();
      setState(() {
        _selectedImage = null;
        _locationAddress = null;
        _latitude = null;
        _longitude = null;
      });
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to file complaint: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fileAnonymousComplaint),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.yourIdentityWillBeProtected,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.anonymousComplaintInfo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: ComplaintCategories.categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Title Field
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: l10n.complaintTitle,
                border: const OutlineInputBorder(),
                hintText: l10n.complaintTitleHint,
              ),
            ),
            const SizedBox(height: 16),
            
            // Description Field
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.description,
                border: const OutlineInputBorder(),
                hintText: l10n.descriptionHint,
              ),
            ),
            const SizedBox(height: 16),

            // Image Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.addPhotoOptional,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedImage != null)
                      Column(
                        children: [
                          Image.file(
                            _selectedImage!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _removeImage,
                                  icon: const Icon(Icons.delete),
                                  label: Text(l10n.remove),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickImageFromCamera,
                                  icon: const Icon(Icons.camera_alt),
                                  label: Text(l10n.retake),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImageFromCamera,
                              icon: const Icon(Icons.camera_alt),
                              label: Text(l10n.camera),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImageFromGallery,
                              icon: const Icon(Icons.photo_library),
                              label: Text(l10n.gallery),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.locationOptional,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_locationAddress != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _locationAddress!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _getCurrentLocation,
                            child: Text(l10n.updateLocation),
                          ),
                        ],
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: isGettingLocation ? null : _getCurrentLocation,
                        icon: isGettingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.location_on),
                        label: Text(isGettingLocation ? l10n.gettingLocation : l10n.getCurrentLocation),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
                child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        l10n.submitAnonymousComplaint,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

