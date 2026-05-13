import 'package:flutter/material.dart';
import 'package:gate/pages/new_report.dart';

import 'package:gate/pages/reports.dart';
import 'package:gate/pages/profile.dart';
import '../config.dart';

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
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ReportsPage()),
                                    );
                                  },
                                  child: const Text("Reportes", style: TextStyle(color: textOptionColor),)),
                            ),
                          ),
                          Expanded( // Sin pagina aun
                            child: Center(
                              child: 
                                ElevatedButton(
                                  onPressed:(){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder:(context)=>const NewReport()),);
                                  },
                                  child: const Text("+", style: TextStyle(color: textOptionColor),)),
                            ),
                          ),

                          Expanded(
                            child: Center(
                              child: 
                                ElevatedButton(  // Pagina del mapa
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ProfilePage()),
                                    );
                                },      
                                child: const Text("Perfil", style: TextStyle(color: textOptionColor))
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