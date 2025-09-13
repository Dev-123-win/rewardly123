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
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline), // Primary color
                                ),
                              ),
                              const SizedBox(height: 10.0), // Adjusted spacing
                              TextButton(
                                onPressed: () {
                                  widget.toggleView();
                                },
                                child: Text(
                                  'Don\'t have an account? Register now',
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

class AuthScreenLoading extends StatelessWidget {
  const AuthScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Solid white background
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(20.0),
            color: Colors.grey[100], // Light grey background for loading card
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
