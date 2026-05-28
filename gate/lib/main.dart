// lib/main.dart
import 'package:flutter/material.dart';
import 'package:gate/pages/login.dart';

// ** Importar otras paginas .dart (links)
import 'config.dart';

// Variables: (Estaticas por el moment)

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
        body: Center(
          child: Column(children: [
            const SizedBox(height: 50),
            Image.asset(
              'assets/gate_logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/LEGO_logo.svg/1280px-LEGO_logo.svg.png',
                  height: 60,
                  width: 120,
                  fit: BoxFit.contain,
                );
              },
            ),
            const SizedBox(height: 40),
            const Text("Bienvenido a GATE", style: titleTextStyle),
            const SizedBox(
              height: 50,
            ),
            FilledButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              style: FilledButton.styleFrom(backgroundColor: buttonColor, padding: EdgeInsets.all(16)),
              child: const Text("Iniciar Sesion", style: TextStyle(fontSize: 20),)
            ), 
          ]),
        ));
  }
}
