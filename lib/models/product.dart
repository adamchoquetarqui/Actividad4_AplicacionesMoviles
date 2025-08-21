class Product {
  String id;
  String name;
  double price;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  // Convertir Product a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // Crear Product desde un Map de Firestore
  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'],
      price: map['price'].toDouble(),
      quantity: map['quantity'],
    );
  }
}