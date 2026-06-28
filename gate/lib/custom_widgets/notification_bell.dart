import 'dart:math';
import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/notification_service.dart';
import '../pages/notifications_page.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
    NotificationService.addListener(_onNewNotification);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    NotificationService.removeListener(_onNewNotification);
    super.dispose();
  }

  void _onNewNotification() {
    if (mounted) {
      setState(() {});
      _shakeController.forward(from: 0);
    }
  }

  Color _colorForLevel(AlertLevel nivel) {
    switch (nivel) {
      case AlertLevel.rojo:
        return const Color(0xFFEF4444);
      case AlertLevel.naranja:
        return const Color(0xFFF97316);
      case AlertLevel.amarillo:
        return const Color(0xFFFBBF24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nivel = NotificationService.nivelPendiente;
    final noLeidas = NotificationService.noLeidas;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          slideUpRoute(const NotificationsPage()),
        );
        if (mounted) setState(() {});
      },
      child: AnimatedBuilder(
        animation: _shakeAnim,
        builder: (_, child) {
          final angle = sin(_shakeAnim.value * pi * 4) * 0.15;
          return Transform.rotate(angle: angle, child: child);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: nivel != null
                ? _colorForLevel(nivel).withOpacity(0.15)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: nivel != null
                  ? _colorForLevel(nivel).withOpacity(0.4)
                  : Colors.white.withOpacity(0.12),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_outlined,
                color: nivel != null ? _colorForLevel(nivel) : Colors.white70,
                size: 20,
              ),
              if (noLeidas > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: _colorForLevel(nivel ?? AlertLevel.naranja),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF0D1B3E), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        noLeidas > 9 ? '9+' : '$noLeidas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
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
}
