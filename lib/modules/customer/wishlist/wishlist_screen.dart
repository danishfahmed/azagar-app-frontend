import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/constants/dummy_data.dart';
import 'package:azager/core/models/product_model.dart';
import 'package:azager/core/network/api_exception.dart';
import 'package:azager/core/services/product_service.dart';
import 'package:azager/modules/customer/product/product_details/product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _wishlistService = WishlistService();

  bool _isLoading = true;
  String? _error;
  List<ProductModel> _items = const [];

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  @override
  void dispose() {
    _wishlistService.dispose();
    super.dispose();
  }

  Future<void> _fetchWishlist() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _wishlistService.getWishlist();
      if (!mounted) return;
      setState(() {
        _items = items.map((e) => e.copyWith(isFavorite: true)).toList();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load wishlist right now.';
        _isLoading = false;
      });
    }
  }

  Future<void> _remove(ProductModel product) async {
    final old = _items;
    setState(() {
      _items = _items.where((x) => x.id != product.id).toList();
    });

    try {
      await _wishlistService.toggleFavorite(
        productId: product.id,
        currentFavoriteState: true,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _items = old);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not remove item from wishlist'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatPrice(double price) =>
      '₦${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Wishlist',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _fetchWishlist,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 72,
                    color: AppColors.lightGrey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _fetchWishlist,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _WishlistCard(
                  product: _items[i],
                  onRemove: () => _remove(_items[i]),
                  formatPrice: _formatPrice,
                  onAddToCart: () {
                    DummyData.addProductToCart(_items[i]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${_items[i].name} added to cart'),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: _items[i]),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;
  final String Function(double) formatPrice;

  const _WishlistCard({
    required this.product,
    required this.onRemove,
    required this.onAddToCart,
    required this.onTap,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = product.imageUrl.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: SizedBox(
                width: 100,
                child: isNetwork
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      )
                    : Image.asset(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        GestureDetector(
                          onTap: onRemove,
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatPrice(product.price),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            if (product.originalPrice != null)
                              Text(
                                formatPrice(product.originalPrice!),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: onAddToCart,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFF0F0F0),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 40, color: Color(0xFFBDBDBD)),
      ),
    );
  }
}
