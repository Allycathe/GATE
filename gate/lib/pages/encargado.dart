import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gate/pages/edit_user.dart';
import 'package:gate/pages/new_user.dart';
import '../config.dart';
import '../services/api_client.dart';
import '../custom_widgets/option_menu.dart';
import '../custom_widgets/app_header.dart';
import '../routes.dart';

Future<List<dynamic>> getUsers() async {
  final response = await ApiClient.get('/usuarios/');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["usuarios"];
  } else {
    throw Exception("Error cargando usuarios");
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<List<dynamic>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = getUsers();
  }

  void _recargar() {
    setState(() => _futureUsers = getUsers());
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

          SafeArea(
            child: Column(
              children: [
                AppHeader(
                  titulo: "Panel admin",
                  mostrarVolver: true,
                  acciones: [
                    GestureDetector(
                      onTap: _recargar,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12)),
                        ),
                        child: const Icon(Icons.refresh_rounded,
                            color: Colors.white70, size: 20),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Botón añadir usuario
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          slideUpRoute(NewUserPage()),
                        );
                        _recargar();
                      },
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: const Text(
                        "Añadir usuario",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: interfaceColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _futureUsers,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white54),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("Error al cargar usuarios",
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 15)),
                        );
                      }

                      final todos = snapshot.data!;
                      final encargados = todos
                          .where((u) =>
                              u["id_supermarket"] == userSupermarketId &&
                              u["isadmin"] == true)
                          .toList();
                      final guardias = todos
                          .where((u) =>
                              u["id_supermarket"] == userSupermarketId &&
                              u["isadmin"] == false)
                          .toList();

                      return ListView(
                        padding:
                            const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        children: [
                          // Sección encargados
                          _sectionHeader(
                            icon: Icons.admin_panel_settings_outlined,
                            label: "Encargados",
                            count: encargados.length,
                            color: const Color(0xFFFBFF16),
                          ),
                          const SizedBox(height: 10),
                          if (encargados.isEmpty)
                            _emptyState("Sin encargados registrados")
                          else
                            ...encargados.map((u) => _userCard(
                                  context,
                                  user: u,
                                  esEncargado: true,
                                )),

                          const SizedBox(height: 24),

                          // Sección guardias
                          _sectionHeader(
                            icon: Icons.security_outlined,
                            label: "Guardias",
                            count: guardias.length,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 10),
                          if (guardias.isEmpty)
                            _emptyState("Sin guardias registrados")
                          else
                            ...guardias.map((u) => _userCard(
                                  context,
                                  user: u,
                                  esEncargado: false,
                                )),
                        ],
                      );
                    },
                  ),
                ),

                const OptionContainer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "$count",
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _userCard(BuildContext context,
      {required Map user, required bool esEncargado}) {
    final nombre = "${user["name"]} ${user["last_name"]}";
    final email = user["email"] ?? "";
    final id = user["id"];
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : "?";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Avatar inicial
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: esEncargado
                    ? const Color(0xFFFBFF16).withOpacity(0.15)
                    : interfaceColor.withOpacity(0.2),
                border: Border.all(
                  color: esEncargado
                      ? const Color(0xFFFBFF16).withOpacity(0.4)
                      : interfaceColor.withOpacity(0.4),
                ),
              ),
              child: Center(
                child: Text(
                  inicial,
                  style: TextStyle(
                    color: esEncargado
                        ? const Color(0xFFFBFF16)
                        : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Badge rol
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: esEncargado
                    ? const Color(0xFFFBFF16).withOpacity(0.1)
                    : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                esEncargado ? "Encargado" : "Guardia",
                style: TextStyle(
                  color: esEncargado
                      ? const Color(0xFFFBFF16)
                      : Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Botón editar
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  slideRoute(EditUserPage(editUserId: id)),
                );
                _recargar();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: const Icon(Icons.edit_outlined,
                    color: Colors.white60, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String mensaje) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        mensaje,
        style: TextStyle(color: Colors.white30, fontSize: 13),
      ),
    );
  }
}
