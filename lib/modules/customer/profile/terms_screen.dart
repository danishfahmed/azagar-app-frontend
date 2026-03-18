import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          'Terms & Conditions',
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
        children: const [
          _Section(
            title: '1. Acceptance of Terms',
            body:
                'By accessing or using Azager, you agree to be bound by these Terms and Conditions and all applicable laws and regulations. If you do not agree with any of these terms, you are prohibited from using or accessing this application.',
          ),
          _Section(
            title: '2. Use of Service',
            body:
                'Azager is a campus marketplace platform. You agree to use the service only for lawful purposes and in a way that does not infringe the rights of others or restrict their use of the service. Prohibited activities include but are not limited to fraud, harassment, and selling counterfeit goods.',
          ),
          _Section(
            title: '3. User Accounts',
            body:
                'You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized use of your account. Azager will not be liable for any loss resulting from unauthorized use of your account.',
          ),
          _Section(
            title: '4. Buyer & Seller Responsibilities',
            body:
                'Sellers are responsible for the accuracy, legality, and quality of listed products. Buyers are responsible for making payments promptly. Azager acts only as a platform facilitating transactions and is not responsible for disputes between buyers and sellers.',
          ),
          _Section(
            title: '5. Privacy Policy',
            body:
                'Your use of Azager is also governed by our Privacy Policy, which is incorporated by reference into these Terms. We collect and process personal data as described in our Privacy Policy.',
          ),
          _Section(
            title: '6. Intellectual Property',
            body:
                'All content on Azager, including logos, text, and software, is the property of Azager and is protected by applicable intellectual property laws. You may not copy, reproduce, or distribute any content without prior written consent.',
          ),
          _Section(
            title: '7. Limitation of Liability',
            body:
                'Azager shall not be liable for any indirect, incidental, or consequential damages arising from the use of or inability to use the service. Our total liability shall not exceed the amount paid by you in the last 30 days.',
          ),
          _Section(
            title: '8. Modifications',
            body:
                'Azager reserves the right to modify these Terms at any time. Continued use of the platform after changes constitutes acceptance of the updated terms. We will notify users of significant changes.',
          ),
          _Section(
            title: '9. Governing Law',
            body:
                'These Terms are governed by the laws of the Federal Republic of Nigeria. Any disputes shall be resolved in the courts of jurisdiction applicable to the registered business address of Azager.',
          ),
          _Section(
            title: '10. Contact Us',
            body:
                'If you have questions about these Terms & Conditions, please contact us at support@azager.com.',
          ),
          SizedBox(height: 20),
          Text(
            'Last updated: March 11, 2026',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
