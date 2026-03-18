import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:azager/core/constants/app_colors.dart';

class VouchersScreen extends StatelessWidget {
  const VouchersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vouchers = [
      _Voucher(
        code: 'WELCOME20',
        description: '20% off your first order',
        expiry: 'Expires Mar 31, 2026',
        discount: '20%',
        isActive: true,
      ),
      _Voucher(
        code: 'CAMPUS50',
        description: '₦500 off orders above ₦5,000',
        expiry: 'Expires Apr 15, 2026',
        discount: '₦500',
        isActive: true,
      ),
      _Voucher(
        code: 'FREEDEL',
        description: 'Free delivery on any order',
        expiry: 'Expired Jan 1, 2026',
        discount: 'FREE',
        isActive: false,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          'Vouchers',
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
          // Voucher input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter voucher code',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textHint,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'My Vouchers',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 10),

          ...vouchers.map(
            (v) => Opacity(
              opacity: v.isActive ? 1.0 : 0.5,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: v.isActive
                        ? AppColors.primaryLight
                        : AppColors.lightGrey,
                  ),
                ),
                child: Row(
                  children: [
                    // Discount badge
                    Container(
                      width: 70,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: v.isActive
                            ? AppColors.primaryLight
                            : const Color(0xFFF0F0F0),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            v.discount,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: v.isActive
                                  ? AppColors.primary
                                  : AppColors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (v.discount != 'FREE')
                            Text(
                              'OFF',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: v.isActive
                                    ? AppColors.primary
                                    : AppColors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Divider dash
                    Column(
                      children: List.generate(
                        5,
                        (i) => Container(
                          width: 1,
                          height: 8,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: AppColors.lightGrey,
                        ),
                      ),
                    ),

                    // Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  v.code,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 1,
                                  ),
                                ),
                                if (v.isActive)
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(text: v.code),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Code copied!'),
                                          duration: Duration(seconds: 1),
                                          backgroundColor: AppColors.primary,
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.copy_outlined,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              v.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              v.expiry,
                              style: TextStyle(
                                fontSize: 11,
                                color: v.isActive
                                    ? AppColors.primary
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Voucher {
  final String code;
  final String description;
  final String expiry;
  final String discount;
  final bool isActive;
  const _Voucher({
    required this.code,
    required this.description,
    required this.expiry,
    required this.discount,
    required this.isActive,
  });
}
