import 'package:flutter/material.dart';
import 'package:rewardly_app/auth_service.dart';
import 'package:rewardly_app/shared/shimmer_loading.dart';
import 'package:rewardly_app/widgets/custom_button.dart';
import 'package:rewardly_app/screens/auth/auth_card.dart';
import 'package:rewardly_app/screens/auth/forgot_password.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  const SignIn({super.key, required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? const AuthScreenLoading()
        : Scaffold(
            backgroundColor: Colors.black, // Dark background
            body: Container(
              decoration: const BoxDecoration(
                // Subtle geometric pattern or solid dark background
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
                                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                                onChanged: (val) {
                                  setState(() => email = val);
                                },
                              ),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: TextStyle(color: Colors.white54),
                                  prefixIcon: Icon(Icons.lock, color: Colors.white70),
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
                                obscureText: true,
                                validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                                onChanged: (val) {
                                  setState(() => password = val);
                                },
                              ),
                              const SizedBox(height: 30.0), // Adjusted spacing
                              CustomButton(
                                text: 'Login', // Dynamic text
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => loading = true);
                                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ForgotPassword()),
                                  );
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                                ),
                              ),
                              const SizedBox(height: 10.0), // Adjusted spacing
                              TextButton(
                                onPressed: () {
                                  widget.toggleView();
                                },
                                child: const Text(
                                  'Don\'t have an account? Register now',
                                  style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
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

class AuthScreenLoading extends StatelessWidget {
  const AuthScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(20.0),
            color: Colors.black.withOpacity(0.4),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ShimmerLoading.rectangular(height: 100, width: 100),
                  const SizedBox(height: 20.0),
                  const ShimmerLoading.rectangular(height: 20, width: 250),
                  const SizedBox(height: 40.0),
                  const ShimmerLoading.rectangular(height: 50),
                  const SizedBox(height: 20.0),
                  const ShimmerLoading.rectangular(height: 50),
                  const SizedBox(height: 30.0),
                  const ShimmerLoading.rectangular(height: 50),
                  const SizedBox(height: 20.0),
                  const ShimmerLoading.rectangular(height: 20, width: 150),
                  const SizedBox(height: 10.0),
                  const ShimmerLoading.rectangular(height: 20, width: 200),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
