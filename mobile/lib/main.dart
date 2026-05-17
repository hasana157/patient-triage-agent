import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const TriageDemoApp());
}

class TriageDemoApp extends StatelessWidget {
  const TriageDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriageFlow Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final TextEditingController _complaintController = TextEditingController(text: "chest pain");
  
  bool _isLoading = false;
  String _triageResult = "";
  String _actionPlan = "";
  String _error = "";

  Future<void> runDemo() async {
    setState(() {
      _isLoading = true;
      _triageResult = "";
      _actionPlan = "";
      _error = "";
    });

    try {
      final caseData = {
        "case_id": "DEMO-CASE",
        "patient_code": "PT-999",
        "age": 45,
        "sex": "male",
        "pregnant": false,
        "chief_complaint": _complaintController.text,
        "symptoms": ["chest_pain"],
        "duration_minutes": 30,
        "pain_score": 8,
        "vitals": {
          "heart_rate": 110,
          "systolic_bp": 90,
          "diastolic_bp": 60,
          "respiratory_rate": 22,
          "spo2": 92,
          "temperature_c": 37.0,
          "consciousness": "alert"
        },
        "nurse_note": "Patient looks pale.",
        "arrival_time": DateTime.now().toIso8601String(),
        "current_wait_minutes": 10
      };

      // 1. Evaluate Triage
      final triageRes = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/triage/evaluate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(caseData),
      );

      if (triageRes.statusCode != 200) throw Exception("Triage evaluation failed: ${triageRes.body}");
      final triageData = json.decode(triageRes.body);
      
      setState(() {
        _triageResult = "Priority: ${triageData['priority_level']}\n"
                        "Risk Score: ${triageData['risk_score']}\n"
                        "Reasoning: ${triageData['reasoning']?.join(', ')}";
      });

      // 2. Plan Actions
      final actionRes = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/actions/plan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(triageData),
      );

      if (actionRes.statusCode != 200) throw Exception("Action planning failed: ${actionRes.body}");
      final actionData = json.decode(actionRes.body) as List;
      
      setState(() {
        _actionPlan = actionData.map((a) => "- ${a['title']} (${a['action_type']})").join("\n");
      });

    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minimal Triage Demo (Phase 6A)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _complaintController,
              decoration: const InputDecoration(labelText: 'Chief Complaint'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : runDemo,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Run Triage & Plan Actions'),
            ),
            const SizedBox(height: 24),
            if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red)),
            if (_triageResult.isNotEmpty) ...[
              const Text("Triage Result", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[800],
                child: Text(_triageResult),
              ),
              const SizedBox(height: 16),
            ],
            if (_actionPlan.isNotEmpty) ...[
              const Text("Action Plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[800],
                child: Text(_actionPlan),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
