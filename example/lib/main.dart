import 'package:flutter/material.dart';
import 'package:ux_state_manager/ux_state_manager.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UxStateBuilder Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<List<String>> _fetchItems() async {
    await Future.delayed(const Duration(seconds: 1));
    return ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UxStateBuilder Demo')),
      body: UxStateBuilder<List<String>>(
        request: _fetchItems,
        retryStrategy: const RetryStrategy(maxRetries: 2, delay: Duration(seconds: 1)),
        builder: (context, items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(items[i]),
          ),
        ),
      ),
    );
  }
}
