import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';

class SellerTransactionHistoryScreen extends StatelessWidget {
  const SellerTransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const transactions = [
      _TxnItem(
        title: 'Order Payment',
        date: 'Mar 16, 2026 • 09:10 AM',
        amount: '+₦13,500',
        isCredit: true,
      ),
      _TxnItem(
        title: 'Withdrawal',
        date: 'Mar 15, 2026 • 02:40 PM',
        amount: '-₦8,000',
        isCredit: false,
      ),
      _TxnItem(
        title: 'Refund Adjustment',
        date: 'Mar 12, 2026 • 11:30 AM',
        amount: '-₦2,000',
        isCredit: false,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transaction History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final txn = transactions[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: txn.isCredit
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    txn.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 16,
                    color: txn.isCredit
                        ? const Color(0xFF43A047)
                        : const Color(0xFFE53935),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        txn.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  txn.amount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: txn.isCredit
                        ? const Color(0xFF43A047)
                        : const Color(0xFFE53935),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TxnItem {
  final String title;
  final String date;
  final String amount;
  final bool isCredit;

  const _TxnItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
  });
}
