import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthViewModel with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      print('Auth state changed. Current User: ${_currentUser?.email}, Display Name: ${_currentUser?.displayName}');
      notifyListeners();
    });
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
      _currentUser = _auth.currentUser;
      print('Sign up successful! User: ${_currentUser?.email}, Set Display Name: ${_currentUser?.displayName}');

      await _auth.signOut();
      _currentUser = null;
      print('User signed out immediately after sign up.');

      _errorMessage = 'Sign up successful! Please log in.';
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      print('Sign up error: ${e.message}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _auth.currentUser?.reload();
      _currentUser = _auth.currentUser;
      print('Sign in successful! User: ${_currentUser?.email}, Display Name: ${_currentUser?.displayName}');
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      print('Sign in error: ${e.message}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        _errorMessage = 'Google sign-in cancelled.';
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      await _auth.currentUser?.reload();
      _currentUser = _auth.currentUser;
      print('Signed in with Google successfully! User: ${_currentUser?.email}, Display Name: ${_currentUser?.displayName}');
      _errorMessage = 'Signed in with Google successfully!';
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      print('Google sign-in error (Firebase Auth): ${e.message}');
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during Google sign-in: $e';
      print('Google sign-in unexpected error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOutUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signOut();
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().signOut();
      }
      print('User signed out successfully.');
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      print('Sign out error: ${e.message}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
