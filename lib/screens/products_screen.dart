import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import 'cart_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final AuthService _authService = AuthService();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await _authService.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ).then((_) => setState(() {}));
                },
              ),
              if (_cartService.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartService.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Precio: \$${product.price}'),
                      Text(
                        'Stock: ${product.quantity}',
                        style: TextStyle(
                          color: product.quantity > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.quantity == 0)
                        const Text(
                          'SIN STOCK',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text('Agregar'),
                        onPressed: product.quantity > 0
                            ? () {
                                setState(() {
                                  _cartService.addToCart(product);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} agregado al carrito'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            : null,
                      ),
                      if (_isAdmin) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                        final nameCtrl = TextEditingController(text: product.name);
                        final priceCtrl = TextEditingController(text: product.price.toString());
                        final quantityCtrl = TextEditingController(text: product.quantity.toString());
                        final formKey = GlobalKey<FormState>();

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Editar Producto'),
                            content: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: nameCtrl,
                                    decoration: const InputDecoration(labelText: 'Nombre'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingresa un nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    controller: priceCtrl,
                                    decoration: const InputDecoration(labelText: 'Precio'),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingresa un precio';
                                      }
                                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                        return 'Por favor ingresa un precio válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    controller: quantityCtrl,
                                    decoration: const InputDecoration(labelText: 'Cantidad'),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingresa una cantidad';
                                      }
                                      if (int.tryParse(value) == null || int.parse(value) < 0) {
                                        return 'Por favor ingresa una cantidad válida';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Cancelar'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              ElevatedButton(
                                child: const Text('Guardar'),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    try {
                                      final updatedProduct = Product(
                                        id: product.id,
                                        name: nameCtrl.text.trim(),
                                        price: double.parse(priceCtrl.text),
                                        quantity: int.parse(quantityCtrl.text),
                                      );
                                      await _productService.updateProduct(updatedProduct);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Producto actualizado exitosamente')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error al actualizar: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar eliminación'),
                                content: Text('¿Estás seguro de que quieres eliminar "${product.name}"?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancelar'),
                                    onPressed: () => Navigator.pop(context, false),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Eliminar'),
                                    onPressed: () => Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await _productService.deleteProduct(product.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Producto eliminado exitosamente')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al eliminar: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _isAdmin ? FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final nameCtrl = TextEditingController();
              final priceCtrl = TextEditingController();
              final quantityCtrl = TextEditingController();

              final formKey = GlobalKey<FormState>();
              return AlertDialog(
                title: const Text('Agregar Producto'),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un nombre';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: priceCtrl,
                        decoration: const InputDecoration(labelText: 'Precio'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un precio';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Por favor ingresa un precio válido';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: quantityCtrl,
                        decoration: const InputDecoration(labelText: 'Cantidad'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una cantidad';
                          }
                          if (int.tryParse(value) == null || int.parse(value) < 0) {
                            return 'Por favor ingresa una cantidad válida';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    child: const Text('Agregar'),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          final product = Product(
                            id: '', // Firestore asigna el id automáticamente
                            name: nameCtrl.text.trim(),
                            price: double.parse(priceCtrl.text),
                            quantity: int.parse(quantityCtrl.text),
                          );
                          await _productService.addProduct(product);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Producto agregado exitosamente')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al agregar: $e')),
                          );
                        }
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
      ) : null,
    );
  }
}
