import 'package:flutter/material.dart';
import '../config.dart';
import '../services/report_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewReport extends StatefulWidget {
  const NewReport({super.key});
  @override
  State<NewReport> createState() => _ReportPageState();
}

class _ReportPageState extends State<NewReport> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imagenSeleccionada;
  bool _noExisteNombre = false;
  bool _enviando = false;

  String obtenerFechaActual() {
    final f = DateTime.now();
    return "${f.year}-${f.month.toString().padLeft(2, '0')}-${f.day.toString().padLeft(2, '0')} "
        "${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _seleccionarImagen(ImageSource fuente) async {
    final XFile? imagen =
        await _picker.pickImage(source: fuente, imageQuality: 80);
    if (imagen != null) {
      setState(() => _imagenSeleccionada = File(imagen.path));
    }
  }

  Future<void> _guardarReporte() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _enviando = true);

    final nombreFinal = _noExisteNombre
        ? "Persona no identificada"
        : _nombreController.text.trim();

    try {
      await ReportService.crearReporte(
        nombreSospechoso: nombreFinal,
        description: _descripcionController.text.trim(),
        idSupermarket: userSupermarketId,
        imagen: _imagenSeleccionada,
        idReporter: userId,
      );

      setState(() {
        _noExisteNombre = false;
        _nombreController.clear();
        _descripcionController.clear();
        _imagenSeleccionada = null;
      });
      _formKey.currentState!.reset();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 10),
                Text("Reporte enviado correctamente"),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al enviar reporte: $error"),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
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
                        "Nuevo reporte",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    children: [
                      // Info del usuario
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: interfaceColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: interfaceColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline,
                                color: Colors.white54, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              "$userName $userLastName",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            const Spacer(),
                            const Icon(Icons.store_outlined,
                                color: Colors.white54, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              "Local $userSupermarketId",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

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
                              enabled: !_noExisteNombre,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(
                                hint: "Nombre del sospechoso",
                                icon: Icons.person_search_outlined,
                              ),
                              validator: (value) {
                                if (_noExisteNombre) return null;
                                if (value == null || value.trim().isEmpty) {
                                  return "Ingresa un nombre o marca 'No identificado'";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 10),

                            // Checkbox no identificado
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _noExisteNombre = !_noExisteNombre;
                                  if (_noExisteNombre) _nombreController.clear();
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _noExisteNombre
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _noExisteNombre
                                        ? Colors.white.withOpacity(0.3)
                                        : Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _noExisteNombre,
                                      onChanged: (val) {
                                        setState(() {
                                          _noExisteNombre = val ?? false;
                                          if (_noExisteNombre) _nombreController.clear();
                                        });
                                      },
                                      activeColor: interfaceColor,
                                      checkColor: Colors.white,
                                      side: BorderSide(color: Colors.white38),
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _noExisteNombre
                                          ? "Se guardará como: Persona no identificada"
                                          : "Persona no identificada",
                                      style: TextStyle(
                                        color: _noExisteNombre
                                            ? Colors.white70
                                            : Colors.white38,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                                hint:
                                    "Ej: Persona observada ocultando productos en su ropa...",
                                icon: Icons.description_outlined,
                                alignLabelWithHint: true,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Ingresa una descripción";
                                }
                                if (value.trim().length < 10) {
                                  return "La descripción es demasiado corta";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // Imagen
                            _sectionLabel("Evidencia fotográfica"),
                            const SizedBox(height: 8),

                            if (_imagenSeleccionada == null)
                              // Zona de selección
                              Row(
                                children: [
                                  Expanded(
                                    child: _imageButton(
                                      icon: Icons.camera_alt_outlined,
                                      label: "Cámara",
                                      onTap: () => _seleccionarImagen(
                                          ImageSource.camera),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _imageButton(
                                      icon: Icons.photo_library_outlined,
                                      label: "Galería",
                                      onTap: () => _seleccionarImagen(
                                          ImageSource.gallery),
                                    ),
                                  ),
                                ],
                              )
                            else
                              // Preview imagen
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      _imagenSeleccionada!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Overlay oscuro abajo
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
                                  // Botón quitar
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => setState(
                                          () => _imagenSeleccionada = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ),
                                  // Botón cambiar
                                  Positioned(
                                    bottom: 10,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () => _seleccionarImagen(
                                          ImageSource.gallery),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.edit_outlined,
                                                color: Colors.white, size: 14),
                                            SizedBox(width: 4),
                                            Text("Cambiar",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 32),

                            // Botón enviar
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _enviando ? null : _guardarReporte,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: interfaceColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      interfaceColor.withOpacity(0.4),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _enviando
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.send_rounded, size: 18),
                                          SizedBox(width: 8),
                                          Text(
                                            "Enviar reporte",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
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

  Widget _imageButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
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
