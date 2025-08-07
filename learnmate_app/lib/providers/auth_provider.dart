import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _auth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
      } else {
        _status = AuthStatus.authenticated;
        _user = UserModel.fromFirebaseUser(firebaseUser);
      }
      notifyListeners();
    });
  }

  // Sign In
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      if (credential.user != null) {
        _user = UserModel.fromFirebaseUser(credential.user);
        _status = AuthStatus.authenticated;
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign Up
  Future<bool> signUp(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      if (credential.user != null) {
        _user = UserModel.fromFirebaseUser(credential.user);
        _status = AuthStatus.authenticated;
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _status = AuthStatus.unauthenticated;
      _user = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error signing out';
      notifyListeners();
    }
  }

  // Password Reset
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper Methods
  void _setLoading(bool loading) {
    if (loading) {
      _status = AuthStatus.loading;
    }
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _errorMessage = 'No user found with this email';
        break;
      case 'wrong-password':
        _errorMessage = 'Incorrect password';
        break;
      case 'email-already-in-use':
        _errorMessage = 'Email is already registered';
        break;
      case 'weak-password':
        _errorMessage = 'Password is too weak';
        break;
      case 'invalid-email':
        _errorMessage = 'Invalid email address';
        break;
      case 'too-many-requests':
        _errorMessage = 'Too many failed attempts. Try again later';
        break;
      default:
        _errorMessage = 'Authentication failed. Please try again';
    }
    notifyListeners();
  }
}
```

