import 'package:flutter/material.dart';

import '../config.dart';
import '../pages/map.dart';

class OptionContainer extends StatelessWidget {

  const OptionContainer({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      color: interfaceColor,
              child: 
              Center( 
                child: 
                  Padding(padding: const EdgeInsets.all(16),
                    child: 
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: 
                                ElevatedButton(  // Sin pagina aun
                                  onPressed: () {},
                                  child: const Text("Ver reportes", style: TextStyle(color: textOptionColor),)),
                            ),
                          ),
                          Expanded( // Sin pagina aun
                            child: Center(
                              child: 
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("+", style: TextStyle(color: textOptionColor),)),
                            ),
                          ),

                          Expanded(
                            child: Center(
                              child: 
                                ElevatedButton(  // Pagina del mapa
                                  onPressed: () {
                                    // Navegar a map_1.dart
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => map()),
                                    );
                                },      
                                child: const Text("Ver mapa", style: TextStyle(color: textOptionColor))
                                )
                            )
                          )
                        ]
                      )
                  ),
              ),
    );
  }
}