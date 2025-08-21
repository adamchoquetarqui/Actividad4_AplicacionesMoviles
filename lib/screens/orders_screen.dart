import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class OrdersScreen extends StatelessWidget {
  final _firestore = FirestoreService();
  final _auth = AuthService();

  OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Pedidos")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.getPedidosByUser(_auth.usuarioActual?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No tienes pedidos aún',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          
          final pedidos = snapshot.data!.docs;
          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, i) {
              final p = pedidos[i];
              final data = p.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Pedido #${p.id.substring(0, 8)}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Estado: ${data['estado']}"),
                      Text("Fecha: ${_formatDate(data['fecha'])}"),
                      if (data['items'] != null)
                        Text("Items: ${data['items'].length}"),
                    ],
                  ),
                  trailing: _getStatusIcon(data['estado']),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Fecha no disponible';
    try {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Fecha no válida';
    }
  }

  Widget _getStatusIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return const Icon(Icons.pending, color: Colors.orange);
      case 'en_proceso':
        return const Icon(Icons.sync, color: Colors.blue);
      case 'completado':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'cancelado':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }
}