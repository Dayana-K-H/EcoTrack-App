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
      notifyListeners();
    });
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _errorMessage = 'Sign up successful!';
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
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
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
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
      _errorMessage = 'Signed in with Google successfully!';
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during Google sign-in: $e';
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
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}