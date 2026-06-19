import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    _marcarLeidas();
  }

  Future<void> _marcarLeidas() async {
    await NotificationService.marcarTodasLeidas();
    if (mounted) setState(() {});
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diff = ahora.difference(fecha);

    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';

    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  String _labelNivel(AlertLevel nivel, double? distancia) {
    final dist = distancia != null ? ' · ${distancia.toStringAsFixed(1)} km' : '';
    switch (nivel) {
      case AlertLevel.rojo:
        return 'Muy cerca$dist';
      case AlertLevel.naranja:
        return 'Distancia media$dist';
      case AlertLevel.amarillo:
        return 'Lejos$dist';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifs = NotificationService.notificaciones;

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
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white70, size: 20),
                      ),
                      const Text(
                        "Alertas",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (notifs.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            await NotificationService.limpiar();
                            setState(() {});
                          },
                          child: Text(
                            "Limpiar",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Leyenda de colores
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _legendaDot(const Color(0xFFEF4444), "< 2 km"),
                      const SizedBox(width: 16),
                      _legendaDot(const Color(0xFFF97316), "2–5 km"),
                      const SizedBox(width: 16),
                      _legendaDot(const Color(0xFFFBBF24), "> 5 km"),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: notifs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.notifications_off_outlined,
                                  color: Colors.white24, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                "Sin alertas recibidas",
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: notifs.length,
                          itemBuilder: (context, index) {
                            final n = notifs[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: n.color.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: n.color.withOpacity(0.25)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Indicador de color
                                    Container(
                                      width: 4,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: n.color,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  n.titulo,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                _formatearFecha(n.fecha),
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.35),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            n.cuerpo,
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.6),
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          // Badge distancia
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: n.color.withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color:
                                                      n.color.withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              _labelNivel(n.nivel, n.distanciaKm),
                                              style: TextStyle(
                                                color: n.color,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendaDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      ],
    );
  }
}
