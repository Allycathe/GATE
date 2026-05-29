import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gate/config.dart';
import 'package:gate/pages/encargado.dart';
import 'package:http/http.dart' as http;

import '../custom_widgets/navbar.dart';

bool isAdmin = false;

const emptyTextForm = "Campo vacio";
//var editUserId = 0; // Yo lo añadi

class EditUserPage extends StatefulWidget {

  final int editUserId;

  const EditUserPage({
    super.key,
    required this.editUserId,
  });

  

  @override
  State<EditUserPage> createState() => _EditUserPage();
}

class _EditUserPage extends State<EditUserPage> {

  final formkey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  Future<void> loadUserInfo() async {
    final response = await http.get(

      Uri.parse("$baseUrl/usuarios/perfil/${widget.editUserId}"),

      headers: {
        "Authorization": "Bearer $userToken",
      },
    );

    print(response.body);

    final data = jsonDecode(response.body);

    setState(() {

      nombreController.text = data["name"];
      apellidoController.text = data["last_name"];
      emailController.text = data["email"];

      isAdmin = data["isadmin"];
    });
  }
  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }
  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  Future<void> submitUser() async {
    try {

      final response = await http.put(

        Uri.parse("$baseUrl/usuarios/${widget.editUserId}"),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $userToken",
        },

        body: jsonEncode({

          "name": nombreController.text,
          "last_name": apellidoController.text,
          "email": emailController.text,
          "password": pwController.text,
          "isadmin": isAdmin,
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

  Future<void> deleteUser() async {
    try {

      final response = await http.delete(

        Uri.parse("$baseUrl/usuarios/${widget.editUserId}"),

        headers: {
          "Authorization": "Bearer $userToken",
        },
      );

      print(response.body);

      if (response.statusCode == 200) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminPage(),
          ),
        );
      }

      else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error eliminando usuario"),
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

  void submit() {

    if (formkey.currentState!.validate()) {
      submitUser();
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
                    "Formulario para modificar usuario",
                    style: titleTextStyle,
                  ),

                  const SizedBox(height: 40),

                  Form(

                    key: formkey,

                    child: Column(

                      children: [

                        TextFormField(

                          controller: nombreController,

                          decoration: const InputDecoration(
                            labelText: "Ingresar nombre",
                            hintText: "ej: Mohammed",
                          ),

                          validator: (value) {

                            if (value == null || value.isEmpty) {
                              return emptyTextForm;
                            }

                            return null;
                          },
                        ),

                        TextFormField(

                          controller: apellidoController,

                          decoration: const InputDecoration(
                            labelText: "Ingresar apellido",
                            hintText: "ej: Gonzales",
                          ),

                          validator: (value) {

                            if (value == null || value.isEmpty) {
                              return emptyTextForm;
                            }

                            return null;
                          },
                        ),

                        TextFormField(

                          controller: emailController,

                          decoration: const InputDecoration(
                            labelText: "Ingresar email",
                            hintText: "ej: hola.mondo@email.com",
                          ),

                          validator: (value) {

                            if (value == null || value.isEmpty) {
                              return emptyTextForm;
                            }

                            if (!value.contains("@")) {
                              return "Formato invalido";
                            }

                            return null;
                          },
                        ),

                        TextFormField(

                          controller: pwController,

                          decoration: const InputDecoration(
                            labelText: "Ingresar contraseña",
                            hintText: "ej: 你好世界",
                          ),

                          validator: (value) {

                            if (value == null || value.isEmpty) {
                              return emptyTextForm;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        SwitchListTile(

                          activeThumbColor: interfaceColor,

                          title: const Text("¿Es administrador?"),

                          value: isAdmin,

                          onChanged: (value) {

                            setState(() {
                              isAdmin = value;
                            });
                          },
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

                          onPressed: deleteUser,

                          child: const Text(
                            "Eliminar usuario",
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