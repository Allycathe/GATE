import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gate/pages/encargado.dart';
import 'package:gate/services/api_client.dart';
import '../config.dart';
import '../custom_widgets/option_menu.dart';
import '../custom_widgets/navbar.dart';
import 'user_options.dart';

String _nombreSupermarket = '';

String definirRol(bool isAdmin) => isAdmin ? 'Encargado' : 'Guardia';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _initFCM();
    _loadSupermarketName();
  }

  Future<void> _initFCM() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final token = await messaging.getToken();
    if (token != null) await _saveFcmToken(token);
    messaging.onTokenRefresh.listen(_saveFcmToken);
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? 'Alerta';
      final body = message.notification?.body ?? '';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title: $body'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }

  Future<void> _loadSupermarketName() async {
    try {
      final response = await ApiClient.get('/supermercados/$userSupermarketId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _nombreSupermarket = data['supermercado']['name'] ?? 'Sin nombre';
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _saveFcmToken(String token) async {
    try {
      await ApiClient.put('/usuarios/$userId/fcm-token', {'fcm_token': token});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final rol = definirRol(userIsAdmin);
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            CircleAvatar(
              radius: 100,
              child: ClipOval(
                child: Image.asset(
                  'assets/profile_pic.jpg',
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: 200,
                      color: interfaceColor,
                      child: Center(
                        child: Text(
                          '${userName.isNotEmpty ? userName[0] : '?'}${userLastName.isNotEmpty ? userLastName[0] : ''}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text('$userName $userLastName',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            Text('ID de usuario: $userId',
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 30),
            Text('Rol: $rol', style: const TextStyle(fontSize: 20)),
            Text('Local: $_nombreSupermarket',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const UserOptions())),
              style: FilledButton.styleFrom(
                  backgroundColor: buttonColor, padding: const EdgeInsets.all(16)),
              child: const Text('Opciones'),
            ),
            const SizedBox(height: 20),
            if (userIsAdmin)
              FilledButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminPage())),
                style: FilledButton.styleFrom(
                    backgroundColor: adminInterfaceColor,
                    padding: const EdgeInsets.all(16)),
                child: const Text('Opciones de administrador',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            const Expanded(child: Text(' ')),
            const OptionContainer(),
          ],
        ),
      ),
    );
  }
}
