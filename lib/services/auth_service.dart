import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  User? _user;

  bool get isLoading => _isLoading;
  User? get user => _user;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await result.user!.updateDisplayName(name);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update user profile methods
  Future<void> updateDisplayName(String name) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _auth.currentUser!.updateDisplayName(name);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEmail(String email) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Note: updateEmail requires re-authentication in Firebase
      // For now, we'll show a message that this feature needs re-authentication
      throw Exception('Email update requires re-authentication. Please sign out and sign in again.');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Alias methods for compatibility
  Future<void> signInWithEmail(String email, String password) async {
    return signInWithEmailAndPassword(email, password);
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    return signUpWithEmailAndPassword(email, password, name);
  }
}