import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Health Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const HealthMonitorPage(),
    );
  }
}

class HealthMonitorPage extends StatefulWidget {
  const HealthMonitorPage({super.key});

  @override
  State<HealthMonitorPage> createState() => _HealthMonitorPageState();
}

class _HealthMonitorPageState extends State<HealthMonitorPage> {
  bool isLoading = true;
  bool isHealthy = false;
  String statusMessage = "Checking API health...";
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    checkApiHealth();
    // Set up a timer to check the API health every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      checkApiHealth();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> checkApiHealth() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:8080/health'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isLoading = false;
          isHealthy = data['status'] == 'ok';
          statusMessage = isHealthy ? "API is healthy" : "API is not healthy";
        });
      } else {
        setState(() {
          isLoading = false;
          isHealthy = false;
          statusMessage = "Error: API returned status code ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isHealthy = false;
        statusMessage = "Error: Could not connect to API";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Health Monitor'),
        backgroundColor: Colors.green.shade100,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'API Health Status',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildHealthStatusCard(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: checkApiHealth,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isLoading
          ? Colors.grey.shade100
          : isHealthy
              ? Colors.green.shade50
              : Colors.red.shade50,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isLoading
                  ? Icons.hourglass_empty
                  : isHealthy
                      ? Icons.check_circle
                      : Icons.error,
              size: 80,
              color: isLoading
                  ? Colors.grey
                  : isHealthy
                      ? Colors.green
                      : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              statusMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isLoading
                    ? Colors.grey.shade700
                    : isHealthy
                        ? Colors.green.shade700
                        : Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            if (isHealthy && !isLoading) ...[  
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'status: ok',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
