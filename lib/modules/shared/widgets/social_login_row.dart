import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:azager/core/constants/app_colors.dart';

class SocialLoginRow extends StatelessWidget {
  final String label;

  const SocialLoginRow({super.key, this.label = 'or log in with'});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.lightGrey)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, color: AppColors.grey),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.lightGrey)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              icon: const FaIcon(
                FontAwesomeIcons.google,
                color: AppColors.google,
                size: 22,
              ),
              onTap: () {
                // TODO: Google sign-in
              },
            ),
            const SizedBox(width: 16),
            _SocialButton(
              icon: const FaIcon(
                FontAwesomeIcons.facebook,
                color: AppColors.facebook,
                size: 22,
              ),
              onTap: () {
                // TODO: Facebook sign-in
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Center(child: icon),
      ),
    );
  }
}
