import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _role;

  User? get user => _user;
  String? get role => _role;

  Future<void> register(String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _user = cred.user;
      if (_user != null) {
        await _firestore.collection('users').doc(_user!.uid).set({'email': email});
      }
      notifyListeners();
    } catch (e) {
      print("Registration error: $e");
      rethrow; // Re-throw to handle in UI if needed
    }
  }

  Future<void> login(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = cred.user;
      if (_user != null) {
        // Fetch role from Firestore (optional, based on earlier versions)
        DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();
        _role = doc['role'] as String?; // Adjust based on your schema
      }
      notifyListeners();
    } catch (e) {
      print("Login error: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user = null;
      _role = null;
      notifyListeners();
    } catch (e) {
      print("Logout error: $e");
      rethrow;
    }
  }
}