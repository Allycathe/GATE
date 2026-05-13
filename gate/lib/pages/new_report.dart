import 'package:flutter/material.dart';
import '/custom_widgets/navbar.dart';
import '../config.dart';

class NewReport extends StatefulWidget{
    const NewReport({super.key});

    @override
    State<NewReport> createState(){
        return _ReportPageState();
    }
}

class _ReportPageState extends State<NewReport>{
    final _formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();

    final String nombreUsuario = "Alonso Iturrianda";
    final String supermercadoUsuario = "Unimarc";
    final String rolUsuario = "Guardia";

    String descripcion = "";
    bool noExisteNombre = false;

    final List<Map<String, String>> reportes = [
        {
            "persona": "Juan escobar",
            "supermercado": "Unimarc",
            "reportadoPor": "Alonso iturra",
            "fecha": "2026-05-11 18:40",
            "descripcion": "Persona observada ocultando productos en una mochila.",
        },
        {
            "persona": "Persona no identificada",
            "supermercado": "Unimarc",
            "reportadoPor": "Alonso iturra",
            "fecha": "2026-05-10 16:15",
            "descripcion": "Intentó salir del local sin pagar productos de higiene personal.",
        },
    ];

    String obtenerFechaActual(){
        final fecha = DateTime.now();

        final year = fecha.year.toString();
        final month = fecha.month.toString().padLeft(2, "0");
        final day = fecha.day.toString().padLeft(2, "0");
        final hour = fecha.hour.toString().padLeft(2, "0");
        final minute = fecha.minute.toString().padLeft(2, "0");

        return "$year-$month-$day $hour:$minute";
    }

    void guardarReporte(){
        if(!_formKey.currentState!.validate()){
            return; 
        }

        _formKey.currentState!.save();

        String nombreFinal = "";

        if(noExisteNombre == true){
            nombreFinal = "Persona no identificada";
        }
        else{
            nombreFinal = nombreController.text.trim();
        }

        final nuevoReporte = {
            "persona": nombreFinal,
            "supermercado": supermercadoUsuario,
            "reportadoPor": nombreUsuario,
            "fecha": obtenerFechaActual(),
            "descripcion": descripcion,
        };

        setState((){
            reportes.insert(0, nuevoReporte);
            noExisteNombre = false;
            nombreController.clear();
        });

        _formKey.currentState!.reset();

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Reporte registrado correctamente"),
            ),
        );
    }

    @override
    void dispose(){
        nombreController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: const CustomAppBar(),
            body: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                    const Text(
                        "Nuevo reporte",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                        ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: interfaceColor,
                            borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                            "Usuario: $nombreUsuario\n"
                            "Sucursal: $supermercadoUsuario\n"
                            "Rol: $rolUsuario",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                            ),
                        ),
                    ),

                    const SizedBox(height: 25),

                    Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Text(
                                    "Persona reportada",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),

                                const SizedBox(height: 6),

                                TextFormField(
                                    controller: nombreController,
                                    enabled: !noExisteNombre,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: "Ingrese el nombre de la persona",
                                    ),
                                    validator: (value){
                                        if(noExisteNombre == true){
                                            return null; 
                                        }

                                        if(value == null || value.trim().isEmpty){
                                            return "Debe ingresar un nombre o marcar que no existe";
                                        }

                                        return null; 
                                    },
                                ),

                                CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text("No existe nombre"),
                                    value: noExisteNombre,
                                    onChanged: (value){
                                        setState((){
                                            noExisteNombre = value!;

                                            if(noExisteNombre == true){
                                                nombreController.clear();
                                            }
                                        });
                                    },
                                ),

                                if(noExisteNombre == true)
                                    const Text(
                                        "El reporte se guardará como: Persona no identificada",
                                        style: TextStyle(
                                            color: Colors.grey,
                                        ),
                                    ),

                                const SizedBox(height: 18),

                                const Text(
                                    "Descripción del incidente",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),

                                const SizedBox(height: 6),

                                TextFormField(
                                    maxLines: 5,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: "Ej: Persona observada ocultando productos...",
                                    ),
                                    validator: (value){
                                        if(value == null || value.trim().isEmpty){
                                            return "Debe ingresar una descripción";
                                        }

                                        if(value.trim().length < 10){
                                            return "La descripción es demasiado corta";
                                        }

                                        return null; 
                                    },
                                    onSaved: (value){
                                        descripcion = value!.trim();
                                    },
                                ),

                                const SizedBox(height: 18),

                                const Text(
                                    "Imagen o evidencia",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),

                                const SizedBox(height: 6),

                                FilledButton.icon(
                                    onPressed: (){
                                      
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text("La imagen se conectará después"),
                                            ),
                                        );
                                    },
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text("Subir imagen"),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: buttonColor,
                                      padding: const EdgeInsets.all(16),
                                    ),
                                ),

                                const SizedBox(height: 24),

                                SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                        onPressed: guardarReporte,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: interfaceColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.all(14),
                                        ),
                                        child: const Text(
                                            "Enviar reporte",
                                            style: TextStyle(
                                                fontSize: 16,
                                            ),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),

                    const SizedBox(height: 35),

                    const Text(
                        "Reportes recientes",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                        ),
                    ),

                    const SizedBox(height: 12),

                    if(reportes.isEmpty)
                        const Text(
                            "No existen reportes recientes.",
                            style: TextStyle(
                                color: Colors.grey,
                            ),
                        )
                    else
                        ...reportes.map((reporte){
                            return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                    title: Text(
                                        reporte["persona"]!,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                        ),
                                    ),
                                    subtitle: Text(
                                        "Sucursal: ${reporte["supermercado"]}\n"
                                        "Reportado por: ${reporte["reportadoPor"]}\n"
                                        "Fecha: ${reporte["fecha"]}\n"
                                        "${reporte["descripcion"]}",
                                    ),
                                ),
                            );
                        }),
                ],
            ),
        );
    }
} // d