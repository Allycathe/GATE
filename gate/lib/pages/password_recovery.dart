import 'dart:convert';
import 'package:flutter/material.dart';
import '../routes.dart';
import 'package:flutter/services.dart';
import 'package:gate/config.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

final routeStep1 = "$baseUrl/auth/recuperar";
final routeStep2 = "$baseUrl/auth/recuperar/resetear";

class PwRecoveryPage extends StatefulWidget {
  const PwRecoveryPage({super.key});

  @override
  State<PwRecoveryPage> createState() => _PwRecoveryPageState();
}

class _PwRecoveryPageState extends State<PwRecoveryPage> {
  int _paso = 1;
  bool _cargando = false;
  bool _obscurePassword = true;

  final _formKeyPaso1 = GlobalKey<FormState>();
  final _formKeyPaso2 = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codigoController = TextEditingController();
  final _nuevaPwController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _codigoController.dispose();
    _nuevaPwController.dispose();
    super.dispose();
  }

  Future<void> _enviarEmail() async {
    if (!_formKeyPaso1.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final response = await http.post(
        Uri.parse(routeStep1),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": _emailController.text.trim()}),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        setState(() => _paso = 2);
      } else {
        final data = jsonDecode(response.body);
        _mostrarError(data["error"] ?? "Error al enviar el código");
      }
    } catch (e) {
      _mostrarError("Error de conexión: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _resetearPassword() async {
    if (!_formKeyPaso2.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final response = await http.post(
        Uri.parse(routeStep2),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "codigo": _codigoController.text.trim(),
          "nueva_password": _nuevaPwController.text,
        }),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        setState(() => _paso = 3);
      } else {
        final data = jsonDecode(response.body);
        _mostrarError(data["error"] ?? "Código inválido o expirado");
      }
    } catch (e) {
      _mostrarError("Error de conexión: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1B3E),
                  Color(0xFF1A3A6B),
                  Color(0xFF0D1B3E),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Círculos decorativos
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white70, size: 20),
                      ),
                      const Text(
                        "Recuperar contraseña",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          // Indicador de pasos
                          if (_paso < 3) ...[
                            const SizedBox(height: 24),
                            _buildStepIndicator(),
                            const SizedBox(height: 32),
                          ] else
                            const SizedBox(height: 40),

                          if (_paso == 1) _buildPaso1(),
                          if (_paso == 2) _buildPaso2(),
                          if (_paso == 3) _buildPaso3(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepDot(1, "Correo"),
        _stepLine(activo: _paso >= 2),
        _stepDot(2, "Código"),
      ],
    );
  }

  Widget _stepDot(int numero, String label) {
    final activo = _paso >= numero;
    final esCurrent = _paso == numero;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: activo ? interfaceColor : Colors.white.withOpacity(0.1),
            border: Border.all(
              color: esCurrent
                  ? interfaceColor
                  : activo
                      ? interfaceColor
                      : Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: activo && _paso > numero
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '$numero',
                    style: TextStyle(
                      color: activo ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: activo ? Colors.white70 : Colors.white30,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _stepLine({required bool activo}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        width: 60,
        height: 2,
        color: activo ? interfaceColor : Colors.white.withOpacity(0.15),
      ),
    );
  }

  // Paso 1 — email
  Widget _buildPaso1() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.email_outlined,
                  color: Colors.white38, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Te enviaremos un código de 6 dígitos a tu correo.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKeyPaso1,
          child: Column(
            children: [
              _buildLabel("Correo electrónico"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                decoration: _inputDecoration(
                  hint: "example@gmail.com",
                  icon: Icons.email_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Campo vacío";
                  if (!value.contains("@")) return "Formato inválido";
                  return null;
                },
              ),
              const SizedBox(height: 28),
              _botonPrincipal(
                  label: "Enviar código", onPressed: _enviarEmail),
            ],
          ),
        ),
      ],
    );
  }

  // Paso 2 — código + nueva contraseña
  Widget _buildPaso2() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.mark_email_read_outlined,
                  color: Colors.white38, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Código enviado a ${_emailController.text}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKeyPaso2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Código de verificación"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codigoController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLength: 6,
                decoration: _inputDecoration(
                  hint: "000000",
                  icon: Icons.pin_outlined,
                ).copyWith(counterText: ""),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Campo vacío";
                  if (value.length < 6) return "El código tiene 6 dígitos";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildLabel("Nueva contraseña"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nuevaPwController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  hint: "••••••••",
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white38,
                      size: 20,
                    ),
                    onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Campo vacío";
                  if (value.length < 6)
                    return "Mínimo 6 caracteres";
                  return null;
                },
              ),
              const SizedBox(height: 28),
              _botonPrincipal(
                  label: "Cambiar contraseña",
                  onPressed: _resetearPassword),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _paso = 1),
                  child: Text(
                    "Cambiar correo",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Paso 3 — éxito
  Widget _buildPaso3() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF10B981).withOpacity(0.15),
            border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.4), width: 2),
          ),
          child: const Icon(Icons.check_rounded,
              color: Color(0xFF10B981), size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          "Contraseña actualizada",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Ya puedes iniciar sesión con tu nueva contraseña.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        _botonPrincipal(
          label: "Ir al login",
          onPressed: () => Navigator.pushReplacement(
            context,
            fadeRoute(const LoginPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.75),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _botonPrincipal(
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _cargando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: interfaceColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: interfaceColor.withOpacity(0.4),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _cargando
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: interfaceColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Color(0xFFEF4444)),
    );
  }
}
