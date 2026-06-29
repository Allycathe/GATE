import 'package:flutter/material.dart';
import '../routes.dart';
import 'package:gate/pages/new_report.dart';
import 'package:gate/pages/reports.dart';
import 'package:gate/pages/profile.dart';
import '../config.dart';

enum NavPage { reportes, perfil, otro }

class OptionContainer extends StatelessWidget {
  final NavPage paginaActual;

  const OptionContainer({super.key, this.paginaActual = NavPage.otro});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B3E),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.list_alt_outlined,
                label: "Reportes",
                activo: paginaActual == NavPage.reportes,
                onTap: paginaActual == NavPage.reportes
                    ? null
                    : () => Navigator.pushReplacement(
                          context,
                          fadeRoute(ReportsPage()),
                        ),
              ),

              // Botón central — siempre disponible
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  slideUpRoute(const NewReport()),
                ),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: interfaceColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: interfaceColor.withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),

              _NavItem(
                icon: Icons.person_outline,
                label: "Perfil",
                activo: paginaActual == NavPage.perfil,
                onTap: paginaActual == NavPage.perfil
                    ? null
                    : () => Navigator.pushReplacement(
                          context,
                          fadeRoute(ProfilePage()),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool activo;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: activo ? Colors.white : Colors.white60,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: activo
                    ? Colors.white
                    : Colors.white.withOpacity(0.55),
                fontSize: 11,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            // Indicador activo
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: activo ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: interfaceColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
