// lib/debug.dart
import 'package:flutter/material.dart';

import '../custom_widgets/navbar.dart';
import '../config.dart';


class MisReportes extends StatelessWidget {
  const MisReportes({super.key});

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
