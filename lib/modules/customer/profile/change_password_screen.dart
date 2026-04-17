import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/services/auth_service.dart';
import 'package:azager/core/network/api_exception.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _authService = AuthService();
  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_currentCtrl.text.trim().isEmpty ||
        _newCtrl.text.trim().isEmpty ||
        _confirmCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all password fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password and confirm password do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.changePassword(
        currentPassword: _currentCtrl.text.trim(),
        password: _newCtrl.text.trim(),
        passwordConfirmation: _confirmCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    } on ApiValidationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _label('Current Password'),
          const SizedBox(height: 8),
          _passwordField(
            controller: _currentCtrl,
            hint: 'Enter current password',
            obscureText: _hideCurrent,
            onToggle: () => setState(() => _hideCurrent = !_hideCurrent),
          ),
          const SizedBox(height: 16),
          _label('New Password'),
          const SizedBox(height: 8),
          _passwordField(
            controller: _newCtrl,
            hint: 'Enter new password',
            obscureText: _hideNew,
            onToggle: () => setState(() => _hideNew = !_hideNew),
          ),
          const SizedBox(height: 16),
          _label('Confirm Password'),
          const SizedBox(height: 8),
          _passwordField(
            controller: _confirmCtrl,
            hint: 'Confirm new password',
            obscureText: _hideConfirm,
            onToggle: () => setState(() => _hideConfirm = !_hideConfirm),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Update Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.grey,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
