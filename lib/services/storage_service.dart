import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload image to Firebase Storage
  Future<String> uploadComplaintImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create unique filename
      String fileName = 'complaints/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Create reference to the file
      Reference storageRef = _storage.ref().child(fileName);
      
      // Upload file
      UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': user.uid,
            'uploadedAt': DateTime.now().toString(),
          },
        ),
      );

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      Uri uri = Uri.parse(imageUrl);
      String filePath = uri.path.split('/o/')[1].split('?')[0];
      
      // Decode URL encoded characters
      filePath = Uri.decodeFull(filePath);
      
      Reference storageRef = _storage.ref().child(filePath);
      await storageRef.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Get storage usage (optional - for future features)
  Future<int> getUserStorageUsage() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;

      Reference userFolderRef = _storage.ref().child('complaints/${user.uid}');
      ListResult result = await userFolderRef.listAll();
      
      int totalSize = 0;
      for (var item in result.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}