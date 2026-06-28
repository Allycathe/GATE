import 'package:flutter/material.dart';
import '../config.dart';
import '../routes.dart';
import '../utils.dart';
import 'edit_report.dart';

class ReportDetailPage extends StatefulWidget {
  final Map<String, dynamic> reporte;
  final bool puedeEditar; // solo el dueño del reporte puede editar

  const ReportDetailPage({
    super.key,
    required this.reporte,
    this.puedeEditar = false,
  });

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _editado = false;
  bool _descripcionExpandida = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reporte;
    final id = r["id"];
    final nombre = r["nombre_sospechoso"] ?? "Desconocido";
    final descripcion = r["description"] ?? "Sin descripción";
    final fecha = formatearFecha(r["date"]?.toString());
    final idSupermarket = r["id_supermarket"];
    final idUser = r["id_user"];

    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado
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
                        onPressed: () => Navigator.pop(context, _editado),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white70, size: 20),
                      ),
                      const Expanded(
                        child: Text(
                          "Detalle del reporte",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Text(
                          "#$id",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Foto grande
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Hero(
                                tag: "reporte_img_$id",
                                child: Image.network(
                                  '$baseUrl/reportes/$id/imagen',
                                  width: double.infinity,
                                  height: 280,
                                  fit: BoxFit.cover,
                                  headers: {
                                    'Authorization': 'Bearer $userToken'
                                  },
                                  errorBuilder: (_, __, ___) => Container(
                                    width: double.infinity,
                                    height: 280,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person_outline,
                                            color: Colors.white24, size: 64),
                                        const SizedBox(height: 8),
                                        Text("Sin imagen",
                                            style: TextStyle(
                                                color: Colors.white30,
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  loadingBuilder: (_, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      width: double.infinity,
                                      height: 280,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius:
                                            BorderRadius.circular(20),
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
                            ),

                            const SizedBox(height: 24),

                            // Nombre sospechoso
                            Text(
                              nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Tarjeta de info
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              child: Column(
                                children: [
                                  _descripcionRow(descripcion),
                                  _divider(),
                                  _infoRow(
                                    Icons.store_outlined,
                                    "Local",
                                    "Local $idSupermarket",
                                  ),
                                  _divider(),
                                  _infoRow(
                                    Icons.access_time_outlined,
                                    "Fecha",
                                    fecha,
                                  ),
                                  _divider(),
                                  _infoRow(
                                    Icons.person_outline,
                                    "Reportado por",
                                    "Usuario #$idUser",
                                  ),
                                ],
                              ),
                            ),

                            if (widget.puedeEditar) ...[
                              const SizedBox(height: 28),

                              // Botón editar
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push<bool>(
                                      context,
                                      slideRoute(
                                          EditReportPage(editReportId: id)),
                                    );
                                    if (result == true || result == null) {
                                      setState(() => _editado = true);
                                    }
                                  },
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 18, color: Colors.white),
                                  label: const Text(
                                    "Editar reporte",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: interfaceColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _descripcionRow(String descripcion) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined,
                  color: Colors.white38, size: 18),
              const SizedBox(width: 12),
              Text(
                "Descripción",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _descripcionExpandida
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              descripcion,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              descripcion,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
          if (descripcion.length > 120)
            GestureDetector(
              onTap: () =>
                  setState(() => _descripcionExpandida = !_descripcionExpandida),
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _descripcionExpandida ? "Ver menos" : "Ver más",
                  style: TextStyle(
                    color: interfaceColor.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {bool multiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              maxLines: multiline ? 5 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(color: Colors.white.withOpacity(0.07), height: 1);
}
