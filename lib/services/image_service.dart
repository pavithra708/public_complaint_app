import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  // Request gallery permission
  Future<bool> requestGalleryPermission() async {
    var status = await Permission.photos.status;
    if (status.isDenied) {
      status = await Permission.photos.request();
    }
    return status.isGranted;
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      // Skip permission check on web as it's not supported
      if (!kIsWeb) {
        final bool hasPermission = await requestCameraPermission();
        if (!hasPermission) {
          throw Exception('Camera permission denied');
        }
      }
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      // Skip permission check on web as it's not supported
      if (!kIsWeb) {
        final bool hasPermission = await requestGalleryPermission();
        if (!hasPermission) {
          throw Exception('Gallery permission denied');
        }
      }
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image from gallery: $e');
    }
  }

  // Convert XFile to File
  Future<File> convertXFileToFile(XFile xfile) async {
    return File(xfile.path);
  }
}