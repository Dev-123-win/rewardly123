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
      backgroundColor: Colors.white, // White background
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Solid white background
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
                  style: TextStyle(fontSize: 16, color: Colors.black87), // Darker text for readability
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
                            hintStyle: TextStyle(color: Colors.grey[600]), // Lighter hint text
                            prefixIcon: Icon(Icons.email, color: Colors.grey[700]), // Darker icon
                            filled: true,
                            fillColor: Colors.grey[100], // Light fill color
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0), // Light border
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0), // Primary color border
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          style: const TextStyle(color: Colors.black87), // Dark text
                          validator: (val) => val!.isEmpty ? 'Enter your email' : null,
                          onChanged: (val) {
                            setState(() => email = val);
                          },
                        ),
                        const SizedBox(height: 30.0), // Adjusted spacing
                        loading
                            ? CircularProgressIndicator(color: Theme.of(context).primaryColor) // Use primary color for consistency
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
                          child: Text(
                            'Back to Sign In',
                            style: TextStyle(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline), // Primary color
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
