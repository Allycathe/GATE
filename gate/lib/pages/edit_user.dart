import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gate/config.dart';
import '../custom_widgets/app_header.dart';
import '../services/api_client.dart';

class EditUserPage extends StatefulWidget {
  final int editUserId;

  const EditUserPage({super.key, required this.editUserId});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _isAdmin = false;
  bool _loading = false;
  bool _loadingData = true;
  bool _pwVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final response = await ApiClient.get('/usuarios/perfil/${widget.editUserId}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _nombreCtrl.text = data["name"] ?? "";
            _apellidoCtrl.text = data["last_name"] ?? "";
            _emailCtrl.text = data["email"] ?? "";
            _isAdmin = data["isadmin"] ?? false;
            _loadingData = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final response = await ApiClient.put(
        '/usuarios/${widget.editUserId}',
        jsonEncode({
          "name": _nombreCtrl.text.trim(),
          "last_name": _apellidoCtrl.text.trim(),
          "email": _emailCtrl.text.trim(),
          "isadmin": _isAdmin,
          if (_pwCtrl.text.isNotEmpty) "password": _pwCtrl.text,
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Error al guardar cambios"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error de conexión: $e"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A3A6B),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Eliminar usuario",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          "¿Estás seguro de que deseas eliminar este usuario? Esta acción no se puede deshacer.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar",
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Eliminar",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) await _deleteUser();
  }

  Future<void> _deleteUser() async {
    setState(() => _loading = true);
    try {
      final response = await ApiClient.delete('/usuarios/${widget.editUserId}');
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 204) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Error al eliminar usuario"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error de conexión: $e"),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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

          SafeArea(
            child: Column(
              children: [
                AppHeader(titulo: "Editar usuario", mostrarVolver: true),

                Expanded(
                  child: _loadingData
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white54),
                        )
                      : SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(24, 24, 24, 32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label("Nombre"),
                                const SizedBox(height: 8),
                                _field(
                                  controller: _nombreCtrl,
                                  hint: "ej: Mohammed",
                                  icon: Icons.person_outline,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? "Campo requerido"
                                      : null,
                                ),

                                const SizedBox(height: 16),
                                _label("Apellido"),
                                const SizedBox(height: 8),
                                _field(
                                  controller: _apellidoCtrl,
                                  hint: "ej: Gonzales",
                                  icon: Icons.person_outline,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? "Campo requerido"
                                      : null,
                                ),

                                const SizedBox(height: 16),
                                _label("Correo electrónico"),
                                const SizedBox(height: 8),
                                _field(
                                  controller: _emailCtrl,
                                  hint: "ej: usuario@email.com",
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                        RegExp(r'\s')),
                                  ],
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return "Campo requerido";
                                    if (!v.contains("@"))
                                      return "Formato inválido";
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),
                                _label("Nueva contraseña (opcional)"),
                                const SizedBox(height: 8),
                                _passwordField(),

                                const SizedBox(height: 24),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: SwitchListTile(
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16),
                                    title: const Text(
                                      "¿Es administrador?",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      _isAdmin ? "Encargado" : "Guardia",
                                      style: TextStyle(
                                        color: _isAdmin
                                            ? const Color(0xFFFBFF16)
                                            : Colors.white38,
                                        fontSize: 12,
                                      ),
                                    ),
                                    value: _isAdmin,
                                    activeColor: const Color(0xFFFBFF16),
                                    activeTrackColor:
                                        const Color(0xFFFBFF16).withOpacity(0.3),
                                    inactiveThumbColor: Colors.white38,
                                    inactiveTrackColor: Colors.white12,
                                    onChanged: (v) =>
                                        setState(() => _isAdmin = v),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: interfaceColor,
                                      disabledBackgroundColor:
                                          interfaceColor.withOpacity(0.5),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2),
                                          )
                                        : const Text(
                                            "Guardar cambios",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        _loading ? null : _confirmDelete,
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent, size: 20),
                                    label: const Text(
                                      "Eliminar usuario",
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Colors.redAccent,
                                          width: 1.5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                    ),
                                  ),
                                ),
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

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w500),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: interfaceColor.withOpacity(0.7)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _pwCtrl,
      obscureText: !_pwVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Dejar vacío para no cambiar",
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
        prefixIcon:
            const Icon(Icons.lock_outline, color: Colors.white38, size: 20),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _pwVisible = !_pwVisible),
          icon: Icon(
            _pwVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.white38,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: interfaceColor.withOpacity(0.7)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
