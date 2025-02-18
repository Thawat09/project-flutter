import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_flutter/helpers/theme_helper.dart';

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

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTheme();
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
    if (!_isNewPasswordValid || !_isPasswordMatch) {
      _showErrorSnackBar("Please make sure all fields are valid.");
      return;
    }

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
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/settings');
              }
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

  Future<void> _loadTheme() async {
    bool storedTheme = await loadThemeFromLocalStorage();
    setState(() {
      _isDarkMode = storedTheme;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'DynaPuff',
            fontSize: 16,
          ),
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
          child: ListView(
            children: [
              _buildAnimatedFormField(
                controller: _oldPasswordController,
                label: "Old Password",
                isPasswordVisible: _isOldPasswordVisible,
                onToggleVisibility: () => _togglePasswordVisibility('old'),
                isObscured: !_isOldPasswordVisible,
              ),
              const SizedBox(height: 10),
              _buildAnimatedFormField(
                controller: _newPasswordController,
                label: "New Password (min 6 characters)",
                isPasswordVisible: _isNewPasswordVisible,
                onToggleVisibility: () => _togglePasswordVisibility('new'),
                isObscured: !_isNewPasswordVisible,
              ),
              const SizedBox(height: 10),
              _buildAnimatedFormField(
                controller: _confirmPasswordController,
                label: "Confirm New Password",
                isPasswordVisible: _isConfirmPasswordVisible,
                onToggleVisibility: () => _togglePasswordVisibility('confirm'),
                isObscured: !_isConfirmPasswordVisible,
              ),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: ElevatedButton(
                  key: ValueKey<bool>(_isLoading),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFormField({
    required TextEditingController controller,
    required String label,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
    required bool isObscured,
  }) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: TextFormField(
        controller: controller,
        obscureText: isObscured,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'DynaPuff',
            fontSize: 16,
          ),
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }
}
