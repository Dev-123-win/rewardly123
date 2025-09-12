import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:rewardly_app/screens/auth/authenticate.dart';
import 'package:rewardly_app/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // return either Home or Authenticate widget
    if (user == null) {
      return const Authenticate();
    } else {
      return const Home();
    }
  }
}
