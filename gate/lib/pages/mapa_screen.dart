// lib/screens/mapa_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:async';
import '../config.dart';

import '../services/report_service.dart';

class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  LatLng _ubicacionUsuario = const LatLng(-33.4489, -70.6693);
  List<Map<String, dynamic>> _supermercados = [];

  List<dynamic> _historialCompletoReportes = [];

  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await Future.delayed(Duration.zero);
    await _obtenerUbicacion();
    await _cargarSupermercados();
    await _cargarTodosLosReportes();
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _cargarTodosLosReportes() async {
    try {
      _historialCompletoReportes = await ReportService.listarReportes();
    } catch (e) {
      debugPrint('Error al cargar el historial de reportes: $e');
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
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (accion != null) await accion();
            },
            child: Text(boton),
          ),
        ],
      ),
    );
  }

  Future<void> _cargarSupermercados() async {
    try {
      final response = await http.get(
        Uri.parse('https://gate.blade.dedyn.io/supermercados'),
        headers: {
          'Authorization': 'Bearer $userToken',
        },
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
      } else {
        debugPrint('Error al cargar supermercados: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error de conexión al cargar supermercados: $e');
    }
  }

  List<dynamic> _filtrarReportes(int idSucursal) {
    return _historialCompletoReportes.where((reporte) {
      final idReporte = reporte["id_supermarket"];
      if (idReporte == null) return false;
      return int.tryParse(idReporte.toString()) == idSucursal;
    }).toList();
  }

  void _mostrarReportes(int idSucursal, String nombreSupermercado) {
    final reportesFiltrados = _filtrarReportes(idSucursal);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Reportes: $nombreSupermercado",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Expanded(
                child: reportesFiltrados.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay reportes recientes en esta sucursal.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: reportesFiltrados.length,
                        itemBuilder: (context, index) {
                          final reporte = reportesFiltrados[index];
                          final idThief = reporte["id_thief"];
                          final descripcion =
                              reporte["description"] ?? "Sin descripción";

                          final fechaApi = reporte["date"]?.toString() ?? "";
                          final fecha = fechaApi.length > 16
                              ? fechaApi.substring(0, 16)
                              : "Sin fecha";

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.black12, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: SizedBox(
                                width: 60,
                                height: 60,
                                child: Image.network(
                                  '$baseUrl/reportes/${reporte["id"]}/imagen',
                                  fit: BoxFit.cover,
                                  headers: {
                                    'Authorization': 'Bearer $userToken',
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.report,
                                      color: Colors.red,
                                      size: 40,
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                ),
                              ),
                              title: Text(
                                "ID Persona: $idThief",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  "Fecha: $fecha\nDescripción: $descripcion"),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa de Alertas")),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : FlutterMap(
                options: MapOptions(
                  initialCenter: _ubicacionUsuario,
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.gate.app',
                  ),
                  MarkerLayer(
                    markers: _supermercados.map((superMercado) {
                      int cantidadReportes =
                          _filtrarReportes(superMercado['id']).length;

                      return Marker(
                        point: LatLng(superMercado['lat'], superMercado['lng']),
                        width: 60,
                        height: 60,
                        child: GestureDetector(
                          onTap: () => _mostrarReportes(
                              superMercado['id'], superMercado['nombre']),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.store,
                                      color: Colors.red, size: 30),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    color: Colors.white,
                                    child: Text(
                                      superMercado['nombre'],
                                      style: const TextStyle(fontSize: 9),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (cantidadReportes > 0)
                                Positioned(
                                  top: -5,
                                  right: 5,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$cantidadReportes',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _ubicacionUsuario,
                        child: const Icon(Icons.my_location,
                            color: Colors.blue, size: 30),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
