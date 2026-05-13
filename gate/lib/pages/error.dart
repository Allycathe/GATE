import 'package:flutter/material.dart';

import '/custom_widgets/navbar.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: 
        Expanded(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 40,),
                Text("Error al cargar la información", style: TextStyle(fontSize: 20),),
                
              ],
            )
          )
        )
    );
  }
}