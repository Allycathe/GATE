import 'package:flutter/material.dart';
import 'package:gate/pages/edit_report.dart';
import '../config.dart';
import '../custom_widgets/navbar.dart';
import '../custom_widgets/option_menu.dart';
import '../services/report_service.dart';
import '../utils.dart';

class MisReportes extends StatefulWidget {
  const MisReportes({super.key});
  @override
  State<MisReportes> createState() => _MisReportesState();
}

class _MisReportesState extends State<MisReportes> {
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
      final todos = await ReportService.listarReportes();
      final mios = todos.where((r) => r['id_user'] == userId).toList();
      setState(() {
        _reportes = mios;
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
          Expanded(child: _buildBody()),
          const OptionContainer(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Error cargando reportes', style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _cargar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(backgroundColor: interfaceColor),
            ),
          ],
        ),
      );
    }
    if (_reportes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No tenés reportes registrados.',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        itemCount: _reportes.length,
        itemBuilder: (_, i) => _buildCard(_reportes[i]),
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
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EditReportPage(editReportId: id)),
            );
            _cargar();
          },
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
                      loadingBuilder: (_, child, progress) => progress == null
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
