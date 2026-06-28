import 'package:flutter/material.dart';
import '../routes.dart';
import 'package:gate/pages/mapa_screen.dart';
import 'package:gate/pages/mis_reportes.dart';

import '../config.dart';
import '../custom_widgets/option_menu.dart';
import '../custom_widgets/app_header.dart';
import '../services/report_service.dart';
import '../utils.dart';
import 'report_detail.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool cargando = true;
  String? mensajeError;
  List<dynamic> reportes = [];

  // Filtros
  final _searchController = TextEditingController();
  String _busqueda = "";
  int? _sucursalFiltro; // null = todas
  String _ordenFiltro = "reciente"; // "reciente" | "antiguo"

  @override
  void initState() {
    super.initState();
    cargarReportes();
    _searchController.addListener(() {
      setState(() => _busqueda = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> cargarReportes() async {
    setState(() => cargando = true);
    try {
      final data = await ReportService.listarReportes();
      setState(() {
        reportes = data;
        cargando = false;
        mensajeError = null;
      });
    } catch (error) {
      setState(() {
        cargando = false;
        mensajeError = error.toString();
      });
    }
  }

  List<dynamic> get _reportesFiltrados {
    var lista = List<dynamic>.from(reportes);

    // Filtro por nombre
    if (_busqueda.isNotEmpty) {
      lista = lista.where((r) {
        final nombre = (r["nombre_sospechoso"] ?? "").toLowerCase();
        final desc = (r["description"] ?? "").toLowerCase();
        return nombre.contains(_busqueda) || desc.contains(_busqueda);
      }).toList();
    }

    // Filtro por sucursal
    if (_sucursalFiltro != null) {
      lista =
          lista.where((r) => r["id_supermarket"] == _sucursalFiltro).toList();
    }

    // Ordenar
    lista.sort((a, b) {
      final fechaA = DateTime.tryParse(a["date"] ?? "") ?? DateTime(0);
      final fechaB = DateTime.tryParse(b["date"] ?? "") ?? DateTime(0);
      return _ordenFiltro == "reciente"
          ? fechaB.compareTo(fechaA)
          : fechaA.compareTo(fechaB);
    });

    return lista;
  }

  List<int> get _sucursalesDisponibles {
    final ids = reportes
        .map((r) => r["id_supermarket"] as int?)
        .whereType<int>()
        .toSet()
        .toList();
    ids.sort();
    return ids;
  }

  bool get _hayFiltrosActivos =>
      _busqueda.isNotEmpty ||
      _sucursalFiltro != null ||
      _ordenFiltro != "reciente";

  void _limpiarFiltros() {
    setState(() {
      _searchController.clear();
      _busqueda = "";
      _sucursalFiltro = null;
      _ordenFiltro = "reciente";
    });
  }


  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A3A6B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Filtros",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Orden
                  Text("Ordenar por",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _filterChip(
                        label: "Más reciente",
                        selected: _ordenFiltro == "reciente",
                        onTap: () {
                          setModalState(() => _ordenFiltro = "reciente");
                          setState(() => _ordenFiltro = "reciente");
                        },
                      ),
                      const SizedBox(width: 8),
                      _filterChip(
                        label: "Más antiguo",
                        selected: _ordenFiltro == "antiguo",
                        onTap: () {
                          setModalState(() => _ordenFiltro = "antiguo");
                          setState(() => _ordenFiltro = "antiguo");
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sucursal
                  Text("Sucursal",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChip(
                        label: "Todas",
                        selected: _sucursalFiltro == null,
                        onTap: () {
                          setModalState(() => _sucursalFiltro = null);
                          setState(() => _sucursalFiltro = null);
                        },
                      ),
                      ..._sucursalesDisponibles.map((id) => _filterChip(
                            label: "Local $id",
                            selected: _sucursalFiltro == id,
                            onTap: () {
                              setModalState(() => _sucursalFiltro = id);
                              setState(() => _sucursalFiltro = id);
                            },
                          )),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Botón limpiar
                  if (_hayFiltrosActivos)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          _limpiarFiltros();
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Limpiar filtros",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _reportesFiltrados;

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
                AppHeader(
                  titulo: "Reportes",
                  mostrarCampana: true,
                  acciones: [
                    GestureDetector(
                      onTap: _mostrarFiltros,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _hayFiltrosActivos
                              ? interfaceColor.withOpacity(0.3)
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _hayFiltrosActivos
                                ? interfaceColor.withOpacity(0.6)
                                : Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Icon(Icons.tune_rounded,
                            color: _hayFiltrosActivos
                                ? Colors.white
                                : Colors.white70,
                            size: 20),
                      ),
                    ),
                    GestureDetector(
                      onTap: cargarReportes,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12)),
                        ),
                        child: cargando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh_rounded,
                                color: Colors.white70, size: 20),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Barra de búsqueda
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Buscar por nombre o descripción...",
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.25), fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Colors.white38, size: 20),
                      suffixIcon: _busqueda.isNotEmpty
                          ? GestureDetector(
                              onTap: () => _searchController.clear(),
                              child: const Icon(Icons.close_rounded,
                                  color: Colors.white38, size: 18),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.15)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            BorderSide(color: interfaceColor, width: 1.5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Acciones rápidas
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.map_outlined,
                          label: "Ver mapa",
                          onTap: () => Navigator.push(
                            context,
                            slideRoute(const PantallaMapa()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.person_search_outlined,
                          label: "Mis reportes",
                          onTap: () => Navigator.push(
                            context,
                            slideRoute(const MisReportes()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Subtítulo + contador
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        _hayFiltrosActivos ? "Resultados" : "Recientes",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!cargando && mensajeError == null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: interfaceColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${filtrados.length}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (_hayFiltrosActivos) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: _limpiarFiltros,
                          child: Text(
                            "Limpiar",
                            style: TextStyle(
                              color: interfaceColor.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Lista
                Expanded(
                  child: _buildContent(filtrados),
                ),

                const OptionContainer(paginaActual: NavPage.reportes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<dynamic> filtrados) {
    if (cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white54),
      );
    }
    if (mensajeError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white24, size: 48),
            const SizedBox(height: 12),
            Text("Error al cargar reportes",
                style: TextStyle(color: Colors.white60, fontSize: 15)),
          ],
        ),
      );
    }
    if (filtrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                color: Colors.white24, size: 48),
            const SizedBox(height: 12),
            Text(
              _hayFiltrosActivos
                  ? "Sin resultados para ese filtro"
                  : "No hay reportes registrados",
              style: TextStyle(color: Colors.white60, fontSize: 15),
            ),
            if (_hayFiltrosActivos) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _limpiarFiltros,
                child: Text(
                  "Limpiar filtros",
                  style: TextStyle(
                    color: interfaceColor.withOpacity(0.8),
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    decorationColor: interfaceColor.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final reporte = filtrados[index];
        final id = reporte["id"];
        final nombre = reporte["nombre_sospechoso"] ?? "Desconocido";
        final descripcion = reporte["description"] ?? "Sin descripción";
        final fecha = formatearFecha(reporte["date"]);
        final idSupermarket = reporte["id_supermarket"];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              slideRoute(ReportDetailPage(
                reporte: Map<String, dynamic>.from(reporte),
                puedeEditar: reporte["id_user"] == userId,
              )),
            ),
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white.withOpacity(0.06),
            highlightColor: Colors.white.withOpacity(0.04),
            child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                    height: 90,
                    width: 90,
                    fit: BoxFit.cover,
                    headers: {'Authorization': 'Bearer $userToken'},
                    errorBuilder: (_, __, ___) => Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_outline,
                          color: Colors.white30, size: 36),
                    ),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white38, strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "#$id",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
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
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.store_outlined,
                              color: Colors.white30, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            "Local $idSupermarket",
                            style: TextStyle(
                                color: Colors.white30, fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time_outlined,
                              color: Colors.white30, size: 13),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              fecha,
                              style: TextStyle(
                                  color: Colors.white30, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
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
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? interfaceColor : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? interfaceColor
                : Colors.white.withOpacity(0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white.withOpacity(0.6),
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
