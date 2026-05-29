import 'package:flutter/material.dart';
import 'package:gate/pages/encargado.dart';

import '../config.dart';
import '../custom_widgets/option_menu.dart';
import '../custom_widgets/navbar.dart';

import 'user_options.dart';

String rol = "";
String definirRol(bool isAdmin) {
  return isAdmin ? "Encargado" : "Guardia";
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    rol = definirRol(userIsAdmin);
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
            

            Text("$userName $userLastName", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30,)),
            Text("ID de usuario: $userId", style: const TextStyle(fontSize: 15)),

            const SizedBox(height: 30),

            Text("Rol: $rol", style: const TextStyle(fontSize: 20)),

            Text("Local: $userSupermarketId", style: const TextStyle(fontSize: 20),),
            const SizedBox(height: 20,),
            FilledButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserOptions()));
              },
              style: FilledButton.styleFrom(backgroundColor: buttonColor, padding: EdgeInsets.all(16)),
              child: const Text("Opciones")
            ), 
            SizedBox(height: 20),
            if (userIsAdmin)
              FilledButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPage()));
              },
              style: FilledButton.styleFrom(backgroundColor: adminInterfaceColor, padding: EdgeInsets.all(16)),
              child: Text("Opciones de administrador", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
              ), 

            //const SizedBox(height: 100), // Espacio entre el texto y los botones inferiores

            const Expanded(child: Text(" ")),
            const OptionContainer()
          ]),
      ));
  }
}
