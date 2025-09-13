import 'package:flutter/material.dart';

class OfferProScreen extends StatelessWidget {
  const OfferProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OfferPro'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('OfferPro content will go here!'),
      ),
    );
  }
}
