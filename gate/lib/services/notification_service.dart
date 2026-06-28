import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

enum AlertLevel { rojo, naranja, amarillo }

class AppNotification {
  final String id;
  final String titulo;
  final String cuerpo;
  final DateTime fecha;
  final AlertLevel nivel;
  final double? distanciaKm;
  bool leida;

  AppNotification({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.fecha,
    required this.nivel,
    this.distanciaKm,
    this.leida = false,
  });

  Color get color {
    switch (nivel) {
      case AlertLevel.rojo:
        return const Color(0xFFEF4444);
      case AlertLevel.naranja:
        return const Color(0xFFF97316);
      case AlertLevel.amarillo:
        return const Color(0xFFFBBF24);
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'cuerpo': cuerpo,
        'fecha': fecha.toIso8601String(),
        'nivel': nivel.index,
        'distanciaKm': distanciaKm,
        'leida': leida,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'],
        titulo: json['titulo'],
        cuerpo: json['cuerpo'],
        fecha: DateTime.parse(json['fecha']),
        nivel: AlertLevel.values[json['nivel']],
        distanciaKm: json['distanciaKm'],
        leida: json['leida'],
      );
}

class NotificationService {
  static const _key = 'gate_notifications';
  static final List<AppNotification> _notificaciones = [];
  static final List<VoidCallback> _listeners = [];

  static List<AppNotification> get notificaciones =>
      List.unmodifiable(_notificaciones);

  static int get noLeidas =>
      _notificaciones.where((n) => !n.leida).length;

  static AlertLevel? get nivelPendiente {
    final pendientes = _notificaciones.where((n) => !n.leida).toList();
    if (pendientes.isEmpty) return null;
    if (pendientes.any((n) => n.nivel == AlertLevel.rojo)) return AlertLevel.rojo;
    if (pendientes.any((n) => n.nivel == AlertLevel.naranja)) return AlertLevel.naranja;
    return AlertLevel.amarillo;
  }

  static void addListener(VoidCallback cb) => _listeners.add(cb);
  static void removeListener(VoidCallback cb) => _listeners.remove(cb);
  static void _notify() {
    for (final cb in _listeners) cb();
  }

  static Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final lista = jsonDecode(raw) as List;
      _notificaciones.clear();
      _notificaciones.addAll(
          lista.map((e) => AppNotification.fromJson(e)).toList());
    }
  }

  static Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_notificaciones.map((n) => n.toJson()).toList()));
  }

  static Future<void> agregarDesdeFCM({
    required String titulo,
    required String cuerpo,
    required Map<String, dynamic> data,
  }) async {
    final nivel = await _calcularNivel(data);
    final distancia = await _calcularDistancia(data);

    final notif = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      cuerpo: cuerpo,
      fecha: DateTime.now(),
      nivel: nivel,
      distanciaKm: distancia,
    );

    _notificaciones.insert(0, notif);

    // Máximo 50 notificaciones guardadas
    if (_notificaciones.length > 50) _notificaciones.removeLast();

    await _guardar();
    _notify();
  }

  static Future<double?> _calcularDistancia(Map<String, dynamic> data) async {
    try {
      // Obtener coordenadas de la sucursal del usuario
      final miSuper = await _fetchSupermarket(userSupermarketId);
      if (miSuper == null) return null;

      // Obtener sucursal de la alerta
      final alertSuperId = int.tryParse(
              data['supermarket_id']?.toString() ??
              data['center_supermarket_id']?.toString() ?? '');
      if (alertSuperId == null) return null;

      final alertSuper = await _fetchSupermarket(alertSuperId);
      if (alertSuper == null) return null;

      final lat1 = miSuper['location_x'] as double?;
      final lon1 = miSuper['location_y'] as double?;
      final lat2 = alertSuper['location_x'] as double?;
      final lon2 = alertSuper['location_y'] as double?;

      if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) return null;

      return _haversine(lat1, lon1, lat2, lon2);
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _fetchSupermarket(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/supermercados/$id'),
        headers: {'Authorization': 'Bearer $userToken'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['supermercado'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  // Fórmula de Haversine — distancia entre dos coordenadas en km
  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _deg2rad(double deg) => deg * pi / 180;

  static Future<AlertLevel> _calcularNivel(Map<String, dynamic> data) async {
    final distancia = await _calcularDistancia(data);
    if (distancia == null) return AlertLevel.naranja;
    if (distancia < 2) return AlertLevel.rojo;
    if (distancia < 5) return AlertLevel.naranja;
    return AlertLevel.amarillo;
  }

  static Future<void> marcarTodasLeidas() async {
    for (final n in _notificaciones) n.leida = true;
    await _guardar();
    _notify();
  }

  static Future<void> limpiar() async {
    _notificaciones.clear();
    await _guardar();
    _notify();
  }
}
