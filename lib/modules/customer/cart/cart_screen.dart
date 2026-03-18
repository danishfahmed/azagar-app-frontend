import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/constants/dummy_data.dart';
import 'package:azager/core/models/cart_item_model.dart';
import 'package:azager/core/models/product_model.dart';
import 'package:azager/modules/customer/checkout/checkout_screen.dart';
import 'package:azager/modules/customer/product/product_details/product_details_screen.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onBackToShopping;
  const CartScreen({super.key, this.onBackToShopping});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> get _cart => DummyData.cartItems;

  // Saved for later — next 2
  final List<ProductModel> _saved = [
    DummyData.products[3],
    DummyData.products[4],
  ];

  // Suggested — last products
  final List<ProductModel> _suggested = [
    DummyData.products[5],
    DummyData.products[1],
  ];

  final _discountController = TextEditingController();

  String _fmt(double p) =>
      '₦${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  double get _subtotal => _cart.fold(0.0, (s, i) => s + i.total);

  void _removeFromCart(int i) => setState(() => _cart.removeAt(i));

  void _moveToCart(ProductModel p) {
    setState(() {
      _saved.removeWhere((x) => x.id == p.id);
      DummyData.addProductToCart(p);
    });
  }

  void _addSuggestedToCart(ProductModel p) {
    setState(() {
      _suggested.removeWhere((x) => x.id == p.id);
      DummyData.addProductToCart(p);
    });
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppColors.black,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _cart.isEmpty
          ? null
          : _CheckoutBar(
              subtotal: _subtotal,
              total: _subtotal,
              fmt: _fmt,
              onCheckout: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutScreen(cartItems: _cart),
                ),
              ),
            ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ── Cart items or empty state ──────────────────────
          if (_cart.isEmpty)
            _EmptyCartBanner(onBackToShopping: widget.onBackToShopping ?? () {})
          else ...[
            ...List.generate(_cart.length, (i) {
              final item = _cart[i];
              return Dismissible(
                key: ValueKey(item.product.id + i.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                onDismissed: (_) => _removeFromCart(i),
                child: _CartItemCard(
                  item: item,
                  fmt: _fmt,
                  onIncrement: () => setState(() => item.qty++),
                  onDecrement: () =>
                      setState(() => item.qty = (item.qty - 1).clamp(1, 9999)),
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailsScreen(product: item.product),
                    ),
                  ),
                ),
              );
            }),

            // ── Discount code ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: TextField(
                        controller: _discountController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your discount code',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Saved for Later ────────────────────────────────
          if (_saved.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionHeader(title: 'Saved for Later'),
            ..._saved.map(
              (p) => _HorizontalProductTile(
                product: p,
                fmt: _fmt,
                actionLabel: 'Move to Cart',
                actionColor: AppColors.primary,
                onAction: () => _moveToCart(p),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(product: p),
                  ),
                ),
              ),
            ),
          ],

          // ── Suggested Products ─────────────────────────────
          if (_suggested.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionHeader(title: 'Suggested Products'),
            ..._suggested.map(
              (p) => _HorizontalProductTile(
                product: p,
                fmt: _fmt,
                actionLabel: 'Add to Cart',
                actionColor: AppColors.primary,
                onAction: () => _addSuggestedToCart(p),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(product: p),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Empty banner ──────────────────────────────────────────────────────────

class _EmptyCartBanner extends StatelessWidget {
  final VoidCallback onBackToShopping;
  const _EmptyCartBanner({required this.onBackToShopping});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppColors.lightGrey,
          ),
          const SizedBox(height: 12),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Explore our collections and add something\nspecial to your cart.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onBackToShopping,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Back to shopping',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cart item card ────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final String Function(double) fmt;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onEdit;

  const _CartItemCard({
    required this.item,
    required this.fmt,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: const Color(0xFFF0F0F0),
              child: const Icon(
                Icons.image_outlined,
                size: 32,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onEdit,
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFFFFC107)),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Qty control
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: onDecrement,
                            child: const SizedBox(
                              width: 28,
                              height: 30,
                              child: Icon(
                                Icons.remove,
                                size: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 30,
                            color: const Color(0xFFF5F5F5),
                            child: Center(
                              child: Text(
                                '${item.qty}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: onIncrement,
                            child: const SizedBox(
                              width: 28,
                              height: 30,
                              child: Icon(
                                Icons.add,
                                size: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      fmt(item.total),
                      style: const TextStyle(
                        fontSize: 15,
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
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

// ── Horizontal product tile ───────────────────────────────────────────────

class _HorizontalProductTile extends StatelessWidget {
  final ProductModel product;
  final String Function(double) fmt;
  final String actionLabel;
  final Color actionColor;
  final VoidCallback onAction;
  final VoidCallback onTap;

  const _HorizontalProductTile({
    required this.product,
    required this.fmt,
    required this.actionLabel,
    required this.actionColor,
    required this.onAction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 64,
                height: 64,
                color: const Color(0xFFF0F0F0),
                child: const Icon(
                  Icons.image_outlined,
                  size: 28,
                  color: Color(0xFFBDBDBD),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
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
                        '${product.rating}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              fmt(product.price),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Checkout bottom bar ──────────────────────────────────────────────────

class _CheckoutBar extends StatelessWidget {
  final double subtotal;
  final double total;
  final String Function(double) fmt;
  final VoidCallback onCheckout;

  const _CheckoutBar({
    required this.subtotal,
    required this.total,
    required this.fmt,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                fmt(subtotal),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                fmt(total),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
