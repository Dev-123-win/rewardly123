import 'package:flutter/material.dart';

class AquaBlastScreen extends StatelessWidget {
  const AquaBlastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aqua Blast'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Aqua Blast content will go here!'),
      ),
    );
  }
}
