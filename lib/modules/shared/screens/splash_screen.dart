import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/modules/shared/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 180,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image not yet added
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
        ),
      ),
    );
  }
}
