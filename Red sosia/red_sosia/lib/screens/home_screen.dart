import 'package:flutter/material.dart';
import '../models/user.dart' as model;

class HomeScreen extends StatelessWidget {
  final model.User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido, ${user.name}')),
      body: const Center(child: Text('Aquí irá la búsqueda de usuarios')),
    );
  }
}
