import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import '../config.dart'; // <-- necesario para userToken y baseUrl

import '../services/report_service.dart';

// ─────────────────────────────────────────────
// Constantes
// ─────────────────────────────────────────────
abstract class _MapConstants {
  static const LatLng defaultLocation = LatLng(-33.4489, -70.6693);
  static const double defaultZoom = 14.0;
  static const double minZoom = 5.0;
  static const double maxZoom = 18.0;
  static const double recenterZoom = 15.0;
  static const String apiUrl = 'https://gate.blade.dedyn.io/supermercados';
  static const String tileLight =
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
  static const String tileDark =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
  static const List<String> tileSubdomains = ['a', 'b', 'c'];
  static const String userAgent = 'com.gate.app';
  static const int riskThresholdLow = 1;
  static const int riskThresholdHigh = 3;
}

class Supermercado {
  const Supermercado({
    required this.id,
    required this.nombre,
    required this.ubicacion,
  });

  final int id;
  final String nombre;
  final LatLng ubicacion;

  factory Supermercado.fromJson(Map<String, dynamic> json) {
    final lat = double.tryParse(json['location_y'].toString()) ?? 0.0;
    final lng = double.tryParse(json['location_x'].toString()) ?? 0.0;
    return Supermercado(
      id: json['id'] as int,
      nombre: json['name'] as String,
      ubicacion: LatLng(lat, lng),
    );
  }
}

// ─────────────────────────────────────────────
// PANTALLA PRINCIPAL
// ─────────────────────────────────────────────
class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  LatLng _ubicacionUsuario = _MapConstants.defaultLocation;
  List<Supermercado> _supermercados = [];

  /// Caché de reportes por sucursal
  Map<int, List<dynamic>> _reportesPorSucursal = {};

  bool _cargando = true;
  bool _isDarkMode = false;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ── Inicialización ───────────────────────────────────────────────────

  Future<void> _inicializar() async {
    await _obtenerUbicacion();
    await Future.wait([
      _cargarSupermercados(),
      _cargarTodosLosReportes(),
    ]);
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _recargarDatos() async {
    await Future.wait([
      _cargarSupermercados(),
      _cargarTodosLosReportes(),
    ]);
    if (mounted) setState(() {});
  }

  // ── GPS ──────────────────────────────────────────────────────────────

  Future<void> _obtenerUbicacion() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await _mostrarDialogoUbicacion(
        titulo: 'GPS desactivado',
        mensaje: 'Activa el GPS para continuar.',
        boton: 'Abrir configuración',
        accion: Geolocator.openLocationSettings,
      );
      return _obtenerUbicacion();
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied) {
      await _mostrarDialogoUbicacion(
        titulo: 'Permiso denegado',
        mensaje:
            'Necesitamos tu ubicación para mostrarte supermercados cercanos.',
        boton: 'Reintentar',
        accion: null,
      );
      return _obtenerUbicacion();
    }

    if (permiso == LocationPermission.deniedForever) {
      await _mostrarDialogoUbicacion(
        titulo: 'Permiso bloqueado',
        mensaje: 'Habilita la ubicación manualmente en Configuración.',
        boton: 'Abrir configuración',
        accion: Geolocator.openAppSettings,
      );
      return _obtenerUbicacion();
    }

    final posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (!mounted) return;
    setState(() =>
        _ubicacionUsuario = LatLng(posicion.latitude, posicion.longitude));
  }

  Future<void> _mostrarDialogoUbicacion({
    required String titulo,
    required String mensaje,
    required String boton,
    required Future<void> Function()? accion,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await accion?.call();
            },
            child: Text(boton),
          ),
        ],
      ),
    );
  }

  // ── Carga de datos ───────────────────────────────────────────────────

  Future<void> _cargarSupermercados() async {
    try {
      final response = await http.get(
        Uri.parse(_MapConstants.apiUrl),
        headers: {
          'Authorization': 'Bearer $userToken', // <-- token agregado
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final lista = (data['supermercados'] as List)
            .map((j) => Supermercado.fromJson(j as Map<String, dynamic>))
            // Descarta supermercados sin coordenadas válidas
            .where((s) =>
                s.ubicacion.latitude.isFinite &&
                s.ubicacion.longitude.isFinite &&
                (s.ubicacion.latitude != 0.0 || s.ubicacion.longitude != 0.0))
            .toList();

        if (mounted) setState(() => _supermercados = lista);
      } else {
        _mostrarError('Error al cargar supermercados (${response.statusCode})');
      }
    } catch (e) {
      _mostrarError('Sin conexión. Verifica tu red.');
      debugPrint('_cargarSupermercados: $e');
    }
  }

  Future<void> _cargarTodosLosReportes() async {
    try {
      final todos = await ReportService.listarReportes();

      final Map<int, List<dynamic>> cache = {};
      for (final r in todos) {
        // int.tryParse para manejar tanto int como String desde la API
        final id = int.tryParse(r['id_supermarket']?.toString() ?? '');
        if (id == null) continue;
        (cache[id] ??= []).add(r);
      }

      for (final lista in cache.values) {
        lista.sort((a, b) => (b['date']?.toString() ?? '')
            .compareTo(a['date']?.toString() ?? ''));
      }

      if (mounted) setState(() => _reportesPorSucursal = cache);
    } catch (e) {
      debugPrint('_cargarTodosLosReportes: $e');
      _mostrarError('No se pudieron cargar los reportes.');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  List<dynamic> _reportesDe(int idSucursal) =>
      _reportesPorSucursal[idSucursal] ?? [];

  int _cantidadReportes(int idSucursal) => _reportesDe(idSucursal).length;

  Color _colorRiesgo(int cantidad) {
    if (cantidad >= _MapConstants.riskThresholdHigh) return Colors.red;
    if (cantidad >= _MapConstants.riskThresholdLow) return Colors.orange;
    return Colors.green;
  }

  IconData _iconoSupermercado(String nombre) {
    final n = nombre.toLowerCase();
    if (n.contains('lider')) return Icons.shopping_cart;
    if (n.contains('jumbo')) return Icons.star;
    if (n.contains('santa isabel')) return Icons.shopping_basket;
    if (n.contains('unimarc')) return Icons.local_grocery_store;
    if (n.contains('tottus')) return Icons.store_mall_directory;
    return Icons.storefront;
  }

  String _tiempoRelativo(String fechaApi) {
    if (fechaApi.isEmpty) return 'Sin fecha';
    try {
      final fecha = DateTime.parse(fechaApi);
      final diff = DateTime.now().difference(fecha);
      if (diff.inDays > 1) return 'Hace ${diff.inDays} días';
      if (diff.inDays == 1) return 'Ayer';
      if (diff.inHours > 0) return 'Hace ${diff.inHours} h';
      if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes} min';
      return 'Hace un momento';
    } catch (_) {
      return fechaApi.length > 16 ? fechaApi.substring(0, 16) : fechaApi;
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _centrarEnUsuario() {
    _mapController.move(_ubicacionUsuario, _MapConstants.recenterZoom);
    _obtenerUbicacion();
  }

  // ── Bottom Sheet ─────────────────────────────────────────────────────

  void _mostrarReportes(Supermercado super_) {
    final reportes = _reportesDe(super_.id);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReportesBottomSheet(
        supermercado: super_,
        reportes: reportes,
        isDarkMode: _isDarkMode,
        tiempoRelativo: _tiempoRelativo,
        onRefresh: _recargarDatos,
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: _cargando ? null : _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
        title: const Text('Mapa de Alertas'),
        actions: [
          Semantics(
            label: 'Cambiar tema del mapa',
            child: IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              tooltip: _isDarkMode ? 'Modo claro' : 'Modo oscuro',
              onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            ),
          ),
        ],
      );

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _ubicacionUsuario,
        initialZoom: _MapConstants.defaultZoom,
        minZoom: _MapConstants.minZoom,
        maxZoom: _MapConstants.maxZoom,
      ),
      children: [
        _buildTileLayer(),
        _buildMarcadoresSupermercados(),
        _buildMarcadorUsuario(),
      ],
    );
  }

  TileLayer _buildTileLayer() => TileLayer(
        urlTemplate:
            _isDarkMode ? _MapConstants.tileDark : _MapConstants.tileLight,
        subdomains: _MapConstants.tileSubdomains,
        userAgentPackageName: _MapConstants.userAgent,
      );

  MarkerLayer _buildMarcadoresSupermercados() => MarkerLayer(
        markers: _supermercados.map(_buildMarcadorSupermercado).toList(),
      );

  Marker _buildMarcadorSupermercado(Supermercado s) {
    final cantidad = _cantidadReportes(s.id);
    final color = _colorRiesgo(cantidad);
    final icono = _iconoSupermercado(s.nombre);
    final tieneAlerta = cantidad > 0;

    return Marker(
      point: s.ubicacion,
      width: 70,
      height: 70,
      child: Semantics(
        label: '${s.nombre}, $cantidad reportes',
        button: true,
        child: GestureDetector(
          onTap: () => _mostrarReportes(s),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icono, color: color, size: 32),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.black87 : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      s.nombre,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (tieneAlerta)
                Positioned(
                  top: -5,
                  right: 5,
                  child: _BadgeContador(count: cantidad),
                ),
            ],
          ),
        ),
      ),
    );
  }

  MarkerLayer _buildMarcadorUsuario() => MarkerLayer(
        markers: [
          Marker(
            point: _ubicacionUsuario,
            width: 40,
            height: 40,
            child: Semantics(
              label: 'Tu ubicación actual',
              child:
                  const Icon(Icons.my_location, color: Colors.blue, size: 30),
            ),
          ),
        ],
      );

  FloatingActionButton _buildFAB() => FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        tooltip: 'Centrar en mi ubicación',
        onPressed: _centrarEnUsuario,
        child: const Icon(Icons.gps_fixed, color: Colors.white),
      );
}

// ─────────────────────────────────────────────
// WIDGET: Badge contador
// ─────────────────────────────────────────────
class _BadgeContador extends StatelessWidget {
  const _BadgeContador({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// WIDGET: Bottom Sheet
// ─────────────────────────────────────────────
class _ReportesBottomSheet extends StatelessWidget {
  const _ReportesBottomSheet({
    required this.supermercado,
    required this.reportes,
    required this.isDarkMode,
    required this.tiempoRelativo,
    required this.onRefresh,
  });

  final Supermercado supermercado;
  final List<dynamic> reportes;
  final bool isDarkMode;
  final String Function(String) tiempoRelativo;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final Color bg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subColor = isDarkMode ? Colors.grey.shade400 : Colors.black54;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.90,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: subColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      supermercado.nombre,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Actualizar'),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textColor),
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(color: subColor.withOpacity(0.3), height: 1),
            Expanded(
              child: reportes.isEmpty
                  ? _EmptyState(color: subColor)
                  : RefreshIndicator(
                      onRefresh: onRefresh,
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: reportes.length,
                        itemBuilder: (_, i) => _TarjetaReporte(
                          reporte: reportes[i],
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          subColor: subColor,
                          tiempoRelativo: tiempoRelativo,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET: Tarjeta de reporte con imagen
// ─────────────────────────────────────────────
class _TarjetaReporte extends StatelessWidget {
  const _TarjetaReporte({
    required this.reporte,
    required this.isDarkMode,
    required this.textColor,
    required this.subColor,
    required this.tiempoRelativo,
  });

  final dynamic reporte;
  final bool isDarkMode;
  final Color textColor;
  final Color subColor;
  final String Function(String) tiempoRelativo;

  @override
  Widget build(BuildContext context) {
    final reporteId = reporte['id'];
    final idThief = reporte['id_thief']?.toString() ?? '—';
    final descripcion = reporte['description']?.toString() ?? 'Sin descripción';
    final fechaStr = reporte['date']?.toString() ?? '';
    final fecha = tiempoRelativo(fechaStr);

    return Card(
      color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDarkMode ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del reporte
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              '$baseUrl/reportes/$reporteId/imagen',
              headers: {'Authorization': 'Bearer $userToken'},
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              // Si no hay imagen simplemente no muestra nada
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
          // Datos del reporte
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_rounded,
                  color: Colors.redAccent, size: 28),
            ),
            title: Text(
              'Persona ID: $idThief',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 13, color: subColor),
                      const SizedBox(width: 4),
                      Text(fecha,
                          style: TextStyle(color: subColor, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(descripcion, style: TextStyle(color: subColor)),
                ],
              ),
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET: Estado vacío
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 56, color: Colors.green.shade400),
            const SizedBox(height: 12),
            Text(
              'Sin reportes recientes',
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Esta sucursal está tranquila por ahora.',
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 13),
            ),
          ],
        ),
      );
}
