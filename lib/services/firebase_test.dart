import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTest {
  static Future<void> testFirestoreConnection() async {
    try {
      print('Testing Firestore connection...');
      
      // Test basic Firestore connection
      final firestore = FirebaseFirestore.instance;
      print('Firestore instance created successfully');
      
      // Test authentication
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      print('Current user: ${user?.uid ?? 'No user logged in'}');
      
      if (user == null) {
        print('ERROR: No user is logged in. Authentication required for Firestore writes.');
        return;
      }
      
      // Test write to Firestore
      final testDoc = await firestore.collection('test').add({
        'message': 'Test connection',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'userId': user.uid,
      });
      
      print('✅ Test document created successfully with ID: ${testDoc.id}');
      
      // Clean up test document
      await testDoc.delete();
      print('✅ Test document cleaned up');
      
    } catch (e) {
      print('❌ Firestore connection failed: $e');
      print('Error type: ${e.runtimeType}');
      
      if (e.toString().contains('permission-denied')) {
        print('🔒 Permission denied - Check Firestore security rules');
      } else if (e.toString().contains('unavailable')) {
        print('🌐 Network unavailable - Check internet connection');
      } else if (e.toString().contains('not-found')) {
        print('📁 Firestore not found - Check if Firestore is enabled in Firebase console');
      }
    }
  }
}
