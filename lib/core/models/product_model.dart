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
  final String category;
  final String sellerId;
  final String sellerName;
  final List<DeliveryMethod> deliveryMethods;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.rating = 0,
    this.reviewCount = 0,
    required this.imageUrl,
    required this.category,
    this.sellerId = 'seller_1',
    this.sellerName = 'Azager Official',
    this.deliveryMethods = const [
      DeliveryMethod(name: 'Standard Delivery', price: 1500),
    ],
  });
}
