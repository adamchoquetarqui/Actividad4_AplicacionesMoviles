import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> registrar(String email, String password, {String role = 'cliente'}) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (cred.user != null) {
      // Crear documento de usuario en Firestore
      final userModel = UserModel(
        uid: cred.user!.uid,
        email: email,
        role: role,
        displayName: cred.user!.displayName,
        createdAt: DateTime.now(),
      );
      
      await _db.collection('users').doc(cred.user!.uid).set(userModel.toMap());
    }
    
    return cred.user;
  }

  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get usuarioActual => _auth.currentUser;

  // Obtener datos del usuario actual con rol
  Future<UserModel?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Verificar si el usuario actual es admin
  Future<bool> isAdmin() async {
    final userData = await getUserData();
    return userData?.isAdmin ?? false;
  }
}