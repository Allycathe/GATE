import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

typedef LogoutCallback = void Function();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
LogoutCallback? _logoutHandler;

void registrarLogout(LogoutCallback callback) {
  _logoutHandler = callback;
}

class ApiClient {
  static const Duration _timeout = Duration(seconds: 15);

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      };

  static Future<http.Response> get(String path) async {
    final response = await http
        .get(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(_timeout);
    _manejarRespuesta(response);
    return response;
  }

  static Future<http.Response> post(String path, dynamic body) async {
    final response = await http
        .post(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body))
        .timeout(_timeout);
    _manejarRespuesta(response);
    return response;
  }

  static Future<http.Response> put(String path, dynamic body) async {
    final response = await http
        .put(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body))
        .timeout(_timeout);
    _manejarRespuesta(response);
    return response;
  }

  static Future<http.Response> delete(String path) async {
    final response = await http
        .delete(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(_timeout);
    _manejarRespuesta(response);
    return response;
  }

  static void _manejarRespuesta(http.Response response) {
    if (response.statusCode == 401) _cerrarSesion();
  }

  static void _cerrarSesion() {
    userToken = '';
    userId = 0;
    userEmail = '';
    userName = '';
    userLastName = '';
    userIsAdmin = false;
    userSupermarketId = 0;

    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Sesión expirada. Iniciá sesión nuevamente.')),
      );
    }
    _logoutHandler?.call();
  }
}
