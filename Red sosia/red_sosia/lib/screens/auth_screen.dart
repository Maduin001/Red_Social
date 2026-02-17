import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import '../models/user.dart' as model;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool isLogin = true; // alterna entre login y registro
  bool isLoading = false; // para mostrar loading

  Future<void> submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    // Validaciones
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un email válido')),
      );
      return;
    }

    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
        ),
      );
      return;
    }

    if (!isLogin && name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Introduce tu nombre')));
      return;
    }

    setState(() => isLoading = true);

    final auth = fb.FirebaseAuth.instance;

    try {
      if (isLogin) {
        // LOGIN
        final credential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = model.User(
          id: credential.user!.uid,
          name: 'Usuario',
          email: email,
          interests: [],
        );

        setState(() => isLoading = false);

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
        );
      } else {
        // REGISTRO
        print('Creando usuario: $email');
        final credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✅ Usuario creado en Auth: ${credential.user?.uid}');

        // Guardar en Firestore (intentarlo, pero no bloquear)
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .set({'name': name, 'email': email, 'interests': []});
          print('✅ Datos guardados en Firestore');
        } catch (e) {
          print('⚠️ Error en Firestore (el usuario ya existe en Auth): $e');
        }

        // 🔴 LO IMPORTANTE: Llegamos aquí si NO hay error
        // El registro fue EXITOSO

        setState(() {
          isLoading = false;
          // Limpiar campos
          _emailController.clear();
          _passwordController.clear();
          _nameController.clear();
        });

        if (!mounted) return;

        // Mostrar mensaje de ÉXITO
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Registro exitoso! Ahora puedes iniciar sesión'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        // Cambiar a pantalla de login
        setState(() {
          isLogin = true; // Volver al modo login
        });

        // NO navegamos a HomeScreen, solo mostramos el mensaje y cambiamos a login
      }
    } on fb.FirebaseAuthException catch (e) {
      // Error específico de Firebase Auth
      print('❌ Error Auth: ${e.code} - ${e.message}');

      setState(() => isLoading = false);

      String errorMessage = 'Error';
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'La contraseña es demasiado débil';
          break;
        case 'email-already-in-use':
          errorMessage = '❌ El email ya está registrado';
          break;
        case 'invalid-email':
          errorMessage = 'El email no es válido';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Registro no habilitado';
          break;
        default:
          errorMessage = 'Error: ${e.message}';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      // Cualquier otro error
      print('❌ Error inesperado: $e');

      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Iniciar Sesión' : 'Crear Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!isLogin)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Cómo quieres que te llamen',
                ),
              ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'tu@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                hintText: 'Mínimo 6 caracteres',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            if (isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 45),
                ),
                child: Text(
                  isLogin ? 'Entrar' : 'Registrarse',
                  style: const TextStyle(fontSize: 16),
                ),
              ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                  // Limpiar mensajes anteriores
                  ScaffoldMessenger.of(context).clearSnackBars();
                });
              },
              child: Text(
                isLogin
                    ? '¿No tienes cuenta? Regístrate aquí'
                    : '¿Ya tienes cuenta? Inicia sesión',
              ),
            ),

            if (!isLogin)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Después del registro, podrás iniciar sesión con tu email y contraseña',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
