// lib/debug.dart
import 'package:flutter/material.dart';
import 'package:gate/pages/edit_report.dart';

import '../custom_widgets/navbar.dart';
import '../config.dart';


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gate/pages/edit_user.dart';
import 'package:gate/pages/new_user.dart';
import 'package:http/http.dart' as http;

import '../custom_widgets/navbar.dart';
import '../config.dart';
import '../custom_widgets/option_menu.dart';


var tablePadding = 15.0; 

Future<List<dynamic>> getReportes() async {
  final response = await http.get(
    Uri.parse("$baseUrl/reportes/"),
    headers: {
      "Authorization": "Bearer $userToken",
      "Content-Type": "application/json"
    },

  );

  if (response.statusCode == 200) {
    print(response.body);
    return jsonDecode(response.body);
  }

  else {
    throw Exception("Error cargando reportes");
  }
}


class MisReportes extends StatelessWidget {
  const MisReportes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: 
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: 
                Column(
                  children: [
                    Text("Información de Reportes", style: titleTextStyle),
                    SizedBox(height: 30,),

                    SizedBox(height: 20,),

                    Text("Lista de Mis Reportes", style: subTitleTextStyle),
                    SizedBox(height: 5,),

                    // Encabezado de la tabla
                    Container(padding: EdgeInsets.only( left: tablePadding, top: tablePadding, right: tablePadding),child: 
                    Table(
                      border: TableBorder.all(
                        color: Colors.black,
                        width: 1
                      ),
                      children: [
                        TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "ID",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "ID Sospechoso",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Descripción",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Fecha",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Imagen",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Editar",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                    ),
                    ConstrainedBox(constraints: BoxConstraints(
                      maxHeight: 500
                      ),
                      child: Container(padding: EdgeInsets.only( left: tablePadding, bottom: tablePadding, right: tablePadding) ,child: 
                      SingleChildScrollView(
                        child:
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1.0)),
                            child: 
                              FutureBuilder(
                                future: getReportes(),

                                builder: (context, snapshot) {
                                    // Cargando
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    // Error
                                    if (snapshot.hasError) {
                                      return const Text("Error cargando reportes");
                                    }

                                    // Data
                                    final reportes = snapshot.data!;

                                    return 
                                      Column(children: [
                                        Table(
                                          border: TableBorder.all(
                                            color: Colors.black,
                                          ),
                                          children: [
                                            for (var reporte in reportes)
                                              if(reporte["id_user"] == userId)
                                                TableRow
                                                  (
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.all(8),
                                                      child: Text("${reporte["id"]}"),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.all(8),
                                                      child: Text("${reporte["id_thief"]}"),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.all(8),
                                                      child: Text(reporte["description"]),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.all(8),
                                                      child: Text(reporte["date"]),
                                                    ),
                                                    Image.network(
                                                      '$baseUrl/reportes/${reporte["id"]}/imagen',
                                                      height: 100,
                                                      width: 100,
                                                      fit: BoxFit.cover,
                                                      headers: {
                                                        'Authorization': 'Bearer $userToken',
                                                      },
                                                      errorBuilder:
                                                          (context, error, stackTrace) {
                                                        return const Icon(
                                                          Icons.report,
                                                          size: 80,
                                                          color: Colors.red,
                                                        );
                                                      },
                                                      loadingBuilder:
                                                          (context, child, loadingProgress) {
                                                        if (loadingProgress == null)
                                                          return child;
                                                        return const SizedBox(
                                                          height: 100,
                                                          width: 100,
                                                          child: Center(
                                                              child:
                                                                  CircularProgressIndicator()),
                                                        );
                                                      },
                                                    ),

                                                    // Boton para editar
                                                    Padding(
                                                      padding: EdgeInsets.all(8),
                                                      child: IconButton(
                                                        icon: Icon(Icons.edit),
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => EditReportPage(
                                                                editReportId: reporte["id"],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        tooltip: "Editar Reporte",
                                                        
                                                        
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          ],
                                        ),                                        
                                      ],
                                    );
                                  },
                                )
                              )
                      ))
                    ),
                    SizedBox(height: 30,),
                  ],
                ),
              ),
            
            ),
            
            const OptionContainer(),
          ],
        )
    );
  }
}

