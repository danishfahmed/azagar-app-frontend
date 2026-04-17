class DeliveryMethod {
  final String name;
  final double price;

  const DeliveryMethod({required this.name, required this.price});
}

class ProductModel {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> images;
  final String? description;
  final String category;
  final String sellerId;
  final String sellerName;
  final bool isFavorite;
  final List<DeliveryMethod> deliveryMethods;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.rating = 0,
    this.reviewCount = 0,
    required this.imageUrl,
    this.images = const [],
    this.description,
    required this.category,
    this.sellerId = 'seller_1',
    this.sellerName = 'Azager Official',
    this.isFavorite = false,
    this.deliveryMethods = const [
      DeliveryMethod(name: 'Standard Delivery', price: 1500),
    ],
  });

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    double? originalPrice,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    List<String>? images,
    String? description,
    String? category,
    String? sellerId,
    String? sellerName,
    bool? isFavorite,
    List<DeliveryMethod>? deliveryMethods,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      description: description ?? this.description,
      category: category ?? this.category,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      isFavorite: isFavorite ?? this.isFavorite,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
    );
  }

  factory ProductModel.fromApi(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['product_id'];
    final productId = rawId != null ? rawId.toString() : '';

    final discountPrice = _toDouble(
      json['discount_price'] ?? json['special_price'] ?? json['sale_price'],
    );
    final basePrice = _toDouble(json['price']);
    final effectivePrice = discountPrice > 0 ? discountPrice : basePrice;
    final originalPrice = discountPrice > 0 && basePrice > 0 ? basePrice : null;

    final categoryMap = json['category'] as Map<String, dynamic>?;
    final shopMap = (json['shop'] ?? json['seller']) as Map<String, dynamic>?;

    // Parse delivery methods
    final deliveryRaw = json['delivery_methods'];
    final deliveryMethods = <DeliveryMethod>[];
    if (deliveryRaw is List) {
      for (final dm in deliveryRaw) {
        if (dm is Map<String, dynamic>) {
          deliveryMethods.add(
            DeliveryMethod(
              name: _toString(dm['name']),
              price: _toDouble(dm['price_adjustment'] ?? dm['price']),
            ),
          );
        }
      }
    }

    final imageList = _toStringList(
      json['images'] ??
          json['gallery'] ??
          json['product_images'] ??
          json['thumbnails'],
    );
    final thumbnail = _toString(
      json['thumbnail'] ??
          json['image'] ??
          (imageList.isNotEmpty ? imageList.first : ''),
    );

    return ProductModel(
      id: productId,
      name: _toString(json['name'] ?? json['title']),
      price: effectivePrice,
      originalPrice: originalPrice,
      rating: _toDouble(json['rating']),
      reviewCount: _toInt(json['total_reviews'] ?? json['review_count']),
      imageUrl: thumbnail,
      images: imageList,
      description: _stripHtml(_toNullableString(json['description'])),
      category: _toString(
        json['category_name'] ?? categoryMap?['name'] ?? json['category'],
      ),
      sellerId: _toString(
        json['shop_id'] ?? shopMap?['id'] ?? json['seller_id'],
      ),
      sellerName: _toString(
        json['shop_name'] ?? shopMap?['name'] ?? json['seller_name'],
      ),
      isFavorite: _toBool(json['is_favorite'] ?? json['in_wishlist']),
      deliveryMethods: deliveryMethods.isNotEmpty
          ? deliveryMethods
          : const [DeliveryMethod(name: 'Standard Delivery', price: 1500)],
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final v = value.toLowerCase();
      return v == '1' || v == 'true' || v == 'yes';
    }
    return false;
  }

  static String _toString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String? _toNullableString(dynamic value) {
    final v = _toString(value).trim();
    return v.isEmpty ? null : v;
  }

  /// Strip HTML tags and decode common entities from API descriptions.
  static String? _stripHtml(String? value) {
    if (value == null || value.isEmpty) return value;
    // Remove HTML tags
    var text = value.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode common HTML entities
    text = text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
    // Collapse multiple newlines into two
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) {
            if (item is String) return item;
            if (item is Map<String, dynamic>) {
              return _toString(
                item['url'] ??
                    item['thumbnail'] ??
                    item['image'] ??
                    item['path'],
              );
            }
            return item.toString();
          })
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }
}
