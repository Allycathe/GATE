// lib/main.dart
import 'package:flutter/material.dart';

// ** Importar otras paginas .dart (links)
import 'config.dart';
import 'custom_widgets/navbar.dart';
import 'custom_widgets/option_menu.dart';
import 'pages/debug.dart';

// Variables: (Estaticas por el moment)
const nombre = "Alonso";
const apellido = "Iturrianda";

const rol = "Guardia en la isla Epstein";
const local = "Unimarc Av. San Martín 0675";

const isAdmin = false;

// ** Main
void main() => runApp(const MiAppMapa());

class MiAppMapa extends StatelessWidget {
  const MiAppMapa({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PantallaInicio(),
    );
  }
}

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

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
            const Text("Bienvenido", style: titleTextStyle),
            const Text("$nombre $apellido", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,)),

            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => debug()));
              }, // Por el mometn no hace nada el boton
              style: ElevatedButton.styleFrom(backgroundColor: interfaceColor, foregroundColor: Colors.white,),
              child: const Text("Aca va el Perfil pero lo uso cmo debug por mientras")), 

            const Expanded(child: Text(" ")),
            const OptionContainer()
          ]),
      ));
  }
}
