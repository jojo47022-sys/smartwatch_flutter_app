import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userGender;
  String? _userDob;

  AuthService(this._prefs) {
    _loadSession();
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userGender => _userGender;
  String? get userDob => _userDob;

  void _loadSession() {
    _isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;
    _userEmail = _prefs.getString('userEmail');
    _userGender = _prefs.getString('userGender');
    _userDob = _prefs.getString('userDob');
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoggedIn = true;
      _userEmail = email;
      await _prefs.setBool('isLoggedIn', true);
      await _prefs.setString('userEmail', email);
      notifyListeners();
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        default:
          return 'Login failed. Please try again.';
      }
    }
  }

  Future<String?> createAccount(String email, String password, String gender, String dob) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoggedIn = true;
      _userEmail = email;
      _userGender = gender;
      _userDob = dob;
      await _prefs.setBool('isLoggedIn', true);
      await _prefs.setString('userEmail', email);
      await _prefs.setString('userGender', gender);
      await _prefs.setString('userDob', dob);
      notifyListeners();
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Invalid email address.';
        default:
          return 'Account creation failed. Please try again.';
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _isLoggedIn = false;
    await _prefs.clear();
    notifyListeners();
  }
}