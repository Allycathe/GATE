import 'package:flutter/material.dart';
import '../custom_widgets/notification_bell.dart';

class AppHeader extends StatelessWidget {
  final String? titulo;
  final bool mostrarVolver;
  final bool mostrarCampana;
  final List<Widget>? acciones;

  const AppHeader({
    super.key,
    this.titulo,
    this.mostrarVolver = false,
    this.mostrarCampana = false,
    this.acciones,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
      child: Row(
        children: [
          if (mostrarVolver)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 20),
            )
          else
            const SizedBox(width: 8),

          // Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Image.asset(
              'assets/gate_logo.png',
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.shield_outlined,
                color: Color(0xFF1A3A6B),
                size: 24,
              ),
            ),
          ),

          if (titulo != null) ...[
            const SizedBox(width: 12),
            Text(
              titulo!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          const Spacer(),

          if (acciones != null)
            ...acciones!.map((w) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: w,
                )),

          if (mostrarCampana) ...[
            const SizedBox(width: 8),
            const NotificationBell(),
          ],
        ],
      ),
    );
  }
}
