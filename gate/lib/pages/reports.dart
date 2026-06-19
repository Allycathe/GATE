import 'package:flutter/material.dart';
import 'package:gate/pages/mapa_screen.dart';
import 'package:gate/pages/mis_reportes.dart';
import 'package:gate/pages/report_detail.dart';
import '../config.dart';
import '../custom_widgets/option_menu.dart';
import '../custom_widgets/navbar.dart';
import '../services/report_service.dart';
import '../utils.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool _cargando = true;
  String? _error;
  List<dynamic> _reportes = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final data = await ReportService.listarReportes();
      setState(() {
        _reportes = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PantallaMapa()),
                          ),
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Ver mapa'),
                          style: FilledButton.styleFrom(
                            backgroundColor: buttonColor,
                            padding: const EdgeInsets.all(14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MisReportes()),
                          ),
                          icon: const Icon(Icons.person_outline),
                          label: const Text('Mis reportes'),
                          style: FilledButton.styleFrom(
                            backgroundColor: interfaceColor,
                            padding: const EdgeInsets.all(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Reportes recientes',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _cargar,
                        tooltip: 'Actualizar',
                        color: interfaceColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_cargando)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator()))
                  else if (_error != null)
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text('Error cargando reportes',
                              style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _cargar,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                            style: FilledButton.styleFrom(
                                backgroundColor: interfaceColor),
                          ),
                        ],
                      ),
                    )
                  else if (_reportes.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No hay reportes registrados.',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ..._reportes.map((r) => _buildCard(r)),
                ],
              ),
            ),
          ),
          const OptionContainer(),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> r) {
    final id = r['id'];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ReportDetailPage(reporte: r)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Hero(
                  tag: 'reporte_img_$id',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      '$baseUrl/reportes/$id/imagen',
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      headers: {'Authorization': 'Bearer $userToken'},
                      errorBuilder: (_, __, ___) => Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.warning_amber,
                            size: 36, color: Colors.grey),
                      ),
                      loadingBuilder: (_, child, progress) =>
                          progress == null
                              ? child
                              : const SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['nombre_sospechoso'] ?? 'Sin nombre',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            formatearFecha(r['date']),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r['description'] ?? 'Sin descripción',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
