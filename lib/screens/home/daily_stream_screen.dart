import 'package:flutter/material.dart';

class DailyStreamScreen extends StatelessWidget {
  const DailyStreamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Stream'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Daily Stream content will go here!'),
      ),
    );
  }
}
