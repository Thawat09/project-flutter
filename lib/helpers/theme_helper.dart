import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> loadThemeFromLocalStorage() async {
  final prefs = await SharedPreferences.getInstance();
  bool? storedTheme = prefs.getBool('isDarkMode');
  if (storedTheme != null) {
    return storedTheme;
  }
  return await loadThemeFromFirestore();
}

Future<bool> loadThemeFromFirestore() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists) {
      bool isDarkMode = userDoc['isDarkMode'] ?? false;
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isDarkMode', isDarkMode);
      return isDarkMode;
    }
  }
  return false;
}
