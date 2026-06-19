import 'package:flutter/material.dart';
import 'package:gate/config.dart';
import 'package:gate/pages/edit_report.dart';
import '../utils.dart';

class ReportDetailPage extends StatelessWidget {
  final Map<String, dynamic> reporte;

  const ReportDetailPage({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    final id = reporte['id'];
    final nombre = reporte['nombre_sospechoso'] ?? 'Sin nombre';
    final descripcion = reporte['description'] ?? 'Sin descripción';
    final fecha = formatearFecha(reporte['date']);
    final idSupermarket = reporte['id_supermarket'];
    final puedeEditar = reporte['id_user'] == userId;

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Detalle del Reporte',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (puedeEditar)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  EditReportPage(editReportId: id)),
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
              Hero(
                tag: 'reporte_img_$id',
                child: Image.network(
                  '$baseUrl/reportes/$id/imagen',
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  headers: {'Authorization': 'Bearer $userToken'},
                  errorBuilder: (_, __, ___) => Container(
                    height: 260,
                    color: const Color(0xFF0A1628),
                    child: const Center(
                      child: Icon(Icons.person_search,
                          size: 80, color: Colors.white24),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.report_problem,
                              color: Colors.orange, size: 16),
                          const SizedBox(width: 6),
                          Text('Reporte #$id',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(nombre,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _infoRow(Icons.calendar_today, 'Fecha', fecha),
                      const SizedBox(height: 12),
                      _infoRow(Icons.store, 'Local', 'Supermercado #$idSupermarket'),
                      const SizedBox(height: 20),
                      const Text('Descripción',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(descripcion,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15, height: 1.5)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(color: Colors.white54, fontSize: 14)),
        Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 14))),
      ],
    );
  }
}
