import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gate/config.dart';
import 'package:http/http.dart' as http;
import '../custom_widgets/navbar.dart';
import 'login.dart';

final routeStep1 = "$baseUrl/recuperar"; // Paso enviar email para enviar codigo de recuperacion 
final routeStep2 = "$baseUrl/recuperar/resetear"; // Paso enviar email y codigo de recuperacion 
const exampleCode = "ej: 123456";

class PwRecoveryPage extends StatefulWidget {
  const PwRecoveryPage({super.key});

  @override
  State<PwRecoveryPage> createState() => _PwRecoveryPageState();
}

class _PwRecoveryPageState extends State<PwRecoveryPage> {
  // Controla en qué paso estamos: 1 = email, 2 = código + nueva pw
  int _paso = 1;
  bool _cargando = false;

  final _formKeyPaso1 = GlobalKey<FormState>();
  final _formKeyPaso2 = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final codigoController = TextEditingController();
  final nuevaPwController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    codigoController.dispose();
    nuevaPwController.dispose();
    super.dispose();
  }

  // PASO 1: enviar email
  Future<void> enviarEmail() async {
    if (!_formKeyPaso1.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final response = await http.post(
        Uri.parse(routeStep1),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _paso = 2);
      } else {
        final data = jsonDecode(response.body);
        _mostrarError(data["error"] ?? "Error al enviar el código");
      }
    } catch (e) {
      _mostrarError("Error de conexión: $e");
    } finally {
      setState(() => _cargando = false);
    }
  }

  // PASO 2: verificar código y cambiar contraseña
  Future<void> resetearPassword() async {
    if (!_formKeyPaso2.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final response = await http.post(
        Uri.parse(routeStep2),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "codigo": codigoController.text.trim(),
          "nueva_password": nuevaPwController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _paso = 3);
      } else {
        final data = jsonDecode(response.body);
        _mostrarError(data["error"] ?? "Código inválido o expirado");
      }
    } catch (e) {
      _mostrarError("Error de conexión: $e");
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // =============================== UI ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text("Recuperar Contraseña", style: titleTextStyle),
              const SizedBox(height: 40),
              if (_paso == 1) _buildPaso1(),
              if (_paso == 2) _buildPaso2(),
              if (_paso == 3) _buildPaso3(),
            ],
          ),
        ),
      ),
    );
  }

  // Paso 1 — ingresar email
  Widget _buildPaso1() {
    return Form(
      key: _formKeyPaso1,
      child: Column(
        children: [
          const Text(
            "Ingresa tu correo para enviar el código de recuperación.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Correo electrónico",
              hintText: "ej: example@gmail.com",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Campo vacío";
              if (!value.contains("@")) return "Formato inválido";
              return null;
            },
          ),
          const SizedBox(height: 24),
          _botonPrincipal(
            label: "Enviar código",
            onPressed: enviarEmail,
          ),
        ],
      ),
    );
  }

  // Paso 2 — ingresar código + nueva contraseña
  Widget _buildPaso2() {
    return Form(
      key: _formKeyPaso2,
      child: Column(
        children: [
          Text(
            "Revisá tu correo ${emailController.text} e ingresa el código que te enviamos.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: codigoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Código de verificación",
              hintText: exampleCode,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Campo vacío";
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: nuevaPwController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Nueva contraseña",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return "Campo vacío";
              return null;
            },
          ),
          const SizedBox(height: 24),
          _botonPrincipal(
            label: "Cambiar contraseña",
            onPressed: resetearPassword,
          ),
          const SizedBox(height: 12),
          // Volver al paso 1 si se equivocó de email
          TextButton(
            onPressed: () => setState(() => _paso = 1),
            child: const Text("Cambiar correo"),
          ),
        ],
      ),
    );
  }

  // Paso 3 — éxito
  Widget _buildPaso3() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 64),
        const SizedBox(height: 16),
        const Text(
          "Contraseña actualizada",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text("Ya puedes iniciar sesión con tu nueva contraseña."),
        const SizedBox(height: 32),
        _botonPrincipal(
          label: "Ir al login",
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          ),
        ),
      ],
    );
  }

  Widget _botonPrincipal({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: interfaceColor,
          padding: const EdgeInsets.all(16),
        ),
        onPressed: _cargando ? null : onPressed,
        child: _cargando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(label, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}