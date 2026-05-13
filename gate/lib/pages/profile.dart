import 'package:flutter/material.dart';

import '../config.dart';
import '../custom_widgets/option_menu.dart';
import '../custom_widgets/navbar.dart';

import '/pages/debug.dart';

// Variables: (Estaticas por el moment)
const nombre = "Alonso";
const apellido = "Iturrianda";

const rol = "Guardia en la isla Epstein";
const local = "Unimarc Av. San Martín 0675";

const isAdmin = false;

var profileDefaultImage = const NetworkImage("https://i.pinimg.com/474x/c6/a9/a1/c6a9a1c3ec3b086dda8de521ffc46f61.jpg"); // Img si no se encuentra la real
var profileImage = const AssetImage('assets/profile_pic.jpg');


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: 
        Center( 
          child: Column(
            children: [
            const SizedBox(height: 50),

            CircleAvatar(  // Foto de example
              radius: 100,
              child: ClipOval(
                child: Image.asset(
                  'assets/profile_pic.jpg',
                  height: 200, width: 200,
                  fit: BoxFit.cover,

                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'https://i.pinimg.com/474x/c6/a9/a1/c6a9a1c3ec3b086dda8de521ffc46f61.jpg',
                      height: 200, width: 200,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),
            const Text("$nombre $apellido", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,)),
            const SizedBox(height: 30),
            const Text("Rol: $rol", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            const Text("Local: $local", style: TextStyle(fontSize: 20),),
            const SizedBox(height: 20,),
            FilledButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => debug()));
              }, // Por el mometn no hace nada el boton
              style: FilledButton.styleFrom(backgroundColor: buttonColor),
              child: const Text("Debug")), 

            //const SizedBox(height: 100), // Espacio entre el texto y los botones inferiores

            const Expanded(child: Text(" ")),
            const OptionContainer()
          ]),
      ));
  }
}
