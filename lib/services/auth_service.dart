import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthService with ChangeNotifier {
  static const List<String> _adminEmails = [
    'admin@gmail.com',
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  User? _user;
  bool _isAdminSession = false;

  bool get isLoading => _isLoading;
  User? get user => _user;
  bool get isAdminSession => _isAdminSession;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user == null) {
        _isAdminSession = false;
      }
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

  bool get userHasAdminPrivileges {
    final email = _user?.email?.toLowerCase();
    if (email == null) return false;
    return _adminEmails.contains(email);
  }

  Future<void> signInWithEmailAndPassword(
      String email, String password) async {
    return _signIn(email: email, password: password, adminMode: false);
  }

  Future<void> signInAdmin(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!_adminEmails.contains(normalizedEmail)) {
      throw Exception('You are not authorized to access the admin portal.');
    }
    return _signIn(email: email, password: password, adminMode: true);
  }

  Future<void> _signIn({
    required String email,
    required String password,
    required bool adminMode,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _isAdminSession = adminMode;
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
    _isAdminSession = false;
    notifyListeners();
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

  List<String> get adminEmails => List.unmodifiable(_adminEmails);
}