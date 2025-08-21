class UserModel {
  String uid;
  String email;
  String role; // 'admin' o 'cliente'
  String? displayName;
  DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    required this.createdAt,
  });

  // Convertir UserModel a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'displayName': displayName,
      'createdAt': createdAt,
    };
  }

  // Crear UserModel desde un Map de Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      role: map['role'] ?? 'cliente', // Por defecto cliente
      displayName: map['displayName'],
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }

  // Verificar si es admin
  bool get isAdmin => role == 'admin';

  // Verificar si es cliente
  bool get isCliente => role == 'cliente';
}
