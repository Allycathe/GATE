// lib/debug.dart
import 'package:flutter/material.dart';
import 'login.dart';

class debug extends StatelessWidget {
  const debug({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GATE")),
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
            const Text("Toi dudando si hay q hacer registro"),
            ElevatedButton(onPressed: () {}, child: const Text("Ver Registro")),
            ElevatedButton(onPressed: () {}, child: const Text("Ver Algo")),
          ],
        ),
      ),
    );
  }
}
