// lib/debug.dart
import 'package:flutter/material.dart';

import '../config.dart';
import '../custom_widgets/navbar.dart';


class plantillaPage extends StatelessWidget {
  const plantillaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: 
        Center(
          child: Column(
            children: [
              Text("Reportes recientes"),
              
            ],
          ),
        )
    );
  }
}
