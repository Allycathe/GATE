// lib/navbar.dart
import 'package:flutter/material.dart';

// ** Configuraciones
const interfaceColor = Color.fromARGB(255, 255, 255, 255); // Default interfaceColor.fromARGB(255, 102, 102, 255)

// ** Navbar
class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: 
        Image.asset(
          'assets/gate_logo.png', width: 300, height: 400,
          errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/LEGO_logo.svg/1280px-LEGO_logo.svg.png',
                      height: 200, width: 200,
                      fit: BoxFit.contain,
                    );
                  },
        ) , centerTitle: true, backgroundColor: interfaceColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}