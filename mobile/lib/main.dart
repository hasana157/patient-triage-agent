import 'package:flutter/material.dart';

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
      home: Scaffold(
        appBar: AppBar(title: const Text('TriageFlow AI - Phase 0')),
        body: const Center(
          child: Text('Awaiting Phase 2 implementation...'),
        ),
      ),
    );
  }
}
