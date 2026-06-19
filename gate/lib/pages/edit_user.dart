import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gate/pages/encargado.dart';
import 'package:gate/services/api_client.dart';
import 'package:gate/config.dart';

class EditUserPage extends StatefulWidget {
  final int editUserId;
  const EditUserPage({super.key, required this.editUserId});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  bool _isAdmin = false;
  bool _pwVisible = false;
  bool _cargando = false;
  bool _cargandoDatos = true;

  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final response = await ApiClient.get('/usuarios/perfil/${widget.editUserId}');
      final data = jsonDecode(response.body);
      setState(() {
        _nombreCtrl.text = data['name'] ?? '';
        _apellidoCtrl.text = data['last_name'] ?? '';
        _emailCtrl.text = data['email'] ?? '';
        _isAdmin = data['isadmin'] ?? false;
        _cargandoDatos = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando datos: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final body = {
        'name': _nombreCtrl.text.trim(),
        'last_name': _apellidoCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'isadmin': _isAdmin,
        if (_pwCtrl.text.isNotEmpty) 'password': _pwCtrl.text,
      };
      final response = await ApiClient.put('/usuarios/${widget.editUserId}', body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const AdminPage()));
        }
      } else {
        final data = jsonDecode(response.body);
        _showError(data['error'] ?? 'Error al actualizar usuario');
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A3A6B),
        title: const Text('Eliminar usuario', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que querés eliminar este usuario? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) _deleteUser();
  }

  Future<void> _deleteUser() async {
    setState(() => _cargando = true);
    try {
      final response = await ApiClient.delete('/usuarios/${widget.editUserId}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const AdminPage()));
        }
      } else {
        _showError('Error al eliminar usuario');
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
          child: _cargandoDatos
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Text(
                              'Editar Usuario',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: _confirmDelete,
                            tooltip: 'Eliminar usuario',
                          ),
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
                              _buildField(_nombreCtrl, 'Nombre', 'ej: Mohammed',
                                  Icons.person),
                              const SizedBox(height: 16),
                              _buildField(_apellidoCtrl, 'Apellido',
                                  'ej: González', Icons.person_outline),
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

  Widget _buildField(TextEditingController ctrl, String label, String hint,
      IconData icon) {
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
      decoration: _inputDeco(
              'Nueva contraseña', 'Dejar vacío para no cambiar', Icons.lock)
          .copyWith(
        suffixIcon: IconButton(
          icon: Icon(
              _pwVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.white54),
          onPressed: () => setState(() => _pwVisible = !_pwVisible),
        ),
      ),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _cargando ? null : _submit,
        child: _cargando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Text('Guardar Cambios',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
