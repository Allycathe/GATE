// lib/debug.dart
import 'package:flutter/material.dart';
import 'package:gate/main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../custom_widgets/navbar.dart';

final route = "$baseUrl/auth/login";

// Default settings
const emptyTextForm = "Campo vacio";
const exampleEmail = "example@gmail.com";
const examplePassword = "你好世界";
// Variables

var email = "";
var pw = "";

Future<void> getUserInfo(int id, String token) async {
  
  final response = await http.get(
    Uri.parse("$baseUrl/usuarios/perfil/$id"), // Llamado a la API
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  print(response.body);

  final data = jsonDecode(response.body);

  userName = data["name"];
  userLastName = data["last_name"];
}

 Future<void> login(BuildContext context) async {
      try {
        final response = await http.post(

          Uri.parse(route),

          headers: {
            "Content-Type": "application/json",
          },

          body: jsonEncode({
            "email": email,
            "password": pw,
          }),
        );

        // LOGIN EXITOSO
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          userToken  = data["token"];
          userId = data["usuario"]["id"];
          userEmail = data["usuario"]["email"];

          print("TOKEN: $userToken ID: $userId");

          getUserInfo(userId, userToken);
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MiAppMapa(),
            ),
          );

        }

        // ERROR LOGIN
        else {

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Credenciales invalidas"),
            ),
          );
        }
      }

      catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error conexión: $e"),
          ),
        );
      }
    }


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  

  @override
  Widget build(BuildContext context) {
    final formkey = GlobalKey<FormState>(); // Form key

   
    void submit() {
      if (formkey.currentState!.validate()) {
        login(context);
      }
    }

    return Scaffold(
      appBar: const CustomAppBar(),
      body: 
        Container(
          color: interfaceColor,
          child:
              Center(
                child:  
                  Column(
                    children: [
                      const SizedBox(height: 80,),
                      ColoredBox(
                        color: Colors.white,
                        child: 
                          Padding(
                            padding: const EdgeInsets.all(50),
                            child: 
                              Column( // Textos
                                children: [
                                  const SizedBox(height: 10),
                                  const Text("Bienvenido",
                                    style: titleTextStyle),
                                  const SizedBox(height: 30),
                                  // ** Formulario
                                  Form(
                                    key: formkey,
                                    child: 
                                      Column( children: [
                                        TextFormField( // email form
                                          decoration: const InputDecoration(
                                            labelText: "Ingresar email",
                                            hintText: "ej: $exampleEmail",
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return emptyTextForm;
                                            }
                                            if (!value.contains("@")){
                                              return 'Formato invalido';
                                            }
                                            else {
                                              email = value;
                                            }
                                            return null;
                                          }
                                        ),
                                        TextFormField( // password form
                                          decoration: const InputDecoration(
                                            labelText: "Ingresar contraseña",
                                            hintText: "ej: $examplePassword",
                                          ),
                                          validator: (value){
                                            if (value == null || value.isEmpty) {
                                              return emptyTextForm;
                                            }
                                            else {
                                              pw = value;
                                            }
                                            return null;
                                          }
                                        ),
                                      ])
                                    ),
                                  const SizedBox(height: 40),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: buttonColor,
                                      padding: const EdgeInsets.all(16),
                                    ),
                                    onPressed: () { submit(); },
                                    child: const Text("Ingresar al sistema")
                                  )
                              ])
                            )
                      )
                    ]
                  )
              )
        )
    );
  }
}
