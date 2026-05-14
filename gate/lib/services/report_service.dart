import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ReportService {
    static Future<List<dynamic>> listarReportes() async {
        final url = Uri.parse('${AppConfig.baseUrl}/reportes');

        final response = await http.get(
            url,
            headers: {
                'Authorization': 'Bearer ${AppConfig.token}',
            },
        );

        if(response.statusCode == 200){
            return jsonDecode(response.body);
        }
        else{
            throw Exception('Error al listar reportes: ${response.statusCode} - ${response.body}');
        }
    }

    static Future<Map<String, dynamic>> crearReporte({
        required int idThief,
        required String description,
        required int idSupermarket,
    }) async {
        final url = Uri.parse('${AppConfig.baseUrl}/reportes');

        final response = await http.post(
            url,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${AppConfig.token}',
            },
            body: jsonEncode({
                'id_thief': idThief,
                'description': description,
                'id_supermarket': idSupermarket,
            }),
        );

        if(response.statusCode == 200 || response.statusCode == 201){
            return jsonDecode(response.body);
        }
        else{
            throw Exception('Error al crear reporte: ${response.statusCode} - ${response.body}');
        }
    }

    static Future<Map<String, dynamic>> actualizarReporte({
        required int id,
        required int idThief,
        required String description,
        required int idSupermarket,
    }) async {
        final url = Uri.parse('${AppConfig.baseUrl}/reportes/$id');

        final response = await http.put(
            url,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${AppConfig.token}',
            },
            body: jsonEncode({
                'id_thief': idThief,
                'description': description,
                'id_supermarket': idSupermarket,
            }),
        );

        if(response.statusCode == 200){
            return jsonDecode(response.body);
        }
        else{
            throw Exception('Error al actualizar reporte: ${response.statusCode} - ${response.body}');
        }
    }

    static Future<void> eliminarReporte(int id) async {
        final url = Uri.parse('${AppConfig.baseUrl}/reportes/$id');

        final response = await http.delete(
            url,
            headers: {
                'Authorization': 'Bearer ${AppConfig.token}',
            },
        );

        if(response.statusCode != 200 && response.statusCode != 204){
            throw Exception('Error al eliminar reporte: ${response.statusCode} - ${response.body}');
        }
    }
}