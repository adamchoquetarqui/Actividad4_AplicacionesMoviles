import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  bool _isLoading = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Por favor ingresa un correo válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Iniciar Sesión" : "Registro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Correo"),
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: "Contraseña"),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      child: Text(isLogin ? "Ingresar" : "Registrarse"),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          try {
                            final user = isLogin
                                ? await _auth.login(_emailCtrl.text.trim(), _passCtrl.text)
                                : await _auth.registrar(_emailCtrl.text.trim(), _passCtrl.text);
                            if (user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => HomeScreen()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Error: No se pudo autenticar")),
                              );
                            }
                          } catch (e) {
                            String errorMessage = "Error desconocido";
                            if (e.toString().contains('user-not-found')) {
                              errorMessage = "Usuario no encontrado. ¿Necesitas registrarte?";
                            } else if (e.toString().contains('wrong-password')) {
                              errorMessage = "Contraseña incorrecta";
                            } else if (e.toString().contains('email-already-in-use')) {
                              errorMessage = "Este email ya está registrado";
                            } else if (e.toString().contains('weak-password')) {
                              errorMessage = "La contraseña es muy débil";
                            } else if (e.toString().contains('invalid-email')) {
                              errorMessage = "Email inválido";
                            } else if (e.toString().contains('network-request-failed')) {
                              errorMessage = "Error de conexión. Verifica tu internet";
                            } else if (e.toString().contains('too-many-requests')) {
                              errorMessage = "Demasiados intentos. Espera un momento";
                            }
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                duration: const Duration(seconds: 4),
                                action: SnackBarAction(
                                  label: 'Ver detalles',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Error detallado'),
                                        content: Text(e.toString()),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                    ),
              TextButton(
                child: Text(isLogin ? "Crear cuenta" : "Ya tengo cuenta"),
                onPressed: () => setState(() => isLogin = !isLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}