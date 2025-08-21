import 'package:flutter/material.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'cart_screen.dart';
import 'admin_screen.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();
  final _cartService = CartService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _auth.getUserData();
    setState(() {
      _currentUser = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pedidos Online"),
        backgroundColor: _currentUser?.isAdmin == true ? Colors.orange : Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.store, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'Bienvenido a Pedidos Online',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Usuario: ${_auth.usuarioActual?.email ?? "No disponible"}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    if (_currentUser != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _currentUser!.isAdmin ? Colors.orange : Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _currentUser!.isAdmin ? 'ADMINISTRADOR' : 'CLIENTE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botones para Admin
            if (_currentUser?.isAdmin == true) ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text("Panel de Administración"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long),
                label: const Text("Todos los Pedidos"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrdersScreen()),
                ),
              ),
            ],
            // Botones para Cliente
            if (_currentUser?.isAdmin != true) ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_bag),
                label: const Text("Ver Productos"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductsScreen()),
                ).then((_) => setState(() {})),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (_cartService.itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '${_cartService.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: Text("Carrito (${_cartService.itemCount})"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ).then((_) => setState(() {})),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long),
                label: const Text("Mis Pedidos"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrdersScreen()),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}