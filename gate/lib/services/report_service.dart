import 'dart:convert';
import 'dart:io';
import '../config.dart';
import 'api_client.dart';

class ReportService {
  static Future<List<dynamic>> listarReportes() async {
    final response = await ApiClient.get('/reportes');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al listar reportes: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> crearReporte({
    required String nombreSospechoso,
    required String description,
    required int idSupermarket,
    required int idReporter,
    File? imagen,
  }) async {
    String? imagenBase64;
    if (imagen != null) {
      final bytes = await imagen.readAsBytes();
      imagenBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    }

    final response = await ApiClient.post(
      '/reportes',
      jsonEncode({
        'nombre_sospechoso': nombreSospechoso,
        'description': description,
        'id_supermarket': idSupermarket,
        if (imagenBase64 != null) 'image': imagenBase64,
        'id_user': userId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear reporte: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> actualizarReporte({
    required int id,
    required String nombreSospechoso,
    required String description,
    required int idSupermarket,
    File? imagen,
    String? imagenUrlActual,
  }) async {
    String? imagenFinal;
    if (imagen != null) {
      final bytes = await imagen.readAsBytes();
      imagenFinal = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    } else if (imagenUrlActual != null) {
      imagenFinal = imagenUrlActual;
    }

    final response = await ApiClient.put(
      '/reportes/$id',
      jsonEncode({
        'nombre_sospechoso': nombreSospechoso,
        'description': description,
        'id_supermarket': idSupermarket,
        if (imagenFinal != null) 'image': imagenFinal,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar reporte: ${response.statusCode}');
    }
  }

  static Future<Map<int, String>> listarSupermercados() async {
    final response = await ApiClient.get('/supermercados');
    if (response.statusCode == 200) {
      final lista = jsonDecode(response.body) as List;
      return {for (var s in lista) s['id'] as int: s['name'] as String};
    }
    return {};
  }

  static Future<void> eliminarReporte(int id) async {
    final response = await ApiClient.delete('/reportes/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar reporte: ${response.statusCode}');
    }
  }
}
