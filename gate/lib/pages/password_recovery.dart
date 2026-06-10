import 'package:flutter/material.dart';
import 'package:gate/config.dart';
import '../custom_widgets/navbar.dart';


class PwRecoveryPage extends StatelessWidget {
  const PwRecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: 
        Center(
          child: Column(
            children: [
              Text("Recuperar Contraseña", style: titleTextStyle,),

              SizedBox(height: 40),

              Text("data")
              // Enviar el correo por formulario en la app para despues en backend recibirlo (POST)
              // Backend al recibir, crea un codigo y envia un email al correo ingresado
              // Luego en la app se registra el codigo, y si es correcto -> iniciar formulario para cambiar contraseña
              // Despues de cambiar -> volver a pagina de login 
            ],
          ),
        )
    );
  }
}
