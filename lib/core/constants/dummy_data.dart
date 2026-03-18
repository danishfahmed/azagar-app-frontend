import 'package:azager/core/models/product_model.dart';
import 'package:azager/core/models/cart_item_model.dart';

class DummyData {
  DummyData._();

  static final List<CartItem> cartItems = [
    CartItem(product: products[0]),
    CartItem(product: products[2]),
  ];

  static void addProductToCart(ProductModel product, {int qty = 1}) {
    final index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      cartItems[index].qty += qty;
      return;
    }
    cartItems.add(CartItem(product: product, qty: qty));
  }

  static const List<String> categories = [
    'All',
    'Fashion',
    'Electronic',
    'Furniture',
    'Digital',
    'Beauty',
    'Food',
    'Decoration',
    'Kitchen',
    'Bath',
  ];

  static const List<String> recentSearches = [
    'Ruffle bag',
    'Power bank',
    'Weight machine',
  ];

  static const List<ProductModel> products = [
    ProductModel(
      id: '1',
      name: 'Ruffle bag',
      price: 13500,
      originalPrice: 15500,
      rating: 0,
      reviewCount: 0,
      imageUrl: 'assets/images/product1.png',
      category: 'Fashion',
      sellerId: 'seller_1',
      sellerName: 'Azager Official',
      deliveryMethods: [
        DeliveryMethod(name: 'Pickup', price: 0),
        DeliveryMethod(name: 'Standard Delivery', price: 1500),
        DeliveryMethod(name: 'Azager Xpress', price: 3000),
      ],
    ),
    ProductModel(
      id: '2',
      name: 'Ruffle bag',
      price: 13500,
      originalPrice: 15500,
      rating: 0,
      reviewCount: 0,
      imageUrl: 'assets/images/product2.png',
      category: 'Fashion',
      sellerId: 'seller_2',
      sellerName: 'Trendy Store',
      deliveryMethods: [
        DeliveryMethod(name: 'Pickup', price: 0),
        DeliveryMethod(name: 'Standard Delivery', price: 1500),
      ],
    ),
    ProductModel(
      id: '3',
      name: 'Power Bank',
      price: 8000,
      originalPrice: 10000,
      rating: 4,
      reviewCount: 12,
      imageUrl: 'assets/images/product3.png',
      category: 'Electronic',
      sellerId: 'seller_1',
      sellerName: 'Azager Official',
      deliveryMethods: [
        DeliveryMethod(name: 'Standard Delivery', price: 2000),
        DeliveryMethod(name: 'Azager Xpress', price: 3500),
      ],
    ),
    ProductModel(
      id: '4',
      name: 'Wireless Earbuds',
      price: 15000,
      originalPrice: 20000,
      rating: 4.5,
      reviewCount: 8,
      imageUrl: 'assets/images/product4.png',
      category: 'Electronic',
      sellerId: 'seller_3',
      sellerName: 'GadgetHub',
      deliveryMethods: [DeliveryMethod(name: 'Standard Delivery', price: 1000)],
    ),
    ProductModel(
      id: '5',
      name: 'Leather Wallet',
      price: 5500,
      originalPrice: 7000,
      rating: 3.5,
      reviewCount: 5,
      imageUrl: 'assets/images/product5.png',
      category: 'Fashion',
      sellerId: 'seller_2',
      sellerName: 'Trendy Store',
      deliveryMethods: [
        DeliveryMethod(name: 'Pickup', price: 0),
        DeliveryMethod(name: 'Standard Delivery', price: 800),
        DeliveryMethod(name: 'Azager Xpress', price: 2000),
      ],
    ),
    ProductModel(
      id: '6',
      name: 'Running Shoes',
      price: 22000,
      originalPrice: 28000,
      rating: 4.8,
      reviewCount: 20,
      imageUrl: 'assets/images/product6.png',
      category: 'Fashion',
      sellerId: 'seller_1',
      sellerName: 'Azager Official',
      deliveryMethods: [
        DeliveryMethod(name: 'Standard Delivery', price: 2500),
        DeliveryMethod(name: 'Azager Xpress', price: 4000),
      ],
    ),
  ];
}
