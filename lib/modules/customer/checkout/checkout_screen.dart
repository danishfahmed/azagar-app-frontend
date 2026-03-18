import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/models/cart_item_model.dart';
import 'package:azager/core/models/product_model.dart';
import 'package:azager/modules/customer/checkout/payment_methods_screen.dart';
import 'package:azager/modules/customer/checkout/addresses_screen.dart';
import 'package:azager/modules/customer/checkout/order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  const CheckoutScreen({super.key, required this.cartItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ── Delivery address ─────────────────────────────────
  int _selectedAddress = 0;
  final List<Map<String, String>> _addresses = [
    {'label': 'Home', 'line1': 'Anywhere 123', 'line2': 'City 9945'},
    {'label': 'Office', 'line1': 'Anywhere 123', 'line2': 'City 3440'},
  ];

  // ── Payment ──────────────────────────────────────────
  String _paymentMethod = 'Card';
  String _paymentDetail = '**** **** **** 3947';

  // ── Delivery method state ────────────────────────────
  // If common delivery methods exist → single selection
  // If no common methods → per-product selection
  late final bool _hasCommonMethods;
  late final List<DeliveryMethod> _commonMethods;

  /// Per-product delivery selections (productId → method name)
  final Map<String, String> _perProductSelection = {};

  /// Global selected method name (when common methods available)
  String? _selectedMethod;

  // ── Multiple sellers ─────────────────────────────────
  late final bool _multiSeller;

  String _fmt(double p) =>
      '₦${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  void initState() {
    super.initState();
    _computeDeliveryLogic();
  }

  void _computeDeliveryLogic() {
    final items = widget.cartItems;

    // Check multiple sellers
    final sellerIds = items.map((e) => e.product.sellerId).toSet();
    _multiSeller = sellerIds.length > 1;

    // Compute common delivery method names
    if (items.isEmpty) {
      _hasCommonMethods = false;
      _commonMethods = [];
      return;
    }

    Set<String> common = items.first.product.deliveryMethods
        .map((m) => m.name)
        .toSet();
    for (final item in items.skip(1)) {
      common = common.intersection(
        item.product.deliveryMethods.map((m) => m.name).toSet(),
      );
    }

    _hasCommonMethods = common.isNotEmpty;

    if (_hasCommonMethods) {
      // Build summed-price list
      _commonMethods = common.map((name) {
        double total = 0;
        for (final item in items) {
          final dm = item.product.deliveryMethods.firstWhere(
            (m) => m.name == name,
          );
          total += dm.price;
        }
        return DeliveryMethod(name: name, price: total);
      }).toList()..sort((a, b) => a.price.compareTo(b.price));

      _selectedMethod = _commonMethods.first.name;
    } else {
      _commonMethods = [];
      // Default each product to its first available method
      for (final item in items) {
        _perProductSelection[item.product.id] =
            item.product.deliveryMethods.first.name;
      }
    }

    // If multi-seller, force online payment
    if (_multiSeller) {
      _paymentMethod = 'Paystack';
      _paymentDetail = 'Online payment';
    }
  }

  double get _subtotal => widget.cartItems.fold(0.0, (s, i) => s + i.total);

  double get _deliveryCharges {
    if (_hasCommonMethods && _selectedMethod != null) {
      return _commonMethods.firstWhere((m) => m.name == _selectedMethod).price;
    }
    double total = 0;
    for (final item in widget.cartItems) {
      final sel = _perProductSelection[item.product.id];
      if (sel != null) {
        final dm = item.product.deliveryMethods.firstWhere(
          (m) => m.name == sel,
        );
        total += dm.price;
      }
    }
    return total;
  }

  double get _total => _subtotal + _deliveryCharges;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
          'Checkout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _ConfirmBar(
        total: _total,
        fmt: _fmt,
        onConfirm: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderConfirmationScreen()),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ── Shipping Address ──────────────────────────
          _SectionCard(
            children: [
              _SectionHeader(
                title: 'Shipping Address',
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddressesScreen()),
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(_addresses.length, (i) {
                final a = _addresses[i];
                final active = i == _selectedAddress;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAddress = i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active ? AppColors.primary : AppColors.lightGrey,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          active
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 20,
                          color: active ? AppColors.primary : AppColors.grey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a['label']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${a['line1']}\n${a['line2']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),

          // ── Payment Method ───────────────────────────
          _SectionCard(
            children: [
              _SectionHeader(
                title: 'Payment Method',
                onEdit: _multiSeller
                    ? null
                    : () async {
                        final result =
                            await Navigator.push<Map<String, String>>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PaymentMethodsScreen(),
                              ),
                            );
                        if (result != null && mounted) {
                          setState(() {
                            _paymentMethod = result['method'] ?? _paymentMethod;
                            _paymentDetail = result['detail'] ?? _paymentDetail;
                          });
                        }
                      },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _paymentMethod == 'Card'
                        ? Icons.credit_card
                        : _paymentMethod == 'Bank Transfer'
                        ? Icons.account_balance
                        : _paymentMethod == 'COD'
                        ? Icons.money
                        : Icons.payment,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_paymentMethod  $_paymentDetail',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (_multiSeller) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFFF9A825),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Your cart has items from multiple sellers. Only online payment (Paystack) is available. Cash on Delivery is not supported for multi-seller orders.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6D4C00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          // ── Delivery Method ──────────────────────────
          _SectionCard(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Delivery Method',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (_hasCommonMethods) ...[
                ..._commonMethods.map(
                  (m) => _DeliveryOptionTile(
                    name: m.name,
                    price: m.price,
                    fmt: _fmt,
                    selected: m.name == _selectedMethod,
                    onTap: () => setState(() => _selectedMethod = m.name),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFF388E3C),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Only delivery methods common to all cart items are shown. The price is the combined delivery cost across all items.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'No common delivery method is available for all items. Please choose a method for each product individually.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                ...widget.cartItems.map((item) {
                  final sel =
                      _perProductSelection[item.product.id] ??
                      item.product.deliveryMethods.first.name;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 4),
                        child: Text(
                          item.product.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      ...item.product.deliveryMethods.map(
                        (m) => _DeliveryOptionTile(
                          name: m.name,
                          price: m.price,
                          fmt: _fmt,
                          selected: m.name == sel,
                          onTap: () => setState(
                            () =>
                                _perProductSelection[item.product.id] = m.name,
                          ),
                        ),
                      ),
                      const Divider(height: 16),
                    ],
                  );
                }),
              ],
            ],
          ),

          // ── Order List ───────────────────────────────
          _SectionCard(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Order List',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...widget.cartItems.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF0F0F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 56,
                          height: 56,
                          color: const Color(0xFFF0F0F0),
                          child: const Icon(
                            Icons.image_outlined,
                            size: 24,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 14,
                                  color: AppColors.grey,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Color(0xFFFFC107),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${item.product.rating}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                // Qty controls
                                Container(
                                  height: 28,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.lightGrey,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () => setState(
                                          () => item.qty = (item.qty - 1).clamp(
                                            1,
                                            9999,
                                          ),
                                        ),
                                        child: const SizedBox(
                                          width: 26,
                                          height: 28,
                                          child: Icon(
                                            Icons.remove,
                                            size: 13,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 26,
                                        height: 28,
                                        color: const Color(0xFFF5F5F5),
                                        child: Center(
                                          child: Text(
                                            '${item.qty}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => setState(() => item.qty++),
                                        child: const SizedBox(
                                          width: 26,
                                          height: 28,
                                          child: Icon(
                                            Icons.add,
                                            size: 13,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _fmt(item.total),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Price summary ────────────────────────────
          _SectionCard(
            children: [
              _PriceRow(label: 'Subtotal', value: _fmt(_subtotal)),
              const SizedBox(height: 4),
              _PriceRow(
                label: 'Delivery Charges',
                value: _deliveryCharges == 0 ? 'Free' : _fmt(_deliveryCharges),
              ),
              const Divider(height: 16),
              _PriceRow(label: 'Total Cost', value: _fmt(_total), bold: true),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section card wrapper ──────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ── Section header with optional edit ─────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onEdit;
  const _SectionHeader({required this.title, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (onEdit != null)
          GestureDetector(
            onTap: onEdit,
            child: const Text(
              'Edit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Delivery option tile ──────────────────────────────────────────────────

class _DeliveryOptionTile extends StatelessWidget {
  final String name;
  final double price;
  final String Function(double) fmt;
  final bool selected;
  final VoidCallback onTap;

  const _DeliveryOptionTile({
    required this.name,
    required this.price,
    required this.fmt,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected ? AppColors.primary : AppColors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              price == 0 ? 'Free' : fmt(price),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: price == 0
                    ? const Color(0xFF388E3C)
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Price row ─────────────────────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: bold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: bold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Bottom confirm bar ────────────────────────────────────────────────────

class _ConfirmBar extends StatelessWidget {
  final double total;
  final String Function(double) fmt;
  final VoidCallback onConfirm;

  const _ConfirmBar({
    required this.total,
    required this.fmt,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  fmt(total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Confirm Payment',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
