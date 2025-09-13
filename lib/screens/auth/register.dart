import 'package:flutter/material.dart';
import 'package:rewardly_app/auth_service.dart';
import 'package:rewardly_app/screens/auth/sign_in.dart';
import 'package:rewardly_app/widgets/custom_button.dart';
import 'package:rewardly_app/screens/auth/auth_card.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  const Register({super.key, required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String referralCode = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? const AuthScreenLoading()
        : Scaffold(
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
                                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                                onChanged: (val) {
                                  setState(() => email = val);
                                },
                              ),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(color: Colors.grey[600]), // Lighter hint text
                                  prefixIcon: Icon(Icons.lock, color: Colors.grey[700]), // Darker icon
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
                                obscureText: true,
                                validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                                onChanged: (val) {
                                  setState(() => password = val);
                                },
                              ),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Referral Code (Optional)',
                                  hintStyle: TextStyle(color: Colors.grey[600]), // Lighter hint text
                                  prefixIcon: Icon(Icons.person_add, color: Colors.grey[700]), // Darker icon
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
                                onChanged: (val) {
                                  setState(() => referralCode = val);
                                },
                              ),
                              const SizedBox(height: 30.0), // Adjusted spacing
                              CustomButton(
                                text: 'Register', // Dynamic text
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => loading = true);
                                    dynamic result = await _auth.registerWithEmailAndPassword(email, password, referralCode: referralCode.isEmpty ? null : referralCode);
                                    if (result is String) {
                                      if (mounted) {
                                        setState(() {
                                          loading = false;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(result),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                              const SizedBox(height: 20.0), // Adjusted spacing
                              TextButton(
                                onPressed: () {
                                  widget.toggleView();
                                },
                                child: Text(
                                  'Already have an account? Login now',
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
