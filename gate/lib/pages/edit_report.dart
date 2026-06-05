import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gate/config.dart';
import 'package:gate/pages/encargado.dart';
import 'package:gate/pages/mis_reportes.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../custom_widgets/navbar.dart';


// No se corrige correctamente la imagen

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
  File? _imagenSeleccionada;
  final formkey = GlobalKey<FormState>();

  final descriptionController = TextEditingController();
  final imageController = TextEditingController(); // Nose si funcione DEBUG

  Future<void> loadReportInfo() async {
    final response = await http.get(
      Uri.parse("$baseUrl/reportes/${widget.editReportId}"),
      headers: {
        "Authorization": "Bearer $userToken",
      },
    );

    print(response.body);

    final data = jsonDecode(response.body);

    setState(() {
      descriptionController.text = data["description"];

    });
  }
  @override
  void initState() {
    super.initState();
    loadReportInfo();
  }
  @override
  void dispose() {
    descriptionController.dispose(); // Falta la img
    super.dispose();
  }

  Future<void> submitReport() async {
    try {

      final response = await http.put(

        Uri.parse("$baseUrl/reportes/${widget.editReportId}"),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken",
        },

        body: jsonEncode({
          "description": descriptionController.text,

        }),
      );

      print(response.body);

      // EXITOSO
      if (response.statusCode == 200 || response.statusCode == 201) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminPage(),
          ),
        );
      }

      // ERROR
      else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error al modificar al usuario"),
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

  Future<void> deleteReport() async {
    try {

      final response = await http.delete(

        Uri.parse("$baseUrl/reportes/${widget.editReportId}"),

        headers: {
          "Authorization": "Bearer $userToken",
        },
      );

      print(response.body);

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
        _imagenSeleccionada = File(imagen.path);
      });
    }
    else{
      // Aca deberia seleccionar la imagen antigua, en caso de haber... o nose
    }
  }

  void submit() {
    if (formkey.currentState!.validate()) {
      submitReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),

              child: Column(

                children: [

                  Text(
                    "Formulario para Modificar Reporte",
                    style: titleTextStyle,
                  ),

                  const SizedBox(height: 40),

                  Form(

                    key: formkey,

                    child: Column(

                      children: [

                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: "Ingresar descripción",
                            hintText: "ej: Robo de productos",
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return emptyTextForm;
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 40,),

                        // Botones de cámara y galería
                        Text("Modificar img no funcional,,,"), // DEBUG
                        Row(
                          children: [
                            FilledButton.icon(
                              onPressed: () => seleccionarImagen(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("Cámara"),
                              style: FilledButton.styleFrom(
                                backgroundColor: buttonColor,
                                padding: const EdgeInsets.all(14),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FilledButton.icon(
                              onPressed: () => seleccionarImagen(ImageSource.gallery),
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
                        SizedBox(height: 20,),
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
          ],
        ),
      ),
    );
  }
}