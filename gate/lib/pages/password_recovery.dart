import 'package:flutter/material.dart';
import '../custom_widgets/navbar.dart';


class PwRecoveryPage extends StatelessWidget {
  const PwRecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: 
        Center(
          child: Column(
            children: [
              Text("Hola amucos"),
              
            ],
          ),
        )
    );
  }
}
