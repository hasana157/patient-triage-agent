import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/patient_intake_screen.dart';

void main() {
  runApp(const TriageFlowApp());
}

class TriageFlowApp extends StatelessWidget {
  const TriageFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriageFlow AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      // Named routes for dataless screens only.
      // Data-carrying screens (TriageResultScreen, ActionChainScreen,
      // ExecutionSimulationScreen) use Navigator.push with constructor injection.
      routes: {
        '/home': (_) => const HomeScreen(),
        '/intake': (_) => const PatientIntakeScreen(),
      },
    );
  }
}
