import 'package:azager/core/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int qty;

  CartItem({required this.product, this.qty = 1});

  double get total => product.price * qty;
}
