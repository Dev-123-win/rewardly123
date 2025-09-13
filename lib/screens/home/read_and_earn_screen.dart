import 'package:flutter/material.dart';

class ReadAndEarnScreen extends StatelessWidget {
  const ReadAndEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read & Earn'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Read & Earn content will go here!'),
      ),
    );
  }
}
