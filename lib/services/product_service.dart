import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  // Crear o agregar un producto
  Future<void> addProduct(Product product) async {
    await _productsCollection.add(product.toMap());
  }

  // Leer todos los productos
  Stream<List<Product>> getProducts() {
    return _productsCollection.snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Product.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Actualizar un producto
  Future<void> updateProduct(Product product) async {
    await _productsCollection.doc(product.id).update(product.toMap());
  }

  // Eliminar un producto
  Future<void> deleteProduct(String id) async {
    await _productsCollection.doc(id).delete();
  }
}