import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';

class ReportService {
  static Future<List<dynamic>> listarReportes() async {
    final url = Uri.parse('$baseUrl/reportes');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $userToken',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Error al listar reportes: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> crearReporte({
    required int idThief,
    required String description,
    required int idSupermarket,
    required int idReporter,
    File? imagen,
  }) async {
    final url = Uri.parse('$baseUrl/reportes');

    // Convertir imagen a base64 si existe
    String? imagenBase64;
    if (imagen != null) {
      final bytes = await imagen.readAsBytes();
      imagenBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
      body: jsonEncode({
        'id_thief': idThief,
        'description': description,
        'id_supermarket': idSupermarket,
        if (imagenBase64 != null) 'image': imagenBase64,
        'id_user': userId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Error al crear reporte: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> actualizarReporte({
    required int id,
    required int idThief,
    required String description,
    required int idSupermarket,
    File? imagen,
    String? imagenUrlActual, // Se reenvía si no se cambia la imagen
  }) async {
    final url = Uri.parse('$baseUrl/reportes/$id');

    String? imagenFinal;
    if (imagen != null) {
      // Nueva imagen seleccionada → convertir a base64
      final bytes = await imagen.readAsBytes();
      imagenFinal = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    } else if (imagenUrlActual != null) {
      // Sin cambios → reenviar la URL/base64 que ya tenía
      imagenFinal = imagenUrlActual;
    }

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken',
      },
      body: jsonEncode({
        'id_thief': idThief,
        'description': description,
        'id_supermarket': idSupermarket,
        if (imagenFinal != null) 'image': imagenFinal,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Error al actualizar reporte: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<void> eliminarReporte(int id) async {
    final url = Uri.parse('$baseUrl/reportes/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $userToken',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Error al eliminar reporte: ${response.statusCode} - ${response.body}');
    }
  }
}
