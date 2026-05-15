// lib/screens/mapa_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:async';

class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  LatLng _ubicacionUsuario = const LatLng(-33.4489, -70.6693);
  List<Map<String, dynamic>> _supermercados = [];
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
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _obtenerUbicacion() async {
    // 1. Verificar GPS
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

    // 2. Verificar / solicitar permiso
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

    // 3. Obtener posición
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
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List supermercadosJson = data['supermercados'];

        setState(() {
          _supermercados = supermercadosJson
              .map((s) => {
                    'nombre': s['name'],
                    'lat': s['location_y'], //  location_y es la latitud
                    'lng': s['location_x'], // location_x es la longitud
                  })
              .toList();
        });
      } else {
        debugPrint('Error al cargar supermercados: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
    }
  }

  void _mostrarReportes(String nombreSupermercado) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nombreSupermercado,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              const Text("Reporte 1: Sospechoso en pasillo 3 - hace 10 min"),
              const SizedBox(height: 8),
              const Text("Reporte 2: Persona con bolso grande - hace 25 min"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ],
          ),
        ),
      ),
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
                      return Marker(
                        point: LatLng(superMercado['lat'], superMercado['lng']),
                        width: 60,
                        height: 60,
                        child: GestureDetector(
                          onTap: () => _mostrarReportes(superMercado['nombre']),
                          child: Column(
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
