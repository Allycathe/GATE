//import 'dart:ffi';

import 'package:flutter/material.dart';

// Configuracion de backend

class AppConfig {
  static const String baseUrl = 'https://gate.blade.dedyn.io';

  static const String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NiwiZW1haWwiOiJhZG1pbkBnYXRlLmNvbSIsImlhdCI6MTc3ODcxMjgzMiwiZXhwIjoxNzc4NzQxNjMyfQ.Qvs-Jigaf0ti1eXhChokmBiVeRP-0JddSHBivNHHqJE';
}
String baseUrl = 'https://gate.blade.dedyn.io';
String userToken = "";
int userId = 0;
int userSupermarketId = 0;
String userEmail = "";
String userName = "";
String userLastName = "";
bool userIsAdmin = false;


// Configuraciones de interfaz

// Default interfaceColor.fromARGB(255, 102, 102, 255)
// Default textOptionColor.fromARGB(255, 102, 102, 255)


const titleTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 40);
const navbarColor = Color.fromARGB(255, 255, 255, 255);
const interfaceColor = Color.fromARGB(255, 255, 48, 58);
const textOptionColor = Color.fromARGB(255, 255, 57, 57);

// Para filled buttons -> los elevated buttons solo cambiar segun el color de interfaz
const buttonColor = Color.fromARGB(255, 0, 0, 0);
