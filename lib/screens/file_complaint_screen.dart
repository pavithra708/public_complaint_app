import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/complaint_service.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/image_service.dart';
import '../models/complaint_model.dart';

class FileComplaintScreen extends StatefulWidget {
  const FileComplaintScreen({Key? key}) : super(key: key);

  @override
  _FileComplaintScreenState createState() => _FileComplaintScreenState();
}

class _FileComplaintScreenState extends State<FileComplaintScreen> {
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

  // Submit complaint with image
  Future<void> _submitComplaint() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.user;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create complaint object
      final complaint = Complaint(
        title: titleController.text,
        description: descriptionController.text,
        category: selectedCategory,
        userId: user.uid,
        userEmail: user.email!,
        userName: user.displayName,
        createdAt: DateTime.now(),
        location: _locationAddress,
        latitude: _latitude,
        longitude: _longitude,
      );

      // Submit complaint
      await _complaintService.createComplaint(complaint);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint filed successfully!')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to file complaint: $e')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Complaint'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
              decoration: const InputDecoration(
                labelText: 'Complaint Title',
                border: OutlineInputBorder(),
                hintText: 'e.g., Pothole on Main Street',
              ),
            ),
            const SizedBox(height: 16),
            
            // Description Field
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                hintText: 'Describe the issue in detail...',
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
                    const Text(
                      'Add Photo',
                      style: TextStyle(
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
                                  label: const Text('Remove'),
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
                                  label: const Text('Retake'),
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
                              label: const Text('Take Photo'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImageFromGallery,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('From Gallery'),
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
                    const Text(
                      'Location',
                      style: TextStyle(
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
                            style: const TextStyle(color: Colors.green),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Update Location'),
                          ),
                        ],
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: isGettingLocation ? null : _getCurrentLocation,
                        icon: isGettingLocation
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.location_on),
                        label: Text(isGettingLocation
                            ? 'Getting Location...'
                            : 'Add Current Location'),
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
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Complaint'),
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