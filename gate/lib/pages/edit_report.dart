import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gate/config.dart';
import 'package:gate/services/report_service.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_client.dart';

class EditReportPage extends StatefulWidget {
  final int editReportId;

  const EditReportPage({
    super.key,
    required this.editReportId,
  });

  @override
  State<EditReportPage> createState() => _EditReportPageState();
}

class _EditReportPageState extends State<EditReportPage> {
  final ImagePicker _picker = ImagePicker();
  File? _imagenNueva;
  String? _imagenActualUrl;

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  int _idSupermarket = 0;
  bool _cargando = true;
  bool _guardando = false;
  bool _eliminando = false;

  @override
  void initState() {
    super.initState();
    _loadReportInfo();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadReportInfo() async {
    try {
      final response = await ApiClient.get('/reportes/${widget.editReportId}');
      final data = jsonDecode(response.body);
      setState(() {
        _descripcionController.text = data["description"] ?? "";
        _nombreController.text = data["nombre_sospechoso"] ?? "";
        _idSupermarket = data["id_supermarket"] ?? 0;
        _imagenActualUrl = data["image"];
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _seleccionarImagen(ImageSource fuente) async {
    final XFile? imagen =
        await _picker.pickImage(source: fuente, imageQuality: 80);
    if (imagen != null) {
      setState(() => _imagenNueva = File(imagen.path));
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await ReportService.actualizarReporte(
        id: widget.editReportId,
        nombreSospechoso: _nombreController.text,
        description: _descripcionController.text,
        idSupermarket: _idSupermarket,
        imagen: _imagenNueva,
        imagenUrlActual: _imagenActualUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text("Reporte actualizado"),
            ]),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al guardar: $e"),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _eliminarReporte() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A3A6B),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Eliminar reporte",
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          "¿Estás seguro? Esta acción no se puede deshacer.",
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar",
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar",
                style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _eliminando = true);
    try {
      final response = await ApiClient.delete('/reportes/${widget.editReportId}');
      if (response.statusCode == 200) {
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Error eliminando reporte"),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error conexión: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _eliminando = false);
    }
  }

  Widget _buildImagePreview() {
    Widget? imageWidget;

    if (_imagenNueva != null) {
      imageWidget = Image.file(_imagenNueva!, fit: BoxFit.cover);
    } else if (_imagenActualUrl != null && _imagenActualUrl!.isNotEmpty) {
      final isBase64 = _imagenActualUrl!.startsWith("data:image");
      imageWidget = isBase64
          ? Image.memory(
              base64Decode(_imagenActualUrl!.split(",").last),
              fit: BoxFit.cover,
            )
          : Image.network(_imagenActualUrl!, fit: BoxFit.cover);
    }

    if (imageWidget != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: imageWidget,
            ),
          ),
          // Overlay abajo
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          if (_imagenNueva != null)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => setState(() => _imagenNueva = null),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          Positioned(
            bottom: 10,
            right: 12,
            child: GestureDetector(
              onTap: () => _seleccionarImagen(ImageSource.gallery),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text("Cambiar",
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Sin imagen — mostrar botones de selección
    return Row(
      children: [
        Expanded(
          child: _imageButton(
            icon: Icons.camera_alt_outlined,
            label: "Cámara",
            onTap: () => _seleccionarImagen(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _imageButton(
            icon: Icons.photo_library_outlined,
            label: "Galería",
            onTap: () => _seleccionarImagen(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1B3E),
                  Color(0xFF1A3A6B),
                  Color(0xFF0D1B3E),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white70, size: 20),
                      ),
                      const Text(
                        "Editar reporte",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Badge ID
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Text(
                          "#${widget.editReportId}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: _cargando
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white54))
                      : ListView(
                          padding:
                              const EdgeInsets.fromLTRB(24, 16, 24, 32),
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nombre
                                  _sectionLabel("Persona reportada"),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _nombreController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(
                                      hint: "Nombre del sospechoso",
                                      icon: Icons.person_search_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty)
                                        return "Campo vacío";
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 24),

                                  // Descripción
                                  _sectionLabel("Descripción del incidente"),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _descripcionController,
                                    maxLines: 4,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(
                                      hint: "Descripción del incidente...",
                                      icon: Icons.description_outlined,
                                      alignLabelWithHint: true,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty)
                                        return "Campo vacío";
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 24),

                                  // Imagen
                                  _sectionLabel("Evidencia fotográfica"),
                                  const SizedBox(height: 8),
                                  _buildImagePreview(),

                                  const SizedBox(height: 32),

                                  // Botón guardar
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed:
                                          _guardando ? null : _guardarCambios,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: interfaceColor,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            interfaceColor.withOpacity(0.4),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: _guardando
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5),
                                            )
                                          : const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.save_outlined,
                                                    size: 18),
                                                SizedBox(width: 8),
                                                Text("Guardar cambios",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ],
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Botón eliminar
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _eliminando
                                          ? null
                                          : _eliminarReporte,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFEF4444)
                                            .withOpacity(0.1),
                                        foregroundColor:
                                            const Color(0xFFEF4444),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          side: BorderSide(
                                            color: const Color(0xFFEF4444)
                                                .withOpacity(0.4),
                                          ),
                                        ),
                                      ),
                                      child: _eliminando
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                  color: Color(0xFFEF4444),
                                                  strokeWidth: 2.5),
                                            )
                                          : const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                    Icons.delete_outline_rounded,
                                                    size: 18),
                                                SizedBox(width: 8),
                                                Text("Eliminar reporte",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ],
                                            ),
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
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.75),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _imageButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white54, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 13)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14),
      prefixIcon: Padding(
        padding: EdgeInsets.only(bottom: alignLabelWithHint ? 60 : 0),
        child: Icon(icon, color: Colors.white38, size: 20),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      alignLabelWithHint: alignLabelWithHint,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: interfaceColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Color(0xFFEF4444)),
    );
  }
}
