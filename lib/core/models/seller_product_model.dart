import 'dart:math';

/// A single colour + size + price + stock combination.
class ProductVariant {
  String color;
  String size;
  double price;
  int stock;
  bool isActive;

  ProductVariant({
    required this.color,
    required this.size,
    required this.price,
    this.stock = 0,
    this.isActive = true,
  });

  String get label => '$size/$color';
}

/// Seller‑side product representation.
class SellerProduct {
  final String id;
  String name;
  String category;
  String description;
  List<String> imageUrls;
  double price;
  int stockQuantity;
  bool isActive;
  String sku;
  List<ProductVariant> variants;

  SellerProduct({
    required this.id,
    required this.name,
    required this.category,
    this.description = '',
    this.imageUrls = const [],
    required this.price,
    this.stockQuantity = 1,
    this.isActive = true,
    this.sku = '',
    this.variants = const [],
  });

  /// Auto‑generate a unique SKU from category + name + random suffix.
  static String generateSku(String category, String name) {
    final cat = category.length >= 3
        ? category.substring(0, 3).toUpperCase()
        : category.toUpperCase();
    final nm = name.length >= 3
        ? name.substring(0, 3).toUpperCase()
        : name.toUpperCase();
    final rand = (Random().nextInt(90000) + 10000).toString();
    return '$cat-$nm-$rand';
  }
}
