class HomeBanner {
  final int id;
  final String title;
  final String? link;
  final String thumbnail;

  HomeBanner({
    required this.id,
    required this.title,
    this.link,
    required this.thumbnail,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      id: json['id'] as int,
      title: json['title'] as String,
      link: json['link'] as String?,
      thumbnail: json['thumbnail'] as String,
    );
  }
}

class HomeAd {
  final int id;
  final String title;
  final String? link;
  final String thumbnail;

  HomeAd({
    required this.id,
    required this.title,
    this.link,
    required this.thumbnail,
  });

  factory HomeAd.fromJson(Map<String, dynamic> json) {
    return HomeAd(
      id: json['id'] as int,
      title: json['title'] as String,
      link: json['link'] as String?,
      thumbnail: json['thumbnail'] as String,
    );
  }
}

class HomeCategory {
  final int id;
  final String name;
  final String thumbnail;

  HomeCategory({required this.id, required this.name, required this.thumbnail});

  factory HomeCategory.fromJson(Map<String, dynamic> json) {
    return HomeCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      thumbnail: json['thumbnail'] as String,
    );
  }
}

class HomeShopProduct {
  final int id;
  final String name;
  final String logo;
  final double rating;
  final String? estimatedDeliveryTime;
  final double deliveryCharge;
  final bool lastOnline;
  final String? verificationType;
  final String? verificationBadgeUrl;

  HomeShopProduct({
    required this.id,
    required this.name,
    required this.logo,
    required this.rating,
    this.estimatedDeliveryTime,
    required this.deliveryCharge,
    required this.lastOnline,
    this.verificationType,
    this.verificationBadgeUrl,
  });

  factory HomeShopProduct.fromJson(Map<String, dynamic> json) {
    return HomeShopProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      logo: json['logo'] as String,
      rating: (json['rating'] as num).toDouble(),
      estimatedDeliveryTime: json['estimated_delivery_time'] as String?,
      deliveryCharge: (json['delivery_charge'] as num).toDouble(),
      lastOnline: json['last_online'] as bool,
      verificationType: json['verification_type'] as String?,
      verificationBadgeUrl: json['verification_badge_url'] as String?,
    );
  }
}

class HomeProduct {
  final int id;
  final bool isDigital;
  final String name;
  final String thumbnail;
  final double price;
  final double discountPrice;
  final double discountPercentage;
  final double rating;
  final String totalReviews;
  final int remainingQuantity;
  final String totalSold;
  final bool isFavorite;
  final String? brand;
  final HomeShopProduct shop;

  HomeProduct({
    required this.id,
    required this.isDigital,
    required this.name,
    required this.thumbnail,
    required this.price,
    required this.discountPrice,
    required this.discountPercentage,
    required this.rating,
    required this.totalReviews,
    required this.remainingQuantity,
    required this.totalSold,
    required this.isFavorite,
    this.brand,
    required this.shop,
  });

  factory HomeProduct.fromJson(Map<String, dynamic> json) {
    return HomeProduct(
      id: json['id'] as int,
      isDigital: json['is_digital'] as bool,
      name: json['name'] as String,
      thumbnail: json['thumbnail'] as String,
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discount_price'] as num).toDouble(),
      discountPercentage: (json['discount_percentage'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      totalReviews: json['total_reviews'] as String,
      remainingQuantity: json['remaining_quantity'] as int,
      totalSold: json['total_sold'] as String,
      isFavorite: json['is_favorite'] as bool,
      brand: json['brand'] as String?,
      shop: HomeShopProduct.fromJson(json['shop'] as Map<String, dynamic>),
    );
  }
}

class HomeShop {
  final int id;
  final String name;
  final int isVerified;
  final String logo;
  final String banner;
  final int totalProducts;
  final double rating;
  final String totalReviews;
  final String? verificationType;
  final String? verificationBadgeUrl;

  HomeShop({
    required this.id,
    required this.name,
    required this.isVerified,
    required this.logo,
    required this.banner,
    required this.totalProducts,
    required this.rating,
    required this.totalReviews,
    this.verificationType,
    this.verificationBadgeUrl,
  });

  factory HomeShop.fromJson(Map<String, dynamic> json) {
    return HomeShop(
      id: json['id'] as int,
      name: json['name'] as String,
      isVerified: json['is_verified'] as int,
      logo: json['logo'] as String,
      banner: json['banner'] as String,
      totalProducts: json['total_products'] as int,
      rating: (json['rating'] as num).toDouble(),
      totalReviews: json['total_reviews'] as String,
      verificationType: json['verification_type'] as String?,
      verificationBadgeUrl: json['verification_badge_url'] as String?,
    );
  }
}

class JustForYou {
  final int total;
  final List<HomeProduct> products;

  JustForYou({required this.total, required this.products});

  factory JustForYou.fromJson(Map<String, dynamic> json) {
    return JustForYou(
      total: json['total'] as int,
      products: (json['products'] as List)
          .map((e) => HomeProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SplashScreenData {
  final String image;
  final int duration;

  SplashScreenData({required this.image, required this.duration});

  factory SplashScreenData.fromJson(Map<String, dynamic> json) {
    return SplashScreenData(
      image: json['image'] as String,
      duration: json['duration'] as int,
    );
  }
}

class HomeResponse {
  final bool success;
  final String message;
  final List<HomeBanner> banners;
  final List<HomeAd> ads;
  final List<HomeCategory> categories;
  final List<HomeShop> shops;
  final List<HomeProduct> popularProducts;
  final JustForYou justForYou;
  final List<SplashScreenData> splashScreens;

  HomeResponse({
    required this.success,
    required this.message,
    required this.banners,
    required this.ads,
    required this.categories,
    required this.shops,
    required this.popularProducts,
    required this.justForYou,
    required this.splashScreens,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return HomeResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      banners: (data['banners'] as List)
          .map((e) => HomeBanner.fromJson(e as Map<String, dynamic>))
          .toList(),
      ads: (data['ads'] as List)
          .map((e) => HomeAd.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (data['categories'] as List)
          .map((e) => HomeCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      shops: (data['shops'] as List)
          .map((e) => HomeShop.fromJson(e as Map<String, dynamic>))
          .toList(),
      popularProducts: (data['popular_products'] as List)
          .map((e) => HomeProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      justForYou: JustForYou.fromJson(
        data['just_for_you'] as Map<String, dynamic>,
      ),
      splashScreens:
          (data['splash_screens'] as List?)
              ?.map((e) => SplashScreenData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SplashScreenResponse {
  final bool success;
  final String message;
  final List<SplashScreenData> data;

  SplashScreenResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SplashScreenResponse.fromJson(Map<String, dynamic> json) {
    return SplashScreenResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((e) => SplashScreenData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
