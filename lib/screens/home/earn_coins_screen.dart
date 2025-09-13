import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/ad_service.dart';
import 'package:rewardly_app/remote_config_service.dart';
import 'package:rewardly_app/widgets/custom_button.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';
import 'package:rewardly_app/ad_reward_service.dart';
import 'package:rewardly_app/shared/shimmer_loading.dart';

class EarnCoinsScreen extends StatefulWidget {
  const EarnCoinsScreen({super.key});

  @override
  State<EarnCoinsScreen> createState() => _EarnCoinsScreenState();
}

class _EarnCoinsScreenState extends State<EarnCoinsScreen> {
  final AdService _adService = AdService();
  final RemoteConfigService _remoteConfigService = RemoteConfigService();
  final AdRewardService _adRewardService = AdRewardService();

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
      await _adRewardService.rewardUserForAd(
        uid: user.uid,
        coinsPerAd: _coinsPerAd,
      );
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
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (user == null || userDataProvider.userData == null) {
      return const _EarnCoinsScreenLoading();
    }

    Map<String, dynamic> userData = userDataProvider.userData!.data() as Map<String, dynamic>;
    _coins = userData['coins'] ?? 0;
    _adsWatchedToday = userData['adsWatchedToday'] ?? 0;
    _dailyAdLimit = _remoteConfigService.dailyAdLimit;
    _coinsPerAd = _remoteConfigService.coinsPerAd;

    return SingleChildScrollView(
      child: Container(
        color: Colors.white, // White background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Coins: $_coins',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor), // Primary color text
              ),
              const SizedBox(height: 10),
              Text(
                'Ads Watched Today: $_adsWatchedToday / $_dailyAdLimit',
                style: const TextStyle(fontSize: 18, color: Colors.black87), // Darker text
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Watch Ad & Earn Coins',
                onPressed: _showRewardedAd,
                startColor: Theme.of(context).primaryColor, // Primary color
                endColor: Color.fromARGB(
                  (((Theme.of(context).primaryColor.value >> 24) & 0xFF) * 0.8).round(),
                  (Theme.of(context).primaryColor.value >> 16) & 0xFF,
                  (Theme.of(context).primaryColor.value >> 8) & 0xFF,
                  Theme.of(context).primaryColor.value & 0xFF,
                ), // Slightly lighter primary color
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EarnCoinsScreenLoading extends StatelessWidget {
  const _EarnCoinsScreenLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white, // White background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const ShimmerLoading.rectangular(height: 30, width: 150),
              const SizedBox(height: 10),
              const ShimmerLoading.rectangular(height: 18, width: 200),
              const SizedBox(height: 40),
              ShimmerLoading.rectangular(height: 50, width: double.infinity),
            ],
          ),
        ),
      ),
    );
  }
}
