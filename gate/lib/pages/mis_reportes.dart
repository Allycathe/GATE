import 'package:flutter/material.dart';
import 'report_detail.dart';
import '../config.dart';
import '../custom_widgets/option_menu.dart';
import '../routes.dart';
import '../services/report_service.dart';
import '../utils.dart';

class MisReportes extends StatefulWidget {
  const MisReportes({super.key});

  @override
  State<MisReportes> createState() => _MisReportesState();
}

class _MisReportesState extends State<MisReportes> {
  late Future<List<dynamic>> _futureReportes;

  @override
  void initState() {
    super.initState();
    _futureReportes = ReportService.listarReportes();
  }

  void _recargar() {
    setState(() => _futureReportes = ReportService.listarReportes());
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
                        "Mis reportes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
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
                ),

                const SizedBox(height: 16),

                // Lista
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _futureReportes,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white54),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wifi_off_rounded,
                                  color: Colors.white24, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                "Error al cargar reportes",
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 15),
                              ),
                            ],
                          ),
                        );
                      }

                      final todos = snapshot.data!;
                      final misReportes = todos
                          .where((r) => r["id_user"] == userId)
                          .toList();

                      if (misReportes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inbox_outlined,
                                  color: Colors.white24, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                "Aún no tienes reportes",
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 15),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        itemCount: misReportes.length,
                        itemBuilder: (context, index) {
                          final r = misReportes[index];
                          final id = r["id"];
                          final nombre =
                              r["nombre_sospechoso"] ?? "Desconocido";
                          final descripcion =
                              r["description"] ?? "Sin descripción";
                          final fecha = formatearFecha(r["date"]?.toString());
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                            onTap: () async {
                              final actualizado = await Navigator.push<bool>(
                                context,
                                slideRoute(ReportDetailPage(
                                  reporte: Map<String, dynamic>.from(r),
                                  puedeEditar: true,
                                )),
                              );
                              if (actualizado == true) _recargar();
                            },
                            borderRadius: BorderRadius.circular(16),
                            splashColor: Colors.white.withOpacity(0.06),
                            highlightColor: Colors.white.withOpacity(0.04),
                            child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Imagen
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      '$baseUrl/reportes/$id/imagen',
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                      headers: {
                                        'Authorization': 'Bearer $userToken'
                                      },
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.white.withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                            Icons.person_outline,
                                            color: Colors.white30,
                                            size: 32),
                                      ),
                                      loadingBuilder: (_, child, progress) {
                                        if (progress == null) return child;
                                        return Container(
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                                color: Colors.white38,
                                                strokeWidth: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                nombre,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "#$id",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.4),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          descripcion,
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.55),
                                            fontSize: 13,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time_outlined,
                                                color: Colors.white30,
                                                size: 13),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                fecha,
                                                style: TextStyle(
                                                    color: Colors.white30,
                                                    fontSize: 12),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ),
                          );
                        },
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
}
