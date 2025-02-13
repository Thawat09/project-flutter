import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isPasswordMatch = false;
  bool _isNewPasswordValid = false;
  bool _isDarkMode = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadThemeFromFirestore();
    _newPasswordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    setState(() {
      _isNewPasswordValid = _newPasswordController.text.length >= 6;
      _isPasswordMatch =
          _newPasswordController.text == _confirmPasswordController.text;
    });
  }

  void _togglePasswordVisibility(String passwordType) {
    setState(() {
      if (passwordType == 'old') {
        _isOldPasswordVisible = !_isOldPasswordVisible;
      } else if (passwordType == 'new') {
        _isNewPasswordVisible = !_isNewPasswordVisible;
      } else if (passwordType == 'confirm') {
        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
      }
    });
  }

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final credentials = EmailAuthProvider.credential(
          email: user.email!,
          password: _oldPasswordController.text,
        );
        await user.reauthenticateWithCredential(credentials);

        if (_isPasswordMatch) {
          await user.updatePassword(_newPasswordController.text);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Password changed successfully",
                  style: TextStyle(
                    fontFamily: 'DynaPuff',
                    fontSize: 16,
                  ),
                ),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacementNamed(context, '/settings');
            });
          }
        }
      } catch (e) {
        _showErrorSnackBar("Failed to change password. Please try again.");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadThemeFromFirestore() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _isDarkMode = userDoc['isDarkMode'] ?? false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'DynaPuff', fontSize: 16),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Change Password",
            style: TextStyle(
              fontFamily: 'DynaPuff',
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: !_isOldPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Old Password",
                  labelStyle: TextStyle(
                    fontFamily: 'DynaPuff',
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isOldPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => _togglePasswordVisibility('old'),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_isNewPasswordVisible,
                decoration: InputDecoration(
                  labelText: "New Password (min 6 characters)",
                  labelStyle: TextStyle(
                    fontFamily: 'DynaPuff',
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isNewPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => _togglePasswordVisibility('new'),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Confirm New Password",
                  labelStyle: TextStyle(
                    fontFamily: 'DynaPuff',
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => _togglePasswordVisibility('confirm'),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed:
                    (_isNewPasswordValid && _isPasswordMatch && !_isLoading)
                        ? _changePassword
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Change Password",
                        style: TextStyle(
                          fontFamily: 'DynaPuff',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
