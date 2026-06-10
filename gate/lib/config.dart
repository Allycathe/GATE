//import 'dart:ffi';

import 'package:flutter/material.dart';

// Configuracion de backend

class AppConfig {
  static const String baseUrl = 'https://gate.blade.dedyn.io';

  static const String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NiwiZW1haWwiOiJhZG1pbkBnYXRlLmNvbSIsImlhdCI6MTc3ODcxMjgzMiwiZXhwIjoxNzc4NzQxNjMyfQ.Qvs-Jigaf0ti1eXhChokmBiVeRP-0JddSHBivNHHqJE';
}

String baseUrl = 'https://gate.blade.dedyn.io';
String userToken = AppConfig.token;
int userId = 0;
int userSupermarketId = 0;
String userEmail = "";
String userName = "";
String userLastName = "";
bool userIsAdmin = false;

// ignore: non_constant_identifier_names
bool NOTIFICATIONS = true;

// Configuraciones de interfaz

// Default interfaceColor.fromARGB(255, 102, 102, 255)
// Default textOptionColor.fromARGB(255, 102, 102, 255)

const titleTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 35);
const subTitleTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
const navbarColor = Color.fromARGB(255, 255, 255, 255);

const interfaceColor = Color.fromARGB(255, 35, 89, 240);
const textOptionColor = Color.fromARGB(255, 35, 89, 240);

const adminInterfaceColor = Color.fromARGB(255, 251, 255, 22);

// Para filled buttons -> los elevated buttons solo cambiar segun el color de interfaz
const buttonColor = Color.fromARGB(255, 0, 0, 0);

const blackBorderedText = TextStyle(color: Colors.white,
    shadows: [
      Shadow(offset: Offset(-1.5, -1.5), color: Colors.black),
      Shadow(offset: Offset(1.5, -1.5), color: Colors.black),
      Shadow(offset: Offset(1.5, 1.5), color: Colors.black),
      Shadow(offset: Offset(-1.5, 1.5), color: Colors.black),
    ]
);