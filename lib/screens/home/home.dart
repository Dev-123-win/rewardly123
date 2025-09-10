import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:rewardly_app/auth_service.dart';
import 'package:rewardly_app/ad_service.dart';
import 'package:rewardly_app/remote_config_service.dart';
import 'package:rewardly_app/user_service.dart';
import 'package:rewardly_app/shared/loading.dart';
import 'package:rewardly_app/widgets/custom_button.dart';
import 'package:rewardly_app/screens/home/admin_panel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  final AdService _adService = AdService();
  final UserService _userService = UserService();
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  bool _isAdmin = false;
  int _coins = 0;
  int _adsWatchedToday = 0;
  int _dailyAdLimit = 0;
  int _coinsPerAd = 0;

  @override
  void initState() {
    super.initState();
    _adService.loadRewardedAd();
  }

  void _showRewardedAd() {
    final user = Provider.of<User?>(context, listen: false);
    if (user == null) return;

    if (_adsWatchedToday >= _dailyAdLimit) {
      _showSnackBar('Daily ad limit reached. Try again tomorrow!');
      return;
    }

    _adService.showRewardedAd((ad, reward) async {
      await _userService.updateCoins(user.uid, _coinsPerAd);
      await _userService.updateAdsWatchedToday(user.uid);
      _showSnackBar('You earned $_coinsPerAd coins!');
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const Loading(); // Should not happen if Wrapper is working correctly
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _userService.getUserData(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('User data not found.');
        }

        Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
        _coins = userData['coins'] ?? 0;
        _adsWatchedToday = userData['adsWatchedToday'] ?? 0;
        _isAdmin = userData['isAdmin'] ?? false;
        _dailyAdLimit = _remoteConfigService.dailyAdLimit;
        _coinsPerAd = _remoteConfigService.coinsPerAd;

        return Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: const Text('Rewardly Home', style: TextStyle(color: Colors.white)),
            elevation: 0.0,
            actions: <Widget>[
              if (_isAdmin)
                TextButton.icon(
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                  label: const Text('Admin', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminPanel()),
                    );
                  },
                ),
              TextButton.icon(
                icon: const Icon(Icons.person, color: Colors.white),
                label: const Text('Logout', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  await _auth.signOut();
                },
              )
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Coins: $_coins',
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ads Watched Today: $_adsWatchedToday / $_dailyAdLimit',
                    style: const TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'Watch Ad & Earn Coins',
                    onPressed: _showRewardedAd,
                    startColor: Colors.green,
                    endColor: Colors.lightGreen,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Refer a Friend',
                    onPressed: () {
                      _showSnackBar('Your referral code: ${userData['referralCode']}');
                    },
                    startColor: Colors.orange,
                    endColor: Colors.deepOrange,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
