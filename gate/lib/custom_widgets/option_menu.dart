import 'package:flutter/material.dart';
import 'package:gate/pages/new_report.dart';
import 'package:gate/pages/reports.dart';
import 'package:gate/pages/profile.dart';
import '../config.dart';
import '../routes.dart';

class OptionContainer extends StatelessWidget {
  const OptionContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: interfaceColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context, fadeRoute(const ReportsPage())),
                    child: const Text('Reportes',
                        style: TextStyle(color: textOptionColor)),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context, slideUpRoute(const NewReport())),
                    child: const Text('+',
                        style: TextStyle(color: textOptionColor)),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context, fadeRoute(const ProfilePage())),
                    child: const Text('Perfil',
                        style: TextStyle(color: textOptionColor)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
