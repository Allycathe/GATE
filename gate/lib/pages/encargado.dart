// lib/debug.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gate/pages/edit_user.dart';
import 'package:gate/pages/new_user.dart';
import 'package:http/http.dart' as http;

import '../custom_widgets/navbar.dart';
import '../config.dart';
import '../custom_widgets/option_menu.dart';

var tablePadding = 15.0; 

Future<List<dynamic>> getUsers() async {
  final response = await http.get(
    Uri.parse("$baseUrl/usuarios/"),
    headers: {
      "Authorization": "Bearer $userToken",
    },
  );

  if (response.statusCode == 200) {

    final data = jsonDecode(response.body);
    return data["usuarios"];
  }

  else {
    throw Exception("Error cargando usuarios");
  }
}


class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

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
                    Text("Información de usuarios", style: titleTextStyle),
                    SizedBox(height: 30,),
                    FilledButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewUserPage()));
                      },
                      style: FilledButton.styleFrom(backgroundColor: buttonColor, padding: EdgeInsets.all(16)),
                      child: const Text("Añadir usuario")
                    ), 

                    SizedBox(height: 20,),

                    Text("Lista de usuarios", style: subTitleTextStyle,),
                    Text("ENDPOINT PARA SOLO OBTENER USERS DEL LOCAL DEL ENCARGADO (/usuarios/local/:local)"),
                    SizedBox(height: 20,),

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
                                    "Nombre",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Apellido",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Email",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Cargo",
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
                                future: getUsers(),

                                builder: (context, snapshot) {
                                    // Cargando
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }

                                    // Error
                                    if (snapshot.hasError) {
                                      return const Text("Error cargando usuarios");
                                    }

                                    // Data
                                    final users = snapshot.data!;

                                    return Table(
                                      border: TableBorder.all(
                                        color: Colors.black,
                                      ),

                                      children: [

                                        for (var user in users)

                                          TableRow(
                                            children: [

                                              Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text("${user["id"]}"),
                                              ),

                                              Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(user["name"]),
                                              ),

                                              Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(user["last_name"]),
                                              ),

                                              Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(user["email"]),
                                              ),

                                              if (user["isadmin"])
                                                Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Text("Encargado")
                                                ),
                                              if (!user["isadmin"])
                                                Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Text("Guardia")
                                                ),
                                              

                                              Padding(
                                                padding: EdgeInsets.all(8),
                                                child: IconButton(
                                                  icon: Icon(Icons.edit),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => EditUserPage(
                                                          editUserId: user["id"],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  tooltip: "Editar usuario",
                                                  
                                                  
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    );
                                  },
                                  ))
                      ))
                    ),
                      

                    SizedBox(height: 20),
                    Text(""),
                    Text("Estadisticas", style: titleTextStyle),
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
