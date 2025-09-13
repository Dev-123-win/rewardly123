import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/shared/shimmer_loading.dart';
import 'package:rewardly_app/auth_service.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';
import 'package:rewardly_app/widgets/custom_button.dart';
import 'package:rewardly_app/screens/home/admin_panel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final AuthService authService = AuthService();
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (user == null || userDataProvider.userData == null) {
      return const _ProfileScreenLoading();
    }

    Map<String, dynamic> userData = userDataProvider.userData!.data() as Map<String, dynamic>;
    String email = userData['email'] ?? 'N/A';
    int coins = userData['coins'] ?? 0;
    String referralCode = userData['referralCode'] ?? 'N/A';

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.cyan],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Email: $email',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Text(
                'Coins: $coins',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'Referral Code: $referralCode',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              if (userData['isAdmin'] ?? false) // Show Admin Panel button only if user is admin
                Column(
                  children: [
                    CustomButton(
                      text: 'Admin Panel',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminPanel()),
                        );
                      },
                      startColor: Colors.deepOrange,
                      endColor: Colors.red,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              CustomButton(
                text: 'Logout',
                onPressed: () async {
                  await authService.signOut();
                },
                startColor: Colors.redAccent,
                endColor: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileScreenLoading extends StatelessWidget {
  const _ProfileScreenLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.cyan],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const ShimmerLoading.circular(width: 120, height: 120),
              const SizedBox(height: 30),
              const ShimmerLoading.rectangular(height: 16, width: 200),
              const SizedBox(height: 20),
              const ShimmerLoading.rectangular(height: 28, width: 150),
              const SizedBox(height: 20),
              const ShimmerLoading.rectangular(height: 16, width: 200),
              const SizedBox(height: 40),
              ShimmerLoading.rectangular(height: 50, width: double.infinity),
            ],
          ),
        ),
      ),
    );
  }
}
