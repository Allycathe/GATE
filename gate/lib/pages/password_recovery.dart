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
              
            ],
          ),
        )
    );
  }
}
