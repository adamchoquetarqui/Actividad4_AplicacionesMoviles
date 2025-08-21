import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Productos
  Stream<QuerySnapshot> getProductos() {
    return _db.collection("products").snapshots();
  }

  // Pedidos
  Future<void> crearPedido(String userId, List<Map<String, dynamic>> items) async {
    try {
      print('🔄 Intentando crear pedido para usuario: $userId');
      print('📦 Items del pedido: $items');
      
      // Usar transacción para asegurar consistencia
      await _db.runTransaction((transaction) async {
        // Verificar y actualizar stock de cada producto
        for (final item in items) {
          final productId = item['productId'] as String;
          final quantity = item['quantity'] as int;
          
          final productRef = _db.collection("products").doc(productId);
          final productDoc = await transaction.get(productRef);
          
          if (!productDoc.exists) {
            throw Exception('Producto no encontrado: $productId');
          }
          
          final currentStock = productDoc.data()!['quantity'] as int;
          
          if (currentStock < quantity) {
            throw Exception('Stock insuficiente para ${item['name']}. Stock disponible: $currentStock');
          }
          
          // Decrementar stock
          transaction.update(productRef, {
            'quantity': currentStock - quantity,
          });
          
          print('📉 Stock actualizado para ${item['name']}: $currentStock → ${currentStock - quantity}');
        }
        
        // Crear el pedido
        final pedidoRef = _db.collection("pedidos").doc();
        transaction.set(pedidoRef, {
          "id_usuario": userId,
          "fecha": DateTime.now(),
          "estado": "pendiente",
          "items": items,
        });
        
        print('✅ Pedido creado exitosamente con ID: ${pedidoRef.id}');
      });
      
    } catch (e) {
      print('❌ Error al crear pedido: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getPedidos() {
    return _db.collection("pedidos").orderBy("fecha", descending: true).snapshots();
  }

  Stream<QuerySnapshot> getPedidosByUser(String userId) {
    return _db
        .collection("pedidos")
        .where("id_usuario", isEqualTo: userId)
        .orderBy("fecha", descending: true)
        .snapshots();
  }

  // Función para inicializar productos de ejemplo
  Future<void> inicializarProductos() async {
    try {
      print('🔄 Verificando si ya existen productos...');
      
      final snapshot = await _db.collection("products").get();
      if (snapshot.docs.isNotEmpty) {
        print('✅ Ya existen productos en la base de datos');
        return;
      }

      print('📦 Creando productos de ejemplo...');
      
      final productos = [
        {
          'name': 'Pizza Margherita',
          'price': 12.99,
          'quantity': 50,
        },
        {
          'name': 'Hamburguesa Clásica',
          'price': 8.99,
          'quantity': 30,
        },
        {
          'name': 'Pasta Carbonara',
          'price': 10.50,
          'quantity': 25,
        },
        {
          'name': 'Ensalada César',
          'price': 7.99,
          'quantity': 40,
        },
        {
          'name': 'Tacos Mexicanos',
          'price': 9.99,
          'quantity': 35,
        },
        {
          'name': 'Sushi Roll',
          'price': 15.99,
          'quantity': 20,
        },
        {
          'name': 'Pollo a la Parrilla',
          'price': 13.50,
          'quantity': 28,
        },
        {
          'name': 'Lasaña Italiana',
          'price': 11.99,
          'quantity': 22,
        },
      ];

      for (final producto in productos) {
        await _db.collection("products").add(producto);
      }

      print('✅ Productos creados exitosamente');
    } catch (e) {
      print('❌ Error al inicializar productos: $e');
      rethrow;
    }
  }

  // Función para agregar un producto
  Future<void> agregarProducto(Product producto) async {
    try {
      print('🔄 Agregando producto: ${producto.name}');
      
      await _db.collection("products").add(producto.toMap());
      
      print('✅ Producto agregado exitosamente');
    } catch (e) {
      print('❌ Error al agregar producto: $e');
      rethrow;
    }
  }

  // Función para actualizar un producto
  Future<void> actualizarProducto(String id, Product producto) async {
    try {
      print('🔄 Actualizando producto: ${producto.name}');
      
      await _db.collection("products").doc(id).update(producto.toMap());
      
      print('✅ Producto actualizado exitosamente');
    } catch (e) {
      print('❌ Error al actualizar producto: $e');
      rethrow;
    }
  }

  // Función para eliminar un producto
  Future<void> eliminarProducto(String id) async {
    try {
      print('🔄 Eliminando producto con ID: $id');
      
      await _db.collection("products").doc(id).delete();
      
      print('✅ Producto eliminado exitosamente');
    } catch (e) {
      print('❌ Error al eliminar producto: $e');
      rethrow;
    }
  }
}