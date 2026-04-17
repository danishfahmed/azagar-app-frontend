import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/services/session_manager.dart';
import 'package:azager/core/services/home_service.dart';
import 'package:azager/core/models/home_models.dart';
import 'package:azager/modules/shared/screens/onboarding_screen.dart';
import 'package:azager/modules/customer/home/customer_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _homeService = HomeService();
  SplashScreenData? _splashData;

  @override
  void initState() {
    super.initState();
    _loadSplash();
  }

  @override
  void dispose() {
    _homeService.dispose();
    super.dispose();
  }

  Future<void> _loadSplash() async {
    try {
      final response = await _homeService.fetchSplashScreens();
      if (!mounted) return;
      if (response.data.isNotEmpty) {
        setState(() => _splashData = response.data.first);
        await Future.delayed(Duration(seconds: _splashData!.duration));
      } else {
        await Future.delayed(const Duration(seconds: 3));
      }
    } catch (_) {
      // On error, just show fallback for 3 seconds
      await Future.delayed(const Duration(seconds: 3));
    }

    if (!mounted) return;
    _navigate();
  }

  void _navigate() {
    final destination = SessionManager.isLoggedIn
        ? const CustomerShell()
        : const OnboardingScreen();

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: _splashData != null
            ? Image.network(
                _splashData!.image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackLogo(),
              )
            : _fallbackLogo(),
      ),
    );
  }

  Widget _fallbackLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 180,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
            children: [
              TextSpan(
                text: 'aza',
                style: TextStyle(color: AppColors.primary),
              ),
              TextSpan(
                text: 'ger',
                style: TextStyle(color: AppColors.darkGrey),
              ),
            ],
          ),
        );
      },
    );
  }
}
