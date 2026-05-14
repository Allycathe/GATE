import 'package:flutter/material.dart';
import 'package:gate/pages/map.dart';

import '../config.dart';
import '../custom_widgets/option_menu.dart';
import '../custom_widgets/navbar.dart';
import '../services/report_service.dart';

class ReportsPage extends StatefulWidget{
    const ReportsPage({super.key});

    @override
    State<ReportsPage> createState(){
        return _ReportsPageState();
    }
}

class _ReportsPageState extends State<ReportsPage>{
    bool cargando = true;
    String? mensajeError;
    List<dynamic> reportes = [];

    @override
    void initState(){
        super.initState();
        cargarReportes();
    }

    Future<void> cargarReportes() async{
        try{
            final data = await ReportService.listarReportes();

            setState((){
                reportes = data;
                cargando = false;
                mensajeError = null;
            });
        }
        catch(error){
            setState((){
                cargando = false;
                mensajeError = error.toString();
            });
        }
    }

    String formatearFecha(String? fechaApi){
        if(fechaApi == null){
            return "Sin fecha";
        }

        try{
            final fecha = DateTime.parse(fechaApi).toLocal();

            final year = fecha.year.toString();
            final month = fecha.month.toString().padLeft(2, "0");
            final day = fecha.day.toString().padLeft(2, "0");
            final hour = fecha.hour.toString().padLeft(2, "0");
            final minute = fecha.minute.toString().padLeft(2, "0");

            return "$year-$month-$day $hour:$minute";
        }
        catch(error){
            return fechaApi;
        }
    }

    @override
    Widget build(BuildContext context){
        return Scaffold(
            appBar: const CustomAppBar(),
            body: Center(
                child: Column(
                    children: [
                        Expanded(
                            child: SingleChildScrollView(
                                child: Column(
                                    children: [
                                        const SizedBox(height: 20),

                                        const Center(
                                            child: Text(
                                                "Reportes recientes",
                                                style: titleTextStyle,
                                            ),
                                        ),

                                        Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                                children: [
                                                    FilledButton(
                                                        onPressed: (){
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => const map(),
                                                                ),
                                                            );
                                                        },
                                                        style: FilledButton.styleFrom(
                                                            backgroundColor: buttonColor,
                                                            padding: const EdgeInsets.all(16),
                                                        ),
                                                        child: const Text("Ver mapa"),
                                                    ),

                                                    const SizedBox(height: 20),

                                                    FilledButton(
                                                        onPressed: (){
                                                            setState((){
                                                                cargando = true;
                                                            });

                                                            cargarReportes();
                                                        },
                                                        style: FilledButton.styleFrom(
                                                            backgroundColor: interfaceColor,
                                                            padding: const EdgeInsets.all(16),
                                                        ),
                                                        child: const Text("Actualizar reportes"),
                                                    ),

                                                    const SizedBox(height: 20),

                                                    if(cargando == true)
                                                        const CircularProgressIndicator()

                                                    else if(mensajeError != null)
                                                        Text(
                                                            "Error al cargar reportes:\n$mensajeError",
                                                            style: const TextStyle(
                                                                color: Colors.red,
                                                            ),
                                                        )

                                                    else if(reportes.isEmpty)
                                                        const Text(
                                                            "No existen reportes registrados.",
                                                            style: TextStyle(
                                                                color: Colors.grey,
                                                            ),
                                                        )

                                                    else
                                                        ...reportes.map((reporte){
                                                            final id = reporte["id"];
                                                            final idThief = reporte["id_thief"];
                                                            final descripcion = reporte["description"] ?? "Sin descripción";
                                                            final fecha = formatearFecha(reporte["date"]);
                                                            final idSupermarket = reporte["id_supermarket"];

                                                            return Container(
                                                                margin: const EdgeInsets.only(bottom: 12),
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(color: Colors.black),
                                                                    borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Row(
                                                                        children: [
                                                                            Expanded(
                                                                                child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                        Text(
                                                                                            "ID del reporte: $id",
                                                                                            style: const TextStyle(
                                                                                                fontWeight: FontWeight.bold,
                                                                                            ),
                                                                                        ),

                                                                                        const SizedBox(height: 4),

                                                                                        Text("ID persona reportada: $idThief"),
                                                                                        Text("ID supermercado: $idSupermarket"),
                                                                                        Text("Fecha: $fecha"),

                                                                                        const SizedBox(height: 6),

                                                                                        Text(
                                                                                            "Descripción: $descripcion",
                                                                                        ),
                                                                                    ],
                                                                                ),
                                                                            ),

                                                                            const SizedBox(width: 10),

                                                                            Image.asset(
                                                                                'assets/profile_pic.jpg',
                                                                                height: 100,
                                                                                width: 100,
                                                                                fit: BoxFit.cover,
                                                                                errorBuilder: (context, error, stackTrace){
                                                                                    return const Icon(
                                                                                        Icons.report,
                                                                                        size: 80,
                                                                                        color: Colors.red,
                                                                                    );
                                                                                },
                                                                            ),
                                                                        ],
                                                                    ),
                                                                ),
                                                            );
                                                        }),
                                                ],
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),

                        const OptionContainer(),
                    ],
                ),
            ),
        );
    }
}