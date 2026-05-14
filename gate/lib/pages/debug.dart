// lib/debug.dart
import 'package:flutter/material.dart';
import 'package:gate/custom_widgets/navbar.dart';
import 'package:gate/custom_widgets/option_menu.dart';

import '/config.dart';

// Por mientras q es debug
import 'login.dart';
import 'error.dart';

void logout(BuildContext context){

  // Limpiar sesión
  userToken = "";

  userId = 0;

  userEmail = "";

  userName = "";

  userLastName = "";

  userIsAdmin = false;

  userSupermarketId = 0;

  // Volver login
  Navigator.pushAndRemoveUntil(

    context,

    MaterialPageRoute(
      builder: (context) => const LoginPage(),
    ),

    (route) => false,
  );
}

class debug extends StatelessWidget {
  const debug({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Column(
          children: [
            const Text("DEBUG PARA VER LAS DEMAS VISTAS"),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text("Ver Login"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ErrorPage()),
                );
              },
              child: const Text("Ver pagina de error"),
            ),

            FilledButton(onPressed: () {},  
              style: FilledButton.styleFrom(backgroundColor: interfaceColor), child: const Text("Cambiar foto de perfil")
            ),

            SizedBox(height: 20,),

            FilledButton(
              onPressed: () {
                logout(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
              ),
              child: const Text("Cerrar sesión"),
            ),

            
            const Expanded(child: Text(" ")),
            const OptionContainer()
          ],
        ),
      ),
    );
  }
}
