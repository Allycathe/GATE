import 'package:flutter/material.dart';
import '../routes.dart';
import 'package:gate/custom_widgets/option_menu.dart';
import '/config.dart';
import 'login.dart';

void logout(BuildContext context) {
  userToken = "";
  userId = 0;
  userEmail = "";
  userName = "";
  userLastName = "";
  userIsAdmin = false;
  userSupermarketId = 0;

  Navigator.pushAndRemoveUntil(
    context,
    fadeRoute(const LoginPage()),
    (route) => false,
  );
}

class UserOptions extends StatelessWidget {
  const UserOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final initials =
        "${userName.isNotEmpty ? userName[0] : ''}${userLastName.isNotEmpty ? userLastName[0] : ''}"
            .toUpperCase();

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

          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
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
                        "Opciones de cuenta",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/profile_pic.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: interfaceColor,
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          "$userName $userLastName",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 36),

                        _sectionLabel("Cuenta"),
                        const SizedBox(height: 10),

                        _optionTile(
                          icon: Icons.photo_camera_outlined,
                          label: "Cambiar foto de perfil",
                          onTap: () {},
                        ),

                        const SizedBox(height: 32),

                        _sectionLabel("Sesión"),
                        const SizedBox(height: 10),

                        InkWell(
                          onTap: () => _confirmarLogout(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    const Color(0xFFEF4444).withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.logout_rounded,
                                    color: Color(0xFFEF4444), size: 20),
                                SizedBox(width: 14),
                                Text(
                                  "Cerrar sesión",
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.chevron_right_rounded,
                                    color: Color(0xFFEF4444), size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.25), size: 20),
          ],
        ),
      ),
    );
  }

  void _confirmarLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A3A6B),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Cerrar sesión",
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "¿Estás seguro que deseas cerrar sesión?",
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancelar",
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logout(context);
            },
            child: const Text(
              "Cerrar sesión",
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
