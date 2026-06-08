import 'package:flutter/material.dart';
import 'package:gate/custom_widgets/navbar.dart';
import 'package:gate/custom_widgets/option_menu.dart';

import '/config.dart';
import 'login.dart';

void logout(BuildContext context) {
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

class UserOptions extends StatelessWidget {
  const UserOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40,),
            FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(backgroundColor: interfaceColor),
                child: const Text("Cambiar foto de perfil")),
            SizedBox(
              height: 20,
            ),
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
