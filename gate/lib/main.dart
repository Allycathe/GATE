// lib/main.dart
import 'package:flutter/material.dart';

// Importar otras paginas .dart (links)
import 'map.dart';

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
      appBar: AppBar(title: const Text("Main Menu", 
        style: TextStyle(color: Color.fromARGB(255, 255, 255, 255),
        fontWeight: FontWeight.bold,
        )), centerTitle: true, backgroundColor: Color.fromARGB(255, 102, 102, 255),
        ),
      body: SingleChildScrollView( 
        child: Center( 
          child: Column(
            children: [
            SizedBox(height: 50),

            CircleAvatar(  // Foto de example
              radius: 100,
              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/a/ACg8ocI38hDyy-QdzuarH5iQSAtcqH0ufiGoyvUjel1d4EDrdNNsdAB1=s432-c-no'),
            ),
            Text("Foto"),

            SizedBox(height: 40),
            Text("Alonso Iturra", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,)),
            SizedBox(height: 30),
            Text("Rol: Ingeniero en ciberacoso", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Local: Unimarc", style: TextStyle(fontSize: 20),),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {},
              child: Text("Perfil"), 
              style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 102, 102, 255), foregroundColor: Colors.white,)), // Por el mometn no hace nada el boton

            SizedBox(height: 200), // Espacio entre el texto y el boton
            Container( // Container con las opciones
              color: Color.fromARGB(255, 102, 102, 255),
              child: 
              Center( 
                child: 
                  Padding(padding: EdgeInsets.all(16),
                    child: 
                      Row(
                        children: [
                          Expanded(child: Container(
                            child: Center(
                              child: ElevatedButton(  // Sin pagina aun
                                onPressed: () {},
                                child: Text("Ver reportes")),
                            ),
                          )),
                          Expanded(child: Container(  // Sin pagina aun
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text("+")),
                            ),
                          )),

                          Expanded(child: Container(
                            child: Center(
                              child: ElevatedButton(  // Pagina del mapa
                                onPressed: () {
                                  // Navegar a map_1.dart
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => map()),
                                  );
                              },      
                              child: Text('Ver mapa'),
                              )
                            ),
                          )),
                        ],
                      )
                  ),
              ),
            )
          ]),
      )));
  }
}
