import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,  // Cambiado para coincidir con FirestoreService
      'name': product.name,     // Cambiado para coincidir con FirestoreService
      'price': product.price,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }
}
