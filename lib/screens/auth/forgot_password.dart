import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/widgets/custom_button.dart';
import 'package:rewardly_app/screens/auth/auth_card.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String error = '';
  bool loading = false;

  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A), // Dark grey
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/AppLogo.png', height: 100), // App Logo
                const SizedBox(height: 20),
                const Text(
                  'Earn Smarter. Play. Win. Cashout.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                AuthCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.white54),
                            prefixIcon: Icon(Icons.email, color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.0),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.pinkAccent, width: 2.0), // Glowing underline
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (val) => val!.isEmpty ? 'Enter your email' : null,
                          onChanged: (val) {
                            setState(() => email = val);
                          },
                        ),
                        const SizedBox(height: 30.0), // Adjusted spacing
                        loading
                            ? const CircularProgressIndicator(color: Colors.pinkAccent) // Use pinkAccent for consistency
                            : CustomButton(
                                text: 'Send Reset Link', // Dynamic text
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => loading = true);
                                    try {
                                      await _auth.sendPasswordResetEmail(email: email);
                                      if (mounted) {
                                        _showSnackBar('Password reset link sent to $email');
                                        Navigator.pop(context); // Go back to sign in screen
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      if (mounted) {
                                        setState(() {
                                          error = e.message ?? 'An unknown error occurred.';
                                          loading = false;
                                        });
                                        _showSnackBar(error, backgroundColor: Colors.red);
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        setState(() {
                                          error = 'An unexpected error occurred.';
                                          loading = false;
                                        });
                                        _showSnackBar(error, backgroundColor: Colors.red);
                                      }
                                    }
                                  }
                                },
                              ),
                        const SizedBox(height: 20.0), // Adjusted spacing
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Go back to sign in screen
                          },
                          child: const Text(
                            'Back to Sign In',
                            style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
