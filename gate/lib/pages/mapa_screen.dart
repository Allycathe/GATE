// lib/screens/mapa_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import '../config.dart';
import '../services/report_service.dart';

// ─── THEME ──────────────────────────────────────────────────────────────────

class MapTheme {
  final bool isDark;

  const MapTheme({required this.isDark});

  Color get background => isDark ? const Color(0xFF0D1117) : const Color(0xFFF4F6FA);
  Color get surface => isDark ? const Color(0xFF161B22) : Colors.white;
  Color get surfaceVariant => isDark ? const Color(0xFF1F2937) : const Color(0xFFF0F4FF);
  Color get primary => const Color(0xFF6366F1);
  Color get danger => const Color(0xFFEF4444);
  Color get warning => const Color(0xFFF59E0B);
  Color get success => const Color(0xFF10B981);
  Color get textPrimary => isDark ? const Color(0xFFF0F6FC) : const Color(0xFF0D1117);
  Color get textSecondary => isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);
  Color get border => isDark ? const Color(0xFF30363D) : const Color(0xFFE5E7EB);
  Color get cardShadow => isDark ? Colors.black54 : Colors.black12;
  String get tileUrl => isDark
      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
      : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
}

// ─── PULSING MARKER WIDGET ──────────────────────────────────────────────────

class PulsingMarker extends StatefulWidget {
  final Color color;
  final int reportCount;
  final String name;
  final VoidCallback onTap;
  final bool isDark;

  const PulsingMarker({
    super.key,
    required this.color,
    required this.reportCount,
    required this.name,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<PulsingMarker>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnim;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: false);

    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _bounceAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    _bounceController.forward().then((_) => _bounceController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final hasReports = widget.reportCount > 0;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnim, _bounceAnim]),
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnim.value,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (hasReports)
                  Opacity(
                    opacity: (1.0 - _pulseAnim.value).clamp(0.0, 0.6),
                    child: Transform.scale(
                      scale: 1.0 + _pulseAnim.value * 1.8,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.color.withOpacity(0.8),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDark ? const Color(0xFF1F2937) : Colors.white,
                        border: Border.all(color: widget.color, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(Icons.store_rounded, color: widget.color, size: 20),
                    ),
                    CustomPaint(
                      size: const Size(12, 8),
                      painter: _PinTailPainter(color: widget.color),
                    ),
                  ],
                ),
                if (hasReports)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: widget.color.withOpacity(0.5), blurRadius: 6),
                        ],
                      ),
                      child: Text(
                        '${widget.reportCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: -18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF1F2937).withOpacity(0.95)
                          : Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark
                            ? const Color(0xFFF0F6FC)
                            : const Color(0xFF0D1117),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  final Color color;
  _PinTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── USER LOCATION MARKER ───────────────────────────────────────────────────

class UserLocationMarker extends StatefulWidget {
  const UserLocationMarker({super.key});

  @override
  State<UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: (1 - _anim.value) * 0.4,
              child: Transform.scale(
                scale: 1 + _anim.value * 3,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── STATS CHIP ─────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MAIN SCREEN ─────────────────────────────────────────────────────────────

class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa>
    with TickerProviderStateMixin {
  LatLng _ubicacionUsuario = const LatLng(-33.4489, -70.6693);
  List<Map<String, dynamic>> _supermercados = [];
  List<dynamic> _historialCompletoReportes = [];
  bool _cargando = true;
  bool _isDarkMode = true;
  String _filtroActivo = 'todos';
  String _searchQuery = '';
  double _zoomLevel = 15.0; // ← rastreamos el zoom actual
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  late AnimationController _fabController;
  late AnimationController _loadingController;
  late AnimationController _headerController;
  late Animation<double> _fabAnim;
  late Animation<Offset> _headerSlide;

  MapTheme get _theme => MapTheme(isDark: _isDarkMode);

  // Límites de zoom
  static const double _minZoom = 3.0;
  static const double _maxZoom = 19.0;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnim = CurvedAnimation(parent: _fabController, curve: Curves.easeOut);

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));

    _inicializar();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _loadingController.dispose();
    _headerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _inicializar() async {
    await Future.delayed(Duration.zero);
    await _obtenerUbicacion();
    await Future.wait([
      _cargarSupermercados(),
      _cargarTodosLosReportes(),
    ]);
    if (mounted) {
      setState(() => _cargando = false);
      _fabController.forward();
      _headerController.forward();
    }
  }

  Future<void> _cargarTodosLosReportes() async {
    try {
      _historialCompletoReportes = await ReportService.listarReportes();
    } catch (e) {
      debugPrint('Error al cargar reportes: $e');
      _historialCompletoReportes = [];
    }
  }

  Future<void> _obtenerUbicacion() async {
    bool servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      await _mostrarDialogoUbicacion(
        titulo: 'GPS desactivado',
        mensaje: 'Activa el GPS para continuar.',
        boton: 'Abrir configuración',
        accion: () => Geolocator.openLocationSettings(),
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
        mensaje: 'Necesitamos tu ubicación para mostrarte sucursales cercanas.',
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
        accion: () => Geolocator.openAppSettings(),
      );
      return _obtenerUbicacion();
    }

    final posicion = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _ubicacionUsuario = LatLng(posicion.latitude, posicion.longitude);
      });
    }
  }

  Future<void> _mostrarDialogoUbicacion({
    required String titulo,
    required String mensaje,
    required String boton,
    required Future<void> Function()? accion,
  }) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: _theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(titulo,
            style: TextStyle(color: _theme.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(mensaje, style: TextStyle(color: _theme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (accion != null) await accion();
            },
            child: Text(boton, style: TextStyle(color: _theme.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _cargarSupermercados() async {
    try {
      final response = await http.get(
        Uri.parse('https://gate.blade.dedyn.io/supermercados'),
        headers: {'Authorization': 'Bearer $userToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List supermercadosJson = data['supermercados'];

        setState(() {
          _supermercados = supermercadosJson.map((s) {
            double lat = double.tryParse(s['location_y'].toString()) ?? 0.0;
            double lng = double.tryParse(s['location_x'].toString()) ?? 0.0;
            return {
              'id': s['id'],
              'nombre': s['name'],
              'lat': lat,
              'lng': lng,
            };
          }).where((s) {
            final lat = s['lat'] as double;
            final lng = s['lng'] as double;
            return lat.isFinite && lng.isFinite && (lat != 0.0 || lng != 0.0);
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
    }
  }

  List<dynamic> _filtrarReportes(int idSucursal) {
    return _historialCompletoReportes.where((r) {
      final id = r["id_supermarket"];
      if (id == null) return false;
      return int.tryParse(id.toString()) == idSucursal;
    }).toList();
  }

  List<Map<String, dynamic>> get _supermercadosFiltrados {
    return _supermercados.where((s) {
      final nombre = s['nombre'].toString().toLowerCase();
      final matchSearch =
          _searchQuery.isEmpty || nombre.contains(_searchQuery.toLowerCase());
      final count = _filtrarReportes(s['id']).length;
      final matchFilter = _filtroActivo == 'todos' ||
          (_filtroActivo == 'con_reportes' && count > 0) ||
          (_filtroActivo == 'sin_reportes' && count == 0);
      return matchSearch && matchFilter;
    }).toList();
  }

  Color _markerColor(int count) {
    if (count == 0) return _theme.success;
    if (count < 3) return _theme.warning;
    return _theme.danger;
  }

  void _centrarEnUsuario() {
    HapticFeedback.lightImpact();
    _mapController.move(_ubicacionUsuario, 15.0);
    setState(() => _zoomLevel = 15.0);
  }

  // ── ZOOM CONTROLS ──────────────────────────────────────────────────────────
  void _zoomIn() {
    HapticFeedback.selectionClick();
    final newZoom = (_zoomLevel + 1.0).clamp(_minZoom, _maxZoom);
    _mapController.move(_mapController.camera.center, newZoom);
    setState(() => _zoomLevel = newZoom);
  }

  void _zoomOut() {
    HapticFeedback.selectionClick();
    final newZoom = (_zoomLevel - 1.0).clamp(_minZoom, _maxZoom);
    _mapController.move(_mapController.camera.center, newZoom);
    setState(() => _zoomLevel = newZoom);
  }

  // ── NAVIGATE BACK ──────────────────────────────────────────────────────────
  void _volverAtras() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  Future<void> _refrescar() async {
    HapticFeedback.mediumImpact();
    setState(() => _cargando = true);
    await Future.wait([
      _cargarSupermercados(),
      _cargarTodosLosReportes(),
    ]);
    setState(() => _cargando = false);
  }

  void _mostrarEstadisticas() {
    final total = _supermercados.length;
    final conReportes =
        _supermercados.where((s) => _filtrarReportes(s['id']).isNotEmpty).length;
    final totalReportes = _historialCompletoReportes.length;

    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _EstadisticasSheet(
        total: total,
        conReportes: conReportes,
        totalReportes: totalReportes,
        theme: _theme,
      ),
    );
  }

  void _mostrarReportes(int idSucursal, String nombre) {
    final reportes = _filtrarReportes(idSucursal);
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportesSheet(
        nombre: nombre,
        reportes: reportes,
        theme: _theme,
      ),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: _theme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // MAP
              _cargando ? _buildLoadingView() : _buildMap(),

              // HEADER
              SlideTransition(
                position: _headerSlide,
                child: _buildHeader(),
              ),

              // SEARCH BAR
              if (_showSearch)
                Positioned(
                  top: 70,
                  left: 16,
                  right: 16,
                  child: _buildSearchBar(),
                ),

              // FILTER CHIPS
              Positioned(
                top: _showSearch ? 130 : 70,
                left: 0,
                right: 0,
                child: _buildFilterChips(),
              ),

              // FABs (bottom right)
              Positioned(
                bottom: 24,
                right: 16,
                child: FadeTransition(
                  opacity: _fabAnim,
                  child: _buildFABs(),
                ),
              ),

              // BOTTOM STATS BAR
              if (!_cargando)
                Positioned(
                  bottom: 24,
                  left: 16,
                  child: FadeTransition(
                    opacity: _fabAnim,
                    child: _buildStatsBar(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _loadingController,
            builder: (_, __) => Transform.rotate(
              angle: _loadingController.value * 2 * math.pi,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [_theme.primary, _theme.primary.withOpacity(0.1)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(backgroundColor: _theme.background),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando mapa...',
            style: TextStyle(
              color: _theme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final filtrados = _supermercadosFiltrados;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _ubicacionUsuario,
        initialZoom: _zoomLevel,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
        // Sincronizamos _zoomLevel cuando el usuario hace pinch/drag
        onMapEvent: (event) {
          if (event is MapEventMove || event is MapEventScrollWheelZoom) {
            final newZoom = _mapController.camera.zoom;
            if ((newZoom - _zoomLevel).abs() > 0.05) {
              setState(() => _zoomLevel = newZoom);
            }
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: _theme.tileUrl,
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.gate.app',
        ),
        MarkerLayer(
          markers: filtrados.map((s) {
            final count = _filtrarReportes(s['id']).length;
            final color = _markerColor(count);
            return Marker(
              point: LatLng(s['lat'], s['lng']),
              width: 80,
              height: 90,
              child: PulsingMarker(
                color: color,
                reportCount: count,
                name: s['nombre'],
                isDark: _isDarkMode,
                onTap: () => _mostrarReportes(s['id'], s['nombre']),
              ),
            );
          }).toList(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _ubicacionUsuario,
              width: 40,
              height: 40,
              child: const UserLocationMarker(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _theme.surface.withOpacity(0.97),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _theme.border),
          boxShadow: [
            BoxShadow(
              color: _theme.cardShadow,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── BOTÓN RETROCEDER ──────────────────────────────────────────
            GestureDetector(
              onTap: _volverAtras,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _theme.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _theme.border),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _theme.textPrimary,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // ── ÍCONO + TÍTULO ────────────────────────────────────────────
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _theme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.shield_rounded, color: _theme.primary, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mapa de Alertas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _theme.textPrimary,
                    ),
                  ),
                  Text(
                    '${_supermercadosFiltrados.length} sucursales visibles',
                    style: TextStyle(fontSize: 10, color: _theme.textSecondary),
                  ),
                ],
              ),
            ),

            // ── SEARCH ───────────────────────────────────────────────────
            _HeaderBtn(
              icon: _showSearch
                  ? Icons.search_off_rounded
                  : Icons.search_rounded,
              theme: _theme,
              onTap: () => setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              }),
            ),
            const SizedBox(width: 6),

            // ── STATS ────────────────────────────────────────────────────
            _HeaderBtn(
              icon: Icons.bar_chart_rounded,
              theme: _theme,
              onTap: _mostrarEstadisticas,
            ),
            const SizedBox(width: 6),

            // ── DARK MODE ────────────────────────────────────────────────
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _isDarkMode = !_isDarkMode);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _isDarkMode
                      ? const Color(0xFFF59E0B).withOpacity(0.15)
                      : const Color(0xFF6366F1).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: _isDarkMode
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF6366F1),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedOpacity(
      opacity: _showSearch ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _theme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _theme.primary.withOpacity(0.4)),
          boxShadow: [BoxShadow(color: _theme.cardShadow, blurRadius: 12)],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: _theme.textSecondary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: _theme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar sucursal...',
                  hintStyle: TextStyle(color: _theme.textSecondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                }),
                child: Icon(Icons.close, color: _theme.textSecondary, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      ('todos', 'Todos', Icons.apps_rounded),
      ('con_reportes', 'Con alertas', Icons.warning_amber_rounded),
      ('sin_reportes', 'Sin alertas', Icons.check_circle_outline_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((f) {
          final isActive = _filtroActivo == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _filtroActivo = f.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive
                      ? _theme.primary
                      : _theme.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? _theme.primary : _theme.border,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: _theme.primary.withOpacity(0.3),
                            blurRadius: 8,
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      f.$3,
                      size: 13,
                      color: isActive ? Colors.white : _theme.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      f.$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : _theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFABs() {
    final canZoomIn = _zoomLevel < _maxZoom;
    final canZoomOut = _zoomLevel > _minZoom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── ZOOM LEVEL BADGE ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _theme.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _theme.border),
            boxShadow: [
              BoxShadow(color: _theme.cardShadow, blurRadius: 6),
            ],
          ),
          child: Text(
            'z ${_zoomLevel.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _theme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ── ZOOM IN ───────────────────────────────────────────────────────
        _MapFAB(
          icon: Icons.add_rounded,
          theme: _theme,
          onTap: canZoomIn ? _zoomIn : () {},
          small: true,
          disabled: !canZoomIn,
        ),

        // ── DIVISOR VISUAL ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Container(
            width: 22,
            height: 1,
            color: _theme.border,
          ),
        ),

        // ── ZOOM OUT ──────────────────────────────────────────────────────
        _MapFAB(
          icon: Icons.remove_rounded,
          theme: _theme,
          onTap: canZoomOut ? _zoomOut : () {},
          small: true,
          disabled: !canZoomOut,
        ),

        const SizedBox(height: 12),

        // ── REFRESH ───────────────────────────────────────────────────────
        _MapFAB(
          icon: Icons.refresh_rounded,
          theme: _theme,
          onTap: _refrescar,
          small: true,
        ),
        const SizedBox(height: 10),

        // ── MY LOCATION ───────────────────────────────────────────────────
        _MapFAB(
          icon: Icons.my_location_rounded,
          theme: _theme,
          onTap: _centrarEnUsuario,
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    final conAlertas = _supermercados
        .where((s) => _filtrarReportes(s['id']).isNotEmpty)
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _theme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _theme.border),
        boxShadow: [BoxShadow(color: _theme.cardShadow, blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatChip(
            icon: Icons.store_rounded,
            label: '${_supermercados.length}',
            color: _theme.primary,
            isDark: _isDarkMode,
          ),
          const SizedBox(width: 6),
          _StatChip(
            icon: Icons.warning_rounded,
            label: '$conAlertas',
            color: _theme.danger,
            isDark: _isDarkMode,
          ),
          const SizedBox(width: 6),
          _StatChip(
            icon: Icons.report_rounded,
            label: '${_historialCompletoReportes.length}',
            color: _theme.warning,
            isDark: _isDarkMode,
          ),
        ],
      ),
    );
  }
}

// ─── HEADER BUTTON ──────────────────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final MapTheme theme;
  final VoidCallback onTap;

  const _HeaderBtn({
    required this.icon,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.textSecondary, size: 18),
      ),
    );
  }
}

// ─── MAP FAB ────────────────────────────────────────────────────────────────

class _MapFAB extends StatefulWidget {
  final IconData icon;
  final MapTheme theme;
  final VoidCallback onTap;
  final bool small;
  final bool disabled;

  const _MapFAB({
    required this.icon,
    required this.theme,
    required this.onTap,
    this.small = false,
    this.disabled = false,
  });

  @override
  State<_MapFAB> createState() => _MapFABState();
}

class _MapFABState extends State<_MapFAB> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.small ? 40.0 : 50.0;
    final iconColor = widget.disabled
        ? widget.theme.textSecondary.withOpacity(0.35)
        : widget.theme.primary;

    return GestureDetector(
      onTapDown: widget.disabled ? null : (_) => _ctrl.forward(),
      onTapUp: widget.disabled
          ? null
          : (_) {
              _ctrl.reverse();
              widget.onTap();
            },
      onTapCancel: widget.disabled ? null : () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, __) => Transform.scale(
          scale: widget.disabled ? 1.0 : _scale.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: widget.theme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: widget.theme.border),
              boxShadow: widget.disabled
                  ? []
                  : [
                      BoxShadow(
                        color: widget.theme.cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Icon(
              widget.icon,
              color: iconColor,
              size: widget.small ? 18 : 22,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── ESTADÍSTICAS SHEET ──────────────────────────────────────────────────────

class _EstadisticasSheet extends StatelessWidget {
  final int total;
  final int conReportes;
  final int totalReportes;
  final MapTheme theme;

  const _EstadisticasSheet({
    required this.total,
    required this.conReportes,
    required this.totalReportes,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final sinReportes = total - conReportes;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: theme.primary),
              const SizedBox(width: 10),
              Text(
                'Resumen del Mapa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Sucursales',
                  value: '$total',
                  icon: Icons.store_rounded,
                  color: theme.primary,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Con alertas',
                  value: '$conReportes',
                  icon: Icons.warning_rounded,
                  color: theme.danger,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Sin alertas',
                  value: '$sinReportes',
                  icon: Icons.check_circle_rounded,
                  color: theme.success,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Reportes totales',
                  value: '$totalReportes',
                  icon: Icons.report_rounded,
                  color: theme.warning,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final MapTheme theme;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: theme.textSecondary)),
        ],
      ),
    );
  }
}

// ─── REPORTES SHEET ──────────────────────────────────────────────────────────

class _ReportesSheet extends StatelessWidget {
  final String nombre;
  final List<dynamic> reportes;
  final MapTheme theme;

  const _ReportesSheet({
    required this.nombre,
    required this.reportes,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.store_rounded, color: theme.danger, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${reportes.length} reporte${reportes.length != 1 ? 's' : ''}',
                        style:
                            TextStyle(fontSize: 12, color: theme.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(color: theme.border, height: 24),
          Expanded(
            child: reportes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 48,
                            color: theme.success.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'Sin reportes recientes',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Esta sucursal está tranquila',
                          style: TextStyle(
                            color: theme.textSecondary.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: reportes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final r = reportes[i];
                      final nombreSospechoso = r["nombre_sospechoso"] ?? '—';
                      final descripcion = r["description"] ?? "Sin descripción";
                      final fechaApi = r["date"]?.toString() ?? "";
                      final fecha = fechaApi.length > 16
                          ? fechaApi.substring(0, 16)
                          : "Sin fecha";

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + i * 60),
                        tween: Tween(begin: 0, end: 1),
                        curve: Curves.easeOut,
                        builder: (_, v, child) => Opacity(
                          opacity: v,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - v)),
                            child: child,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: theme.border),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(14)),
                                child: SizedBox(
                                  width: 72,
                                  height: 80,
                                  child: Image.network(
                                    '$baseUrl/reportes/${r["id"]}/imagen',
                                    fit: BoxFit.cover,
                                    headers: {
                                      'Authorization': 'Bearer $userToken'
                                    },
                                    errorBuilder: (_, __, ___) => Container(
                                      color: theme.danger.withOpacity(0.1),
                                      child: Icon(Icons.broken_image_rounded,
                                          color: theme.danger.withOpacity(0.5),
                                          size: 28),
                                    ),
                                    loadingBuilder: (_, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        color: theme.surfaceVariant,
                                        child: Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: theme.primary,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: theme.danger.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Nombre del Sospechoso: $nombreSospechoso',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: theme.danger,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        descripcion,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time_rounded,
                                              size: 11,
                                              color: theme.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            fecha,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: theme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
    );
  }
}
