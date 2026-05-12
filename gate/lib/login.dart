// lib/debug.dart
import 'package:flutter/material.dart';

import 'navbar.dart';

const interfaceColor = Color.fromARGB(
    255, 102, 102, 255); // Default interfaceColor.fromARGB(255, 102, 102, 255)
const textOptionColor = Color.fromARGB(
    255, 102, 102, 255); // Default textOptionColor.fromARGB(255, 102, 102, 255)

// Default settings
const emptyTextForm = "Campo vacio";
const exampleEmail = "example@gmail.com";
const examplePassword = "你好世界";
// Variables

var email = "";
var pw = "";

class login extends StatelessWidget {
  const login({super.key});

  @override
  Widget build(BuildContext context) {
    final formkey = GlobalKey<FormState>(); // Form key

    void submit() {
      if (formkey.currentState!.validate()) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Procesando data")));
      }
    }

    return Scaffold(
        appBar: const CustomAppBar(),
        body: Container(
            color: interfaceColor,
            child: Center(
                child: Column(children: [
              const SizedBox(
                height: 80,
              ),
              ColoredBox(
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(50),
                      child: Column(// Textos
                          children: [
                        const SizedBox(height: 10),
                        const Text("Iniciar Sesion",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 50)),
                        const SizedBox(height: 30),
                        // ** Formulario
                        Form(
                            key: formkey,
                            child: Column(children: [
                              TextFormField(
                                  // email form
                                  decoration: const InputDecoration(
                                    labelText: "Ingresar email",
                                    hintText: "ej: $exampleEmail",
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return emptyTextForm;
                                    }
                                    if (!value.contains("@")) {
                                      return 'Formato invalido';
                                    } else {
                                      email = value;
                                    }
                                    return null;
                                  }),
                              TextFormField(
                                  // password form
                                  decoration: const InputDecoration(
                                    labelText: "Ingresar contraseña",
                                    hintText: "ej: $examplePassword",
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return emptyTextForm;
                                    } else {
                                      pw = value;
                                    }
                                    return null;
                                  }),
                            ])),
                        const SizedBox(height: 40),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: interfaceColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(10),
                            ),
                            onPressed: () {
                              submit();
                            },
                            child: const Text("Ingresar al sistema"))
                      ])))
            ]))));
  }
}
