import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
      ),
      body: _cartService.items.isEmpty
          ? const Center(
              child: Text(
                'Tu carrito está vacío',
                style: TextStyle(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartService.items.length,
                    itemBuilder: (context, index) {
                      final item = _cartService.items[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(item.product.name),
                          subtitle: Text('Precio: \$${item.product.price}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (item.quantity > 1) {
                                      _cartService.updateQuantity(
                                          item.product.id, item.quantity - 1);
                                    } else {
                                      _cartService.removeFromCart(item.product.id);
                                    }
                                  });
                                },
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    _cartService.updateQuantity(
                                        item.product.id, item.quantity + 1);
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _cartService.removeFromCart(item.product.id);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${_cartService.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: _isPlacingOrder
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _placeOrder,
                                child: const Text('Realizar Pedido'),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _placeOrder() async {
    if (_cartService.items.isEmpty) return;

    setState(() => _isPlacingOrder = true);

    try {
      final userId = _authService.usuarioActual?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final cartItems = _cartService.getCartItemsForOrder();
      await _firestoreService.crearPedido(userId, cartItems);

      _cartService.clearCart();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido realizado exitosamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al realizar pedido: $e')),
      );
    } finally {
      setState(() => _isPlacingOrder = false);
    }
  }
}
