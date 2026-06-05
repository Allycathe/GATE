import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gate/config.dart';
import 'package:gate/pages/encargado.dart';
import 'package:http/http.dart' as http;

import '../custom_widgets/navbar.dart';

bool isAdmin = false;

final route = "$baseUrl/usuarios";
const emptyTextForm = "Campo vacio";

class NewUserPage extends StatefulWidget {
  const NewUserPage({super.key});

  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {

  final formkey = GlobalKey<FormState>();

  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  Future<void> submitUser() async {
    
    print("DEBUG: isAdmin ="); 
    print(isAdmin);

    try {

      final response = await http.post(
        Uri.parse(route),

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
          "id_supermarket": userSupermarketId,

        }),
      );

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
            content: Text("Error al ingresar al usuario"),
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
                    "Formulario para crear usuario",
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
                            backgroundColor: buttonColor,
                            padding: const EdgeInsets.all(16),
                          ),

                          onPressed: submit,

                          child: const Text(
                            "Crear usuario",
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