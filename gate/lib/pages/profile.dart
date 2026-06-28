import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gate/pages/encargado.dart';
import 'dart:convert';
import '../config.dart';
import '../services/api_client.dart';
import '../custom_widgets/option_menu.dart';
import '../custom_widgets/notification_bell.dart';
import '../custom_widgets/app_header.dart';
import '../services/notification_service.dart';
import 'user_options.dart';
import '../routes.dart';

String _nombreSupermarket = "";

String definirRol(bool isAdmin) => isAdmin ? "Encargado" : "Guardia";

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _initFCM();
    loadSupermarketName();
  }

  Future<void> _initFCM() async {
    await NotificationService.cargar();
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final token = await messaging.getToken();
    if (token != null) await _saveFcmToken(token);
    messaging.onTokenRefresh.listen(_saveFcmToken);
    FirebaseMessaging.onMessage.listen((message) async {
      final title = message.notification?.title ?? 'Alerta';
      final body = message.notification?.body ?? '';
      final data = Map<String, dynamic>.from(message.data);

      await NotificationService.agregarDesdeFCM(
        titulo: title,
        cuerpo: body,
        data: data,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title: $body'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }

  Future<void> loadSupermarketName() async {
    try {
      final response = await ApiClient.get('/supermercados/$userSupermarketId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _nombreSupermarket = data["supermercado"]["name"] ?? "Sin nombre";
        });
      }
    } catch (_) {}
  }

  Future<void> _saveFcmToken(String token) async {
    try {
      await ApiClient.put(
        '/usuarios/$userId/fcm-token',
        jsonEncode({'fcm_token': token}),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final rol = definirRol(userIsAdmin);
    final initials =
        "${userName.isNotEmpty ? userName[0] : ''}${userLastName.isNotEmpty ? userLastName[0] : ''}"
            .toUpperCase();

    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado igual que login
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
            top: -60,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -70,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: interfaceColor.withOpacity(0.07),
              ),
            ),
          ),

          // Contenido
          SafeArea(
            child: Column(
              children: [
                const AppHeader(mostrarCampana: true),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Avatar con iniciales
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              userIsAdmin ? 'assets/admin.png' : 'assets/guardia.jpg', // ✅
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: interfaceColor,
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ),

                        const SizedBox(height: 20),

                        // Nombre
                        Text(
                          "$userName $userLastName",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // Badge de rol
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: userIsAdmin
                                ? const Color(0xFFFBFF16).withOpacity(0.15)
                                : interfaceColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: userIsAdmin
                                  ? const Color(0xFFFBFF16).withOpacity(0.5)
                                  : interfaceColor.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            rol,
                            style: TextStyle(
                              color: userIsAdmin
                                  ? const Color(0xFFFBFF16)
                                  : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Tarjeta de info
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Column(
                            children: [
                              _infoRow(Icons.badge_outlined, "ID de usuario",
                                  "#$userId"),
                              _divider(),
                              _infoRow(Icons.email_outlined, "Correo",
                                  userEmail),
                              _divider(),
                              _infoRow(Icons.store_outlined, "Local",
                                  _nombreSupermarket.isEmpty
                                      ? "Cargando..."
                                      : _nombreSupermarket),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botón opciones
                        _actionButton(
                          label: "Opciones de cuenta",
                          icon: Icons.settings_outlined,
                          color: interfaceColor,
                          onTap: () => Navigator.push(
                            context,
                            slideRoute(UserOptions()),
                          ),
                        ),

                        if (userIsAdmin) ...[
                          const SizedBox(height: 12),
                          _actionButton(
                            label: "Panel de administrador",
                            icon: Icons.admin_panel_settings_outlined,
                            color: const Color(0xFFFBFF16),
                            textColor: Colors.black,
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(AdminPage()),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Barra de navegación
                const OptionContainer(paginaActual: NavPage.perfil),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.white.withOpacity(0.08), height: 1);

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: textColor),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
