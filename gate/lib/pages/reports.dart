import 'package:flutter/material.dart';
import 'package:gate/pages/map.dart';

import '../config.dart';
import '../custom_widgets/option_menu.dart';
import '../custom_widgets/navbar.dart';

int viewReports = 5;

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: 
        Center(
          child: Column(
            children: [    
              Expanded(child: SingleChildScrollView(
                child: 
                  Column(children: [
                    Center(
                      child: Text("Reportes recientes",style: titleTextStyle)),
                          
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column( children: [
                          FilledButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => map()),
                              );
                            }, 
                            style: FilledButton.styleFrom(backgroundColor: buttonColor, padding: EdgeInsets.all(16)),
                             child: Text("Ver mapa"),),
                          SizedBox(height: 20),

                          for (int i = 1; i< viewReports+1 ; i++) // REPORTES
                            Container(decoration: BoxDecoration(border: Border.all(color: Colors.black) ), child: 
                              Padding(padding: EdgeInsets.all(8.0), 
                                child: Row(children: [
                                  Expanded(
                                    child: 
                                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text("ID del reporte: $i", style: TextStyle(fontWeight: FontWeight.bold)) ,
                                        Text("Nombre del bandido: Martin WEKO"),
                                        Text("Ubicacion del atraco: Kawaii Bakery Maid Café, Santiago, Chile.")
                                      ])
                                    ),
                                  //Expanded(child: Text(" ")), // Para tirar la imagen a la derecha
                                  Image.asset('assets/profile_pic.jpg',height: 100, width: 100,
                                    fit: BoxFit.cover,),
                                ])
                            ))
                        ],
                      ),)
                ])
              )
            ),

            //const Expanded(child: Text(" ")),
            const OptionContainer()
            ],
          ),
        )
    );
  }
}
