import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/complaint_model.dart';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reference to complaints collection
  CollectionReference get _complaintsRef => _firestore.collection('complaints');

  // Create a new complaint (authenticated user)
  Future<String> createComplaint(Complaint complaint) async {
    try {
      print('Creating complaint with data: ${complaint.toMap()}');
      final docRef = await _complaintsRef.add(complaint.toMap());
      print('Complaint created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating complaint: $e');
      throw Exception('Failed to create complaint: $e');
    }
  }

  // Create an anonymous complaint (no authentication required)
  Future<String> createAnonymousComplaint(Complaint complaint) async {
    try {
      // Ensure it's marked as anonymous and remove any user identification
      final anonymousComplaint = complaint.copyWith(
        isAnonymous: true,
        userId: null,
        userEmail: null,
        userName: null,
      );
      print('Creating anonymous complaint with data: ${anonymousComplaint.toMap()}');
      final docRef = await _complaintsRef.add(anonymousComplaint.toMap());
      print('Anonymous complaint created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating anonymous complaint: $e');
      throw Exception('Failed to create anonymous complaint: $e');
    }
  }

  // Get all complaints for current user
  Stream<List<Complaint>> getUserComplaints() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    // Simplified query without ordering to avoid index requirement
    return _complaintsRef
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final complaints = snapshot.docs
              .map((doc) => Complaint.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          
          // Sort in memory instead of database
          complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return complaints;
        });
  }

  // Get all complaints (admin view)
  Stream<List<Complaint>> getAllComplaints() {
    return _complaintsRef.snapshots().map((snapshot) {
      final complaints = snapshot.docs
          .map((doc) => Complaint.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return complaints;
    });
  }

  // Update complaint status
  Future<void> updateComplaintStatus(String complaintId, String newStatus) async {
    try {
      await _complaintsRef.doc(complaintId).update({
        'status': newStatus,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to update complaint: $e');
    }
  }

  // Delete a complaint
  Future<void> deleteComplaint(String complaintId) async {
    try {
      await _complaintsRef.doc(complaintId).delete();
    } catch (e) {
      throw Exception('Failed to delete complaint: $e');
    }
  }
}