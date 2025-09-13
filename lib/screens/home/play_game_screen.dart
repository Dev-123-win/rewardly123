import 'package:flutter/material.dart';

class PlayGameScreen extends StatelessWidget {
  const PlayGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Game!'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Play Game content will go here!'),
      ),
    );
  }
}
