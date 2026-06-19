import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gate/config.dart';
import 'package:gate/pages/encargado.dart';
import 'package:gate/services/api_client.dart';

class NewUserPage extends StatefulWidget {
  const NewUserPage({super.key});
  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  bool _isAdmin = false;
  bool _pwVisible = false;
  bool _cargando = false;

  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final response = await ApiClient.post('/usuarios', {
        'name': _nombreCtrl.text.trim(),
        'last_name': _apellidoCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _pwCtrl.text,
        'isadmin': _isAdmin,
        'id_supermarket': userSupermarketId,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const AdminPage()));
        }
      } else {
        final data = jsonDecode(response.body);
        _showError(data['error'] ?? 'Error al crear usuario');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B3E), Color(0xFF1A3A6B), Color(0xFF0D1B3E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Nuevo Usuario',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildField(_nombreCtrl, 'Nombre', 'ej: Mohammed', Icons.person),
                        const SizedBox(height: 16),
                        _buildField(_apellidoCtrl, 'Apellido', 'ej: González', Icons.person_outline),
                        const SizedBox(height: 16),
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPwField(),
                        const SizedBox(height: 24),
                        _buildAdminToggle(),
                        const SizedBox(height: 32),
                        _buildSubmitBtn(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, String hint, IconData icon) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDeco(label, hint, icon),
      validator: (v) => (v == null || v.isEmpty) ? 'Campo vacío' : null,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      decoration: _inputDeco('Email', 'ej: usuario@email.com', Icons.email),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Campo vacío';
        if (!v.contains('@')) return 'Formato inválido';
        return null;
      },
    );
  }

  Widget _buildPwField() {
    return TextFormField(
      controller: _pwCtrl,
      style: const TextStyle(color: Colors.white),
      obscureText: !_pwVisible,
      decoration: _inputDeco('Contraseña', '••••••••', Icons.lock).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
              _pwVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.white54),
          onPressed: () => setState(() => _pwVisible = !_pwVisible),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Campo vacío' : null,
    );
  }

  Widget _buildAdminToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: SwitchListTile(
        title: const Text('¿Es administrador?',
            style: TextStyle(color: Colors.white)),
        subtitle: Text(
          _isAdmin ? 'Encargado de local' : 'Guardia de seguridad',
          style: TextStyle(
              color: _isAdmin ? Colors.yellow[300] : Colors.white54),
        ),
        value: _isAdmin,
        activeThumbColor: Colors.yellow[400],
        onChanged: (v) => setState(() => _isAdmin = v),
      ),
    );
  }

  Widget _buildSubmitBtn() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: interfaceColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _cargando ? null : _submit,
        child: _cargando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Text('Crear Usuario',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  InputDecoration _inputDeco(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: Colors.white54),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white30),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: interfaceColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.07),
    );
  }
}
