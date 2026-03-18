import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/modules/customer/profile/help_topic_detail_screen.dart';
import 'package:azager/modules/customer/profile/support_chat_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const Map<String, List<String>> _topicFaqs = {
    'Orders & Delivery': [
      'How do I track my order?\nOpen your Orders page and tap an item to view live status updates.',
      'How long does delivery take?\nMost campus deliveries are completed within 24 to 48 hours.',
      'Can I change delivery address after placing an order?\nYes, before the seller marks the order as shipped.',
    ],
    'Returns & Refunds': [
      'How do I request a return?\nGo to Orders, open the order, and choose Request Return.',
      'When will I get my refund?\nRefunds are processed after verification and may take 3 to 7 business days.',
      'Can I return used items?\nOnly unused items in original condition are eligible unless damaged on arrival.',
    ],
    'Payment Issues': [
      'Why did my payment fail?\nCheck card balance, network stability, and OTP completion, then retry.',
      'I was charged twice. What should I do?\nContact support with transaction reference for prompt reversal.',
      'Which payment methods are supported?\nCard, wallet balance, and available campus-supported payment options.',
    ],
    'Account & Security': [
      'How do I change my password?\nOpen Settings > Change Password and submit your new password.',
      'How do I secure my account?\nUse a strong password and never share OTP or login details.',
      'How can I report suspicious activity?\nUse Help Center chat support immediately with account details.',
    ],
    'Product Questions': [
      'How do I ask a seller about a product?\nOpen the product page and use available chat/contact option.',
      'Can I request product variations?\nYes, message the seller to confirm available colors or sizes.',
      'What if product details are unclear?\nAsk for photos/specifications before placing the order.',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
          'Help Center',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),

          // Search bar
          Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, size: 20, color: AppColors.grey),
                SizedBox(width: 8),
                Text(
                  'Search help articles...',
                  style: TextStyle(fontSize: 13, color: AppColors.textHint),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'Popular Topics',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          ...[
            ('Orders & Delivery', Icons.local_shipping_outlined),
            ('Returns & Refunds', Icons.replay_outlined),
            ('Payment Issues', Icons.payment_outlined),
            ('Account & Security', Icons.lock_outline),
            ('Product Questions', Icons.help_outline),
          ].map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(item.$2, size: 22, color: AppColors.primary),
                title: Text(
                  item.$1,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.grey,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HelpTopicDetailScreen(
                      title: item.$1,
                      faqs: _topicFaqs[item.$1] ?? const [],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "Can't find what you need?",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportChatScreen()),
              ),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text(
                'Chat with Support',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
