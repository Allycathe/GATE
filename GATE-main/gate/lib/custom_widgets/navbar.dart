import 'package:flutter/material.dart';
import '../config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Image.asset(
        'assets/gate_logo.png',
        width: 120,
        height: 55,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/LEGO_logo.svg/1280px-LEGO_logo.svg.png',
            height: 40,
            width: 120,
            fit: BoxFit.contain,
          );
        },
      ),
      centerTitle: true,
      backgroundColor:
          const Color(0xFFEDE7F6), // <-- mismo color que el Scaffold
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
