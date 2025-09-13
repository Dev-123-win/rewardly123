import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/shared/shimmer_loading.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:rewardly_app/providers/user_data_provider.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (user == null || userDataProvider.userData == null) {
      return const _ReferralScreenLoading();
    }

    Map<String, dynamic> userData = userDataProvider.userData!.data() as Map<String, dynamic>;
    String referralCode = userData['referralCode'] ?? 'N/A';

    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Your Referral Code:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  referralCode,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrange[700]),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.copy, color: Colors.white),
                label: const Text('Copy Code', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: referralCode));
                  _showSnackBar(context, 'Referral code copied to clipboard!');
                },
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Share this code with your friends! When they register using your code, both of you will earn bonus coins!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferralScreenLoading extends StatelessWidget {
  const _ReferralScreenLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const ShimmerLoading.rectangular(height: 24, width: 200),
              const SizedBox(height: 20),
              const ShimmerLoading.rectangular(height: 50, width: 250),
              const SizedBox(height: 30),
              const ShimmerLoading.rectangular(height: 50, width: 150),
              const SizedBox(height: 20),
              const ShimmerLoading.rectangular(height: 16, width: 300),
              const SizedBox(height: 10),
              const ShimmerLoading.rectangular(height: 16, width: 250),
            ],
          ),
        ),
      ),
    );
  }
}
