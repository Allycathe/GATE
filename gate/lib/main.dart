// lib/main.dart
import 'package:flutter/material.dart';

// ** Importar otras paginas .dart (links)
import 'navbar.dart';
import 'debug.dart';
import 'map.dart';

// ** Configuraciones
// De interfaz:
const interfaceColor = Color.fromARGB(255, 102, 102, 255); // Default interfaceColor.fromARGB(255, 102, 102, 255)
const textOptionColor = Color.fromARGB(255, 102, 102, 255); // Default textOptionColor.fromARGB(255, 102, 102, 255)

// Variables: (Estaticas por el moment)
const nombre = "Alonso";
const apellido = "Iturrianda";

const rol = "Guardia en la isla Epstein";
const local = "Unimarc";

var profileDefaultImage = const NetworkImage("https://i.pinimg.com/474x/c6/a9/a1/c6a9a1c3ec3b086dda8de521ffc46f61.jpg"); // Img si no se encuentra la real
var profileImage = const AssetImage('assets/profile_pic.jpg');



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
      body: SingleChildScrollView( 
        child: Center( 
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => debug()));
              }, // Por el mometn no hace nada el boton
              style: ElevatedButton.styleFrom(backgroundColor: interfaceColor, foregroundColor: Colors.white,),
              child: const Text("Aca va el Perfil pero lo uso cmo debug por mientras")), 

            const SizedBox(height: 100), // Espacio entre el texto y los botones inferiores
            Container( // Container con las opciones
              color: interfaceColor,
              child: 
              Center( 
                child: 
                  Padding(padding: const EdgeInsets.all(16),
                    child: 
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: 
                                ElevatedButton(  // Sin pagina aun
                                  onPressed: () {},
                                  child: const Text("Ver reportes", style: TextStyle(color: textOptionColor),)),
                            ),
                          ),
                          Expanded( // Sin pagina aun
                            child: Center(
                              child: 
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("+", style: TextStyle(color: textOptionColor),)),
                            ),
                          ),

                          Expanded(
                            child: Center(
                              child: 
                                ElevatedButton(  // Pagina del mapa
                                  onPressed: () {
                                    // Navegar a map_1.dart
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => map()),
                                    );
                                },      
                                child: const Text("Ver mapa", style: TextStyle(color: textOptionColor))
                                )
                            )
                          )
                        ]
                      )
                  ),
              ),
            )
          ]),
      )));
  }
}
