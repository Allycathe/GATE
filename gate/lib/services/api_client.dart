import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../routes.dart';
import '../pages/login.dart';

// Clave global para poder navegar desde fuera de un widget
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ApiClient {
  static const Duration _timeout = Duration(seconds: 15);

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      };

  static Map<String, String> get _headersNoContent => {
        'Authorization': 'Bearer $userToken',
      };

  static void _manejarRespuesta(http.Response response) {
    if (response.statusCode == 401) {
      _cerrarSesion();
    }
  }

  static void _cerrarSesion() {
    // Limpia el estado del usuario
    userToken = "";
    userId = 0;
    userEmail = "";
    userName = "";
    userLastName = "";
    userIsAdmin = false;
    userSupermarketId = 0;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Muestra aviso y redirige al login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tu sesión expiró. Por favor inicia sesión de nuevo."),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );

    navigatorKey.currentState?.pushAndRemoveUntil(
      fadeRoute(const LoginPage()),
      (route) => false,
    );
  }

  static Future<http.Response> get(String path) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$path'),
            headers: _headersNoContent,
          )
          .timeout(_timeout);
      _manejarRespuesta(response);
      return response;
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on http.ClientException {
      throw Exception('Error de conexión');
    }
  }

  static Future<http.Response> post(String path, dynamic body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: _headers,
            body: body,
          )
          .timeout(_timeout);
      _manejarRespuesta(response);
      return response;
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on http.ClientException {
      throw Exception('Error de conexión');
    }
  }

  static Future<http.Response> put(String path, dynamic body) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$path'),
            headers: _headers,
            body: body,
          )
          .timeout(_timeout);
      _manejarRespuesta(response);
      return response;
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on http.ClientException {
      throw Exception('Error de conexión');
    }
  }

  static Future<http.Response> delete(String path) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$path'),
            headers: _headersNoContent,
          )
          .timeout(_timeout);
      _manejarRespuesta(response);
      return response;
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on http.ClientException {
      throw Exception('Error de conexión');
    }
  }
}
