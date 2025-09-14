import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:rewardly_app/screens/auth/authenticate.dart';
import 'package:rewardly_app/screens/home/home.dart';
import 'package:rewardly_app/widgets/exit_confirmation_overlay.dart'; // Import the new overlay

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  DateTime? _lastPressedAt;
  bool _showExitConfirmation = false;

  Future<bool> _onWillPop() async {
    if (_showExitConfirmation) {
      setState(() {
        _showExitConfirmation = false;
      });
      return false; // Consume the back press to dismiss the overlay
    }

    if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > const Duration(seconds: 2)) {
      _lastPressedAt = DateTime.now();
      setState(() {
        _showExitConfirmation = true;
      });
      return false; // Prevent exit on first press, show overlay
    }
    return true; // Exit on second press within 2 seconds
  }

  void _cancelExit() {
    setState(() {
      _showExitConfirmation = false;
      _lastPressedAt = null; // Reset timer
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    Widget content;
    if (user == null) {
      content = const Authenticate();
    } else {
      content = const Home();
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          content,
          if (_showExitConfirmation)
            ExitConfirmationOverlay(onCancel: _cancelExit),
        ],
      ),
    );
  }
}
