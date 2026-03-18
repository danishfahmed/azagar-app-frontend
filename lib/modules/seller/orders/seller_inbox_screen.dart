import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/modules/seller/orders/seller_chat_screen.dart';
import 'package:azager/modules/seller/orders/seller_orders_screen.dart';

class SellerInboxScreen extends StatelessWidget {
  const SellerInboxScreen({super.key});

  static const _items = [
    _InboxItem(
      customerName: 'John Doe',
      preview: 'I am having issues with my order',
      time: '1:25 PM',
      unread: 2,
      order: SellerOrder(
        id: '1',
        productName: 'Power Bank 5000mah',
        price: 13500,
        orderNumber: '#MB3820',
        date: '25 Feb 2026',
        status: SellerOrderStatus.pending,
        imageAsset: 'assets/images/product1.png',
      ),
    ),
    _InboxItem(
      customerName: 'Amina Yusuf',
      preview: 'Please confirm pickup time',
      time: '11:02 AM',
      unread: 1,
      order: SellerOrder(
        id: '2',
        productName: 'Gold Plated Necklace',
        price: 33500,
        orderNumber: '#MB3821',
        date: '26 Feb 2026',
        status: SellerOrderStatus.toPickup,
        imageAsset: 'assets/images/product2.png',
      ),
    ),
    _InboxItem(
      customerName: 'David K',
      preview: 'Thanks, order received.',
      time: 'Yesterday',
      unread: 0,
      order: SellerOrder(
        id: '3',
        productName: 'Gold Necklace',
        price: 22000,
        orderNumber: '#MB3822',
        date: '27 Feb 2026',
        status: SellerOrderStatus.confirmed,
        imageAsset: 'assets/images/product3.png',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          'Inbox',
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
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SellerChatScreen(order: item.order),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFE3F2FD),
                      child: Text(
                        item.customerName[0],
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.customerName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (item.unread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${item.unread}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InboxItem {
  final String customerName;
  final String preview;
  final String time;
  final int unread;
  final SellerOrder order;

  const _InboxItem({
    required this.customerName,
    required this.preview,
    required this.time,
    required this.unread,
    required this.order,
  });
}
