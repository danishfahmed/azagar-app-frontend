import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/models/seller_product_model.dart';
import 'package:azager/modules/seller/products/add_product_screen.dart';
import 'package:azager/modules/seller/products/edit_product_screen.dart';

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  // Demo products – replace with real data from your backend.
  final List<SellerProduct> _products = [
    SellerProduct(
      id: '1',
      name: 'Ruffle bag',
      category: 'Bags',
      description: 'Elegant ruffle bag for everyday use.',
      price: 11500,
      stockQuantity: 8,
      sku: 'BAG-RUF-10001',
      imageUrls: ['assets/images/product1.png'],
      variants: [
        ProductVariant(color: 'Red', size: 'Small', price: 11500, stock: 4),
        ProductVariant(color: 'Red', size: 'Large', price: 13000, stock: 4),
      ],
    ),
    SellerProduct(
      id: '2',
      name: 'Ruffle bag',
      category: 'Bags',
      description: 'Compact ruffle bag.',
      price: 11500,
      stockQuantity: 5,
      sku: 'BAG-RUF-10002',
      imageUrls: ['assets/images/product2.png'],
    ),
    SellerProduct(
      id: '3',
      name: 'Ruffle bag',
      category: 'Bags',
      description: 'Premium ruffle bag.',
      price: 11500,
      stockQuantity: 3,
      sku: 'BAG-RUF-10003',
      imageUrls: ['assets/images/product3.png'],
    ),
    SellerProduct(
      id: '4',
      name: 'Ruffle bag',
      category: 'Bags',
      description: 'Classic ruffle bag.',
      price: 11500,
      stockQuantity: 6,
      sku: 'BAG-RUF-10004',
      imageUrls: ['assets/images/product4.png'],
      isActive: false,
    ),
  ];

  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${_products[index].name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _products.removeAt(index));
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleActive(int index) {
    setState(() {
      _products[index].isActive = !_products[index].isActive;
    });
    final status = _products[index].isActive ? 'activated' : 'deactivated';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Product $status'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _openAddProduct() async {
    final result = await Navigator.push<SellerProduct>(
      context,
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
    if (result != null) {
      setState(() => _products.add(result));
    }
  }

  Future<void> _openEditProduct(int index) async {
    final result = await Navigator.push<SellerProduct>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductScreen(product: _products[index]),
      ),
    );
    if (result != null) {
      setState(() => _products[index] = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: _openAddProduct,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                '+ Add Product',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: _products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: AppColors.lightGrey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No products yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Add products to your store',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.58,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return _ProductCard(
                  product: _products[index],
                  onEdit: () => _openEditProduct(index),
                  onToggle: () => _toggleActive(index),
                  onDelete: () => _deleteProduct(index),
                );
              },
            ),
    );
  }
}

// ─── Product Card ────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final SellerProduct product;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: product.imageUrls.isNotEmpty
                        ? Image.asset(
                            product.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _ProductPlaceholder(name: product.name),
                          )
                        : _ProductPlaceholder(name: product.name),
                  ),
                  if (!product.isActive)
                    Container(
                      color: Colors.black38,
                      alignment: Alignment.center,
                      child: Text(
                        'Inactive',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Info ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₦${_fmt(product.price)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Quick‑action buttons ──
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
            child: Row(
              children: [
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  color: AppColors.primary,
                  bgColor: const Color(0xFFFFF3E0),
                  tooltip: 'Edit',
                  onTap: onEdit,
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: product.isActive
                      ? Icons.toggle_on
                      : Icons.toggle_off_outlined,
                  color: product.isActive
                      ? const Color(0xFF43A047)
                      : AppColors.grey,
                  bgColor: product.isActive
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFF5F5F5),
                  tooltip: product.isActive ? 'Deactivate' : 'Activate',
                  onTap: onToggle,
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: Icons.delete_outline,
                  color: Colors.red,
                  bgColor: const Color(0xFFFCE4EC),
                  tooltip: 'Delete',
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return v.toStringAsFixed(2);
  }
}

// ─── Product image placeholder ────────────────────────────────────────────────

class _ProductPlaceholder extends StatelessWidget {
  final String name;
  const _ProductPlaceholder({required this.name});

  static const _colors = [
    Color(0xFFFFF3E0),
    Color(0xFFE3F2FD),
    Color(0xFFE8F5E9),
    Color(0xFFFCE4EC),
    Color(0xFFEDE7F6),
    Color(0xFFF3E5F5),
  ];

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color = _colors[initial.codeUnitAt(0) % _colors.length];
    return Container(
      color: color,
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
