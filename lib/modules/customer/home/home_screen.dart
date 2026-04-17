import 'package:flutter/material.dart';
import 'package:azager/core/constants/app_colors.dart';
import 'package:azager/core/models/home_models.dart';
import 'package:azager/core/models/product_model.dart';
import 'package:azager/core/services/home_service.dart';
import 'package:azager/core/services/product_service.dart';
import 'package:azager/core/network/api_exception.dart';
import 'package:azager/modules/customer/category/category_screen.dart';
import 'package:azager/modules/customer/search/search_screen.dart';
import 'package:azager/modules/customer/wishlist/wishlist_screen.dart';
import 'package:azager/modules/shared/widgets/product_card.dart';
import 'package:azager/modules/customer/profile/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _homeService = HomeService();
  final _productService = ProductService();
  int _selectedCategory = 0;
  int _bannerPage = 0;
  final PageController _bannerController = PageController();

  bool _isLoading = true;
  String? _error;
  HomeResponse? _homeData;

  // Category-filtered products
  List<ProductModel>? _categoryProducts;
  bool _isCategoryLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHome();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _homeService.dispose();
    _productService.dispose();
    super.dispose();
  }

  Future<void> _fetchCategoryProducts(int categoryId) async {
    setState(() => _isCategoryLoading = true);
    try {
      final response = await _productService.getCategoryProducts(
        categoryId: categoryId,
      );
      if (!mounted) return;
      setState(() {
        _categoryProducts = response.products;
        _isCategoryLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categoryProducts = [];
        _isCategoryLoading = false;
      });
    }
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategory = index;
      _categoryProducts = null;
    });
    if (index > 0 && _homeData != null) {
      final category = _homeData!.categories[index - 1]; // offset for 'All'
      _fetchCategoryProducts(category.id);
    }
  }

  Future<void> _fetchHome() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _homeService.fetchHome();
      if (!mounted) return;
      setState(() {
        _homeData = response;
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
        _error = 'Something went wrong. Pull down to retry.';
        _isLoading = false;
      });
    }
  }

  /// Convert API [HomeProduct] to the [ProductModel] used by ProductCard.
  ProductModel _toProductModel(HomeProduct p) {
    return ProductModel(
      id: p.id.toString(),
      name: p.name,
      price: p.discountPrice > 0 ? p.discountPrice : p.price,
      originalPrice: p.discountPrice > 0 ? p.price : null,
      rating: p.rating,
      reviewCount: int.tryParse(p.totalReviews) ?? 0,
      imageUrl: p.thumbnail,
      category: '',
      sellerId: p.shop.id.toString(),
      sellerName: p.shop.name,
      isFavorite: p.isFavorite,
    );
  }

  List<String> get _categoryNames {
    final cats = <String>['All'];
    if (_homeData != null) {
      cats.addAll(_homeData!.categories.map((c) => c.name));
    }
    return cats;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _error != null
            ? _ErrorView(error: _error!, onRetry: _fetchHome)
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _fetchHome,
                child: _buildContent(theme),
              ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final data = _homeData!;
    final banners = data.banners;
    final ads = data.ads;
    final popularProducts = data.popularProducts.map(_toProductModel).toList();
    final justForYouProducts = data.justForYou.products
        .map(_toProductModel)
        .toList();

    return CustomScrollView(
      slivers: [
        // ── App Bar ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 32,
                  width: 104,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  ),
                  icon: Icon(
                    Icons.favorite_border,
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Search Bar ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SearchBar(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // ── Banner Carousel ───────────────────────────────────
        if (banners.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  child: PageView.builder(
                    controller: _bannerController,
                    onPageChanged: (i) => setState(() => _bannerPage = i),
                    itemCount: banners.length,
                    itemBuilder: (_, i) => _BannerCard(banner: banners[i]),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    banners.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _bannerPage == i ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _bannerPage == i
                            ? AppColors.primary
                            : AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // ── Category Chips ────────────────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categoryNames.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final selected = _selectedCategory == i;
                return GestureDetector(
                  onTap: () => _onCategorySelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.lightGrey,
                      ),
                    ),
                    child: Text(
                      _categoryNames[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // ── Ads (Sale Banners) ────────────────────────────────
        if (ads.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ads.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _AdCard(ad: ads[i]),
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // ── Category Products (when a category is selected) ───
        if (_selectedCategory > 0) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _categoryNames[_selectedCategory],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (_isCategoryLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            )
          else if (_categoryProducts != null && _categoryProducts!.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ProductCard(product: _categoryProducts![i]),
                  childCount: _categoryProducts!.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
              ),
            )
          else if (_categoryProducts != null && _categoryProducts!.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No products in this category',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
        // ── Popular Products Header ───────────────────────────
        if (popularProducts.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Popular Products',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => ProductCard(product: popularProducts[i]),
                childCount: popularProducts.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],

        // ── Just For You Header ───────────────────────────────
        if (justForYouProducts.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Just For You',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CategoryScreen()),
                    ),
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, i) => ProductCard(product: justForYouProducts[i]),
                childCount: justForYouProducts.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
            ),
          ),
        ],

        // ── Shops Section ─────────────────────────────────────
        if (data.shops.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Top Shops',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: data.shops.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _ShopCard(shop: data.shops[i]),
              ),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets ───────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Explore Fashion',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final HomeBanner banner;
  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          banner.thumbnail,
          width: double.infinity,
          height: 140,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: double.infinity,
            height: 140,
            color: AppColors.primary,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            child: Text(
              banner.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final HomeAd ad;
  const _AdCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        ad.thumbnail,
        width: 200,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 200,
          height: 110,
          color: AppColors.grey,
          alignment: Alignment.center,
          child: Text(
            ad.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final HomeShop shop;
  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(shop.logo),
            backgroundColor: AppColors.lightGrey,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              shop.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          if (shop.isVerified == 1)
            const Icon(Icons.verified, size: 14, color: AppColors.primary),
        ],
      ),
    );
  }
}
