import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/constants/dummy_data.dart';
import 'package:azager/core/models/product_model.dart';
import 'package:azager/core/network/api_exception.dart';
import 'package:azager/core/services/product_service.dart';
import 'package:azager/modules/customer/product/product_details/image_viewer_screen.dart';
import 'package:azager/modules/customer/checkout/review_screen.dart';
import 'package:azager/modules/shared/widgets/product_card.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _productService = ProductService();
  final _wishlistService = WishlistService();

  int _selectedImage = 0;
  int _selectedColor = 0;
  int _selectedDelivery = 0;
  int _qty = 1;
  bool _wishlisted = false;
  bool _expanded = false;
  bool _isLoadingDetails = false;

  ProductModel? _product;
  List<ProductModel> _relatedProducts = const [];

  final PageController _pageController = PageController();

  static const List<Color> _colors = [
    Color(0xFF5C6BC0),
    Color(0xFF42A5F5),
    Color(0xFF1A1A1A),
    Color(0xFF8D6E63),
  ];

  // Placeholder colours for thumbnail strip (when no image)
  static const List<Color> _placeholderColors = [
    Color(0xFFEEEEEE),
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
    Color(0xFFE8F5E9),
  ];

  List<Map<String, String>> get _deliveryOptions {
    final methods = _currentProduct.deliveryMethods;
    if (methods.isEmpty) {
      return const [
        {'label': 'Doorstep', 'price': '₦2,500'},
        {'label': 'Pickup', 'price': 'FREE'},
      ];
    }
    return methods.map((m) {
      final priceStr = m.price <= 0 ? 'FREE' : _formatPrice(m.price);
      return {'label': m.name, 'price': priceStr};
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _wishlisted = widget.product.isFavorite;
    _loadProductDetails();
  }

  List<String> get _imageAssets {
    final product = _currentProduct;
    if (product.images.isNotEmpty) return product.images;
    if (product.imageUrl.isEmpty) return [];
    return [product.imageUrl];
  }

  ProductModel get _currentProduct => _product ?? widget.product;

  @override
  void dispose() {
    _pageController.dispose();
    _productService.dispose();
    _wishlistService.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetails() async {
    if (widget.product.id.isEmpty) return;
    setState(() => _isLoadingDetails = true);

    try {
      final details = await _productService.getProductDetails(
        productId: widget.product.id,
      );
      if (!mounted) return;
      setState(() {
        _product = details.product;
        _relatedProducts = details.relatedProducts;
        _wishlisted = details.product.isFavorite;
        _isLoadingDetails = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingDetails = false);
    }
  }

  Future<void> _toggleWishlist() async {
    final product = _currentProduct;
    if (product.id.isEmpty) return;

    final old = _wishlisted;
    setState(() => _wishlisted = !_wishlisted);

    try {
      final value = await _wishlistService.toggleFavorite(
        productId: product.id,
        currentFavoriteState: old,
      );
      if (!mounted) return;
      setState(() {
        _wishlisted = value;
        _product = _currentProduct.copyWith(isFavorite: value);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _wishlisted = old);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _wishlisted = old);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update wishlist'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openGallery() {
    final assets = _imageAssets;
    if (assets.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageViewerScreen(
          imageAssets: assets,
          initialIndex: _selectedImage,
        ),
      ),
    );
  }

  void _showQtyDialog() {
    final controller = TextEditingController(text: '$_qty');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enter Quantity'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. 100'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final v = int.tryParse(controller.text) ?? 1;
              setState(() => _qty = v.clamp(1, 9999));
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart(ProductModel product) {
    DummyData.addProductToCart(product, qty: _qty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_qty × ${product.name} to cart'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleBuyNow(ProductModel product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Buying $_qty × ${product.name}'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatPrice(double price) =>
      '₦${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    final product = _currentProduct;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 1000;
    final fallbackDesc =
        'The ${product.name} Power Bank is a high-capacity portable charger designed for fast and reliable performance.\n\n'
        'Its massive battery provides enough full charges for most smartphones, making it ideal for travel and daily use.\n\n'
        'With 22.5W fast charging and PD Power, it can charge compatible devices up to 40% in just 30 minutes while maintaining a smart temperature control and charging speed.\n\n'
        'It features a smart digital display to show the remaining battery level.\n\n'
        'Built-in active protection ensures secure and efficient charging every time.';
    final desc = product.description?.trim().isNotEmpty == true
        ? product.description!
        : fallbackDesc;
    final relatedProducts = _relatedProducts.isNotEmpty
        ? _relatedProducts
        : DummyData.products;

    if (isWide) {
      return Scaffold(
        backgroundColor: AppColors.scaffold,
        body: _buildWideLayout(product: product, description: desc),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      // ── Fixed bottom bar ─────────────────────────────────────
      bottomNavigationBar: _BottomBar(
        qty: _qty,
        onDecrement: () => setState(() => _qty = (_qty - 1).clamp(1, 9999)),
        onIncrement: () => setState(() => _qty++),
        onQtyTap: _showQtyDialog,
        onAddToCart: () => _handleAddToCart(product),
      ),
      body: CustomScrollView(
        slivers: [
          if (_isLoadingDetails)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(color: AppColors.primary),
            ),
          // ── Image section ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Main image pager
                GestureDetector(
                  onTap: _openGallery,
                  child: SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _imageAssets.isNotEmpty
                          ? _imageAssets.length
                          : 1,
                      onPageChanged: (i) => setState(() => _selectedImage = i),
                      itemBuilder: (_, i) {
                        final assets = _imageAssets;
                        if (assets.isNotEmpty) {
                          return _buildProductImage(
                            image: assets[i],
                            fit: BoxFit.cover,
                            fallbackIndex: i,
                            letter: _currentProduct.name.isNotEmpty
                                ? _currentProduct.name[0].toUpperCase()
                                : '?',
                          );
                        }
                        return Container(
                          color:
                              _placeholderColors[i % _placeholderColors.length],
                          child: Center(
                            child: Text(
                              widget.product.name.isNotEmpty
                                  ? widget.product.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Back button
                Positioned(
                  top: 44,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),

                // Wishlist button
                Positioned(
                  top: 44,
                  right: 16,
                  child: GestureDetector(
                    onTap: _toggleWishlist,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _wishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: _wishlisted
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

                // Page dots
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _imageAssets.isNotEmpty ? _imageAssets.length : 1,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _selectedImage == i ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _selectedImage == i
                              ? AppColors.primary
                              : AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Thumbnail strip ────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              height: 68,
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _imageAssets.isNotEmpty ? _imageAssets.length : 1,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedImage == i
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _imageAssets.isNotEmpty
                          ? _buildProductImage(
                              image: _imageAssets[i],
                              fit: BoxFit.cover,
                              fallbackIndex: i,
                              letter: '',
                            )
                          : Container(
                              color:
                                  _placeholderColors[i %
                                      _placeholderColors.length],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Product info ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price row
                  Row(
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (product.originalPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatPrice(product.originalPrice!),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Rating + OMAX tag
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewScreen(
                          productName: product.name,
                          productId: product.id,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating}  ${product.reviewCount} reviews',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'OMAX',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Seller row
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0F0F0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.storefront_outlined,
                          size: 18,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.sellerName.isNotEmpty
                            ? product.sellerName
                            : 'Azager Official',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Visit Shop',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Color picker
                  const Text(
                    'Color',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        _colors.length,
                        (i) => GestureDetector(
                          onTap: () => setState(() => _selectedColor = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: _colors[i],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == i
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: _selectedColor == i
                                  ? [
                                      BoxShadow(
                                        color: _colors[i].withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Delivery',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(_deliveryOptions.length, (i) {
                      final selected = _selectedDelivery == i;
                      final option = _deliveryOptions[i];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: i == 0 ? 8 : 0,
                            left: i == 1 ? 8 : 0,
                          ),
                          child: _DeliveryOptionChip(
                            label: option['label']!,
                            price: option['price']!,
                            selected: selected,
                            onTap: () => setState(() => _selectedDelivery = i),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Description ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _expanded ? desc : _truncateText(desc, 120),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? 'Show less' : 'Read more',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── You May Also Like ──────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'You May Also Like',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 236,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: relatedProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => SizedBox(
                  width: 164,
                  child: ProductCard(product: relatedProducts[i]),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildWideLayout({
    required ProductModel product,
    required String description,
  }) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 11, child: _buildWideImageSection()),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 12,
                      child: _buildWideInfoSection(
                        product: product,
                        description: description,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'You May Also Like',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        (_relatedProducts.isNotEmpty
                                ? _relatedProducts
                                : DummyData.products)
                            .take(6)
                            .map(
                              (item) => SizedBox(
                                width: 180,
                                child: ProductCard(product: item),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              GestureDetector(
                onTap: _openGallery,
                child: SizedBox(
                  height: 520,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _imageAssets.isNotEmpty
                        ? _imageAssets.length
                        : 1,
                    onPageChanged: (i) => setState(() => _selectedImage = i),
                    itemBuilder: (_, i) {
                      final assets = _imageAssets;
                      if (assets.isNotEmpty) {
                        return _buildProductImage(
                          image: assets[i],
                          fit: BoxFit.cover,
                          fallbackIndex: i,
                          letter: '',
                        );
                      }
                      return Container(
                        color:
                            _placeholderColors[i % _placeholderColors.length],
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: _toggleWishlist,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _wishlisted ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: _wishlisted
                          ? Colors.red
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 86,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedImage == i
                        ? AppColors.primary
                        : Theme.of(context).dividerColor,
                    width: _selectedImage == i ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: _imageAssets.isNotEmpty
                      ? _buildProductImage(
                          image: _imageAssets[i],
                          fit: BoxFit.cover,
                          fallbackIndex: i,
                          letter: '',
                        )
                      : Container(
                          color:
                              _placeholderColors[i % _placeholderColors.length],
                        ),
                ),
              ),
            ),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: _imageAssets.isNotEmpty ? _imageAssets.length : 1,
          ),
        ),
      ],
    );
  }

  Widget _buildWideInfoSection({
    required ProductModel product,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          if (description.isNotEmpty)
            Text(
              _truncateText(description, 150),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => const Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: Icon(Icons.star, size: 22, color: Color(0xFFD9DEE5)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${product.rating}  ${product.reviewCount} Review',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 1, height: 20, color: AppColors.lightGrey),
              const SizedBox(width: 10),
              const Text(
                '11 Sold',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 18),
              const Icon(
                Icons.share_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              const Text(
                'Share',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          Text(
            _formatPrice(product.price),
            style: const TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1,
            ),
          ),
          const Divider(height: 28),
          const Text(
            'Color',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              _colors.length,
              (i) => GestureDetector(
                onTap: () => setState(() => _selectedColor = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: _colors[i],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == i
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Delivery',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_deliveryOptions.length, (i) {
              final option = _deliveryOptions[i];
              return Padding(
                padding: EdgeInsets.only(right: i == 0 ? 12 : 0),
                child: _DeliveryOptionChip(
                  label: option['label']!,
                  price: option['price']!,
                  selected: _selectedDelivery == i,
                  onTap: () => setState(() => _selectedDelivery = i),
                  compact: false,
                ),
              );
            }),
          ),
          const Divider(height: 30),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleAddToCart(product),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () => _handleBuyNow(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _expanded ? description : _truncateText(description, 180),
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Show less' : 'Read more',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage({
    required String image,
    required BoxFit fit,
    required int fallbackIndex,
    required String letter,
  }) {
    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            _imageFallback(index: fallbackIndex, letter: letter),
      );
    }

    return Image.asset(
      image,
      fit: fit,
      errorBuilder: (_, __, ___) =>
          _imageFallback(index: fallbackIndex, letter: letter),
    );
  }

  Widget _imageFallback({required int index, required String letter}) {
    final char = letter.isNotEmpty ? letter : '';
    return Container(
      color: _placeholderColors[index % _placeholderColors.length],
      child: char.isEmpty
          ? null
          : Center(
              child: Text(
                char,
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
    );
  }

  String _truncateText(String text, int max) {
    if (text.length <= max) return text;
    return '${text.substring(0, max)}...';
  }
}

class _DeliveryOptionChip extends StatelessWidget {
  final String label;
  final String price;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const _DeliveryOptionChip({
    required this.label,
    required this.price,
    required this.selected,
    required this.onTap,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 16,
          vertical: compact ? 10 : 14,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF7EC) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.lightGrey,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useDense = compact && constraints.maxWidth < 180;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: compact ? (useDense ? 13 : 14) : 15,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: useDense ? 4 : 8),
                      Icon(
                        Icons.info_outline,
                        size: useDense ? 14 : 16,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: useDense ? 6 : 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    price,
                    style: TextStyle(
                      fontSize: compact ? (useDense ? 13 : 14) : 15,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Fixed bottom bar ───────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onQtyTap;
  final VoidCallback onAddToCart;

  const _BottomBar({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
    required this.onQtyTap,
    required this.onAddToCart,
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
          // Quantity control
          Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decrement
                InkWell(
                  onTap: onDecrement,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                  child: const SizedBox(
                    width: 40,
                    height: 48,
                    child: Icon(
                      Icons.remove,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Qty (tap to type)
                GestureDetector(
                  onTap: onQtyTap,
                  child: Container(
                    width: 42,
                    height: 48,
                    color: const Color(0xFFF5F5F5),
                    child: Center(
                      child: Text(
                        '$qty',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                // Increment
                InkWell(
                  onTap: onIncrement,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(12),
                  ),
                  child: const SizedBox(
                    width: 40,
                    height: 48,
                    child: Icon(
                      Icons.add,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Add to Cart
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
