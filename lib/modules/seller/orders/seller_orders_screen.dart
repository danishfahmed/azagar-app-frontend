import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/modules/seller/orders/seller_order_details_screen.dart';

// ─────────────────────────── Model ───────────────────────────

enum SellerOrderStatus { pending, confirmed, toShip, toPickup, cancelled }

class SellerOrder {
  final String id;
  final String productName;
  final int price;
  final String orderNumber;
  final String date;
  final SellerOrderStatus status;
  final String imageAsset;

  const SellerOrder({
    required this.id,
    required this.productName,
    required this.price,
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.imageAsset,
  });
}

// ────────────────────────── Screen ───────────────────────────

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _searchCtrl = TextEditingController();

  void _showQuickFilterSheet() {
    final options = [
      ('All Orders', 0),
      ('Pending', 1),
      ('To Ship', 2),
      ('To Pickup', 3),
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (item) => ListTile(
                  title: Text(item.$1),
                  trailing: _tab.index == item.$2
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    _tab.animateTo(item.$2);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  static const _summary = [
    _SumItem('All Orders', 102, null),
    _SumItem('Pending', 102, Color(0xFFE98610)),
    _SumItem('Pickup', 102, Color(0xFF43A047)),
    _SumItem('Cancelled', 102, Color(0xFFE53935)),
  ];

  final _orders = const [
    SellerOrder(
      id: '1',
      productName: 'Power Bank 5000mah',
      price: 13500,
      orderNumber: '#MB3820',
      date: '25 Feb 2026',
      status: SellerOrderStatus.pending,
      imageAsset: 'assets/images/product1.png',
    ),
    SellerOrder(
      id: '2',
      productName: 'Gold Plated Necklace',
      price: 33500,
      orderNumber: '#MB3820',
      date: '25 Feb 2026',
      status: SellerOrderStatus.pending,
      imageAsset: 'assets/images/product2.png',
    ),
    SellerOrder(
      id: '3',
      productName: 'Gold Necklace',
      price: 22000,
      orderNumber: '#MB3821',
      date: '25 Feb 2026',
      status: SellerOrderStatus.toShip,
      imageAsset: 'assets/images/product3.png',
    ),
  ];

  List<SellerOrder> _filtered(int tabIndex) {
    final q = _searchCtrl.text.toLowerCase();
    final list = tabIndex == 0
        ? _orders
        : _orders.where((o) {
            switch (tabIndex) {
              case 1:
                return o.status == SellerOrderStatus.pending;
              case 2:
                return o.status == SellerOrderStatus.toShip;
              case 3:
                return o.status == SellerOrderStatus.toPickup;
              default:
                return true;
            }
          }).toList();
    if (q.isEmpty) return list;
    return list.where((o) => o.productName.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

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
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.fieldBorder),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search Product',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.textHint,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.grey,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _showQuickFilterSheet,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.tune, size: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ── Summary card ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _summary
                        .map((s) => _SummaryChip(item: s))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // ── Tabs ─────────────────────────────────────────────
          TabBar(
            controller: _tab,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant,
            labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 13),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'All Orders (102)'),
              Tab(text: 'Pending (40)'),
              Tab(text: 'To Ship (32)'),
              Tab(text: 'To Pickup'),
            ],
          ),

          // ── Order list ───────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: List.generate(
                4,
                (i) => AnimatedBuilder(
                  animation: _searchCtrl,
                  builder: (_, __) {
                    final list = _filtered(i);
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'No orders found',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, idx) => _OrderCard(order: list[idx]),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────── Sub-widgets ──────────────────────────

class _SumItem {
  final String label;
  final int count;
  final Color? valueColor;
  const _SumItem(this.label, this.count, this.valueColor);
}

class _SummaryChip extends StatelessWidget {
  final _SumItem item;
  const _SummaryChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '${item.count}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: item.valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final SellerOrder order;
  const _OrderCard({required this.order}) : super();

  Color get _statusColor {
    switch (order.status) {
      case SellerOrderStatus.pending:
        return const Color(0xFFE98610);
      case SellerOrderStatus.confirmed:
        return const Color(0xFF43A047);
      case SellerOrderStatus.toShip:
        return const Color(0xFF1976D2);
      case SellerOrderStatus.toPickup:
        return const Color(0xFF7B1FA2);
      case SellerOrderStatus.cancelled:
        return const Color(0xFFE53935);
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case SellerOrderStatus.pending:
        return 'Pending';
      case SellerOrderStatus.confirmed:
        return 'Confirmed';
      case SellerOrderStatus.toShip:
        return 'To Ship';
      case SellerOrderStatus.toPickup:
        return 'To Pickup';
      case SellerOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SellerOrderDetailsScreen(order: order),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Product image
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  order.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.lightGrey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.productName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Price: ₦${order.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')} ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.orderNumber} · ${order.date}',
                    style: TextStyle(fontSize: 11, color: AppColors.grey),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
