import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gate/config.dart';
import 'package:gate/pages/encargado.dart';
import 'package:gate/pages/mis_reportes.dart';
import 'package:gate/services/report_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../custom_widgets/navbar.dart';

const emptyTextForm = "Campo vacio";

class EditReportPage extends StatefulWidget {
  final int editReportId;

  const EditReportPage({
    super.key,
    required this.editReportId,
  });

  @override
  State<EditReportPage> createState() => _EditReportPage();
}

class _EditReportPage extends State<EditReportPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imagenNueva;          // imagen nueva seleccionada por el usuario
  String? _imagenActualUrl;    // imagen que ya tenía el reporte (base64 o url)

  final formkey = GlobalKey<FormState>();

  final nombreSospechosoController = TextEditingController();
  final descriptionController = TextEditingController();

  // Campos que se cargan del reporte existente
  int _idSupermarket = 0;

  bool _cargando = true;

  Future<void> loadReportInfo() async {
    final response = await http.get(
      Uri.parse("$baseUrl/reportes/${widget.editReportId}"),
      headers: {
        "Authorization": "Bearer $userToken",
      },
    );

    final data = jsonDecode(response.body);

    setState(() {
      descriptionController.text = data["description"] ?? "";
      nombreSospechosoController.text = data["nombre_sospechoso"] ?? "";
      _idSupermarket = data["id_supermarket"] ?? 0;
      _imagenActualUrl = data["image"]; // null si no tiene imagen
      _cargando = false;
    });
  }
  @override
  void initState() {
    super.initState();
    loadReportInfo();
  }
  @override
  void dispose() {
    nombreSospechosoController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> submitReport() async {
    try {
      await ReportService.actualizarReporte(
        id: widget.editReportId,
        nombreSospechoso: nombreSospechosoController.text,
        description: descriptionController.text,
        idSupermarket: _idSupermarket,
        imagen: _imagenNueva,            // null si no cambió
        imagenUrlActual: _imagenActualUrl, // reenvía la anterior si no cambió
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MisReportes()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al modificar reporte: $e")),
      );
    }
  }

  Future<void> deleteReport() async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/reportes/${widget.editReportId}"),
        headers: {
          "Authorization": "Bearer $userToken",
        },
      );

      if (response.statusCode == 200) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MisReportes(),
          ),
        );
      }

      else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error eliminando reporte"),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error conexión: $e"),
        ),
      );
    }
  }

  Future<void> seleccionarImagen(ImageSource fuente) async {
    final XFile? imagen = await _picker.pickImage(
      source: fuente,
      imageQuality: 80,
    );

    if (imagen != null) {
      setState(() {
        _imagenNueva = File(imagen.path);
      });
    }
  }

  void submit() {
    if (formkey.currentState!.validate()) {
      submitReport();
    }
  }

  Widget _buildImagePreview() {
    if (_imagenNueva != null) {
      // El usuario eligió una imagen nueva
      return _imageStack(Image.file(_imagenNueva!, fit: BoxFit.cover));
    }

    if (_imagenActualUrl != null && _imagenActualUrl!.isNotEmpty) {
      // Mostrar la imagen guardada en el servidor
      final isBase64 = _imagenActualUrl!.startsWith("data:image");
      final imageWidget = isBase64
          ? Image.memory(
              base64Decode(_imagenActualUrl!.split(",").last),
              fit: BoxFit.cover,
            )
          : Image.network(_imagenActualUrl!, fit: BoxFit.cover);

      return _imageStack(imageWidget);
    }

    return const Text(
      "Sin imagen adjunta",
      style: TextStyle(color: Colors.grey),
    );
  }

  Widget _imageStack(Widget imageWidget) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: imageWidget,
          ),
        ),
        if (_imagenNueva != null)
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => setState(() => _imagenNueva = null),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Modificar Reporte",
                        style: titleTextStyle,
                      ),
                      const SizedBox(height: 40),
                      Form(
                        key: formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: nombreSospechosoController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: "Nombre del sospechoso",
                                border: OutlineInputBorder(),
                                hintText: "ej: Felipe Roa",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return emptyTextForm;
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 20),

                            TextFormField(
                              controller: descriptionController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: "Descripción",
                                border: OutlineInputBorder(),
                                hintText: "ej: Robo de productos",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return emptyTextForm;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Imagen o evidencia",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _buildImagePreview(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                FilledButton.icon(
                                  onPressed: () =>
                                      seleccionarImagen(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text("Cámara"),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: buttonColor,
                                    padding: const EdgeInsets.all(14),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                FilledButton.icon(
                                  onPressed: () =>
                                      seleccionarImagen(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text("Galería"),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: buttonColor,
                                    padding: const EdgeInsets.all(14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: interfaceColor,
                                padding: const EdgeInsets.all(16),
                              ),
                              onPressed: submit,
                              child: const Text(
                                "Guardar cambios",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: buttonColor,
                                padding: const EdgeInsets.all(16),
                              ),
                              onPressed: deleteReport,
                              child: const Text(
                                "Eliminar reporte",
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}