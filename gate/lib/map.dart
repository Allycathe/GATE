// lib/map_1.dart
import 'package:flutter/material.dart';
import 'mapa_screen.dart';

class map extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GATE")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PantallaMapa()),
            );
          },
          child: const Text("Ver mapa"),
        ),
      ),
    );
  }
}