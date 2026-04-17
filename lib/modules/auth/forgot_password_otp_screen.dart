import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/services/auth_service.dart';
import 'package:azager/core/network/api_exception.dart';
import 'package:azager/modules/auth/reset_password_screen.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final String email;

  const ForgotPasswordOtpScreen({super.key, required this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final _authService = AuthService();
  bool _isVerifying = false;
  bool _isResending = false;

  Timer? _resendTimer;
  int _resendCountdown = 30;
  bool get _canResend => _resendCountdown == 0;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    _authService.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final otp = _otpCode;
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 4-digit code.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final response = await _authService.forgotPasswordVerifyOtp(
        email: widget.email,
        otp: otp,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(token: response.token),
        ),
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
          content: Text('Verification failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend || _isResending) return;

    setState(() => _isResending = true);

    try {
      await _authService.forgotPasswordSendOtp(email: widget.email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 2),
        ),
      );
      _startResendTimer();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to resend OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              const Text(
                'Verify Code',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please verify the OTP to reset your password.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 52,
                    height: 52,
                    margin: EdgeInsets.only(left: index == 0 ? 0 : 12),
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.fieldBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.fieldBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Resend link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_canResend)
                    GestureDetector(
                      onTap: _isResending ? null : _resendOtp,
                      child: Text(
                        _isResending ? 'Sending...' : 'Resend it.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Resend in ${_resendCountdown}s',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

              const Spacer(),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
