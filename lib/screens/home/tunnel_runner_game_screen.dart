import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:rewardly_app/user_service.dart';
import 'package:rewardly_app/ad_service.dart'; // Consolidated AdService
import 'package:rewardly_app/remote_config_service.dart';
import 'package:rewardly_app/shared/shimmer_loading.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:convert';
import 'dart:developer';

class TunnelRunnerGameScreen extends StatefulWidget {
  const TunnelRunnerGameScreen({super.key});

  @override
  State<TunnelRunnerGameScreen> createState() => _TunnelRunnerGameScreenState();
}

class _TunnelRunnerGameScreenState extends State<TunnelRunnerGameScreen> {
  late final WebViewController _controller;
  final UserService _userService = UserService();
  final AdService _adService = AdService();
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  User? _currentUser;
  bool _isLoading = true;
  int _currentCoinsInRun = 0;
  int _currentDistance = 0;
  int _bestDistance = 0;
  int _maxBonusCoinsPerMilestone = 50;

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _currentUser = Provider.of<User?>(context, listen: false);
    _loadInitialData();
    _loadAds();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (message) {
          _handleJavaScriptMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            log('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            log('Page started loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            log('Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
            _sendInitialGameStateToWeb();
          },
          onWebResourceError: (WebResourceError error) {
            log('''
            Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
            ''');
          },
        ),
      )
      ..loadFlutterAsset('assets/web/tunnel_runner_game.html');
  }

  Future<void> _loadInitialData() async {
    if (_currentUser == null) return;

    await _remoteConfigService.initialize();
    setState(() {
      _maxBonusCoinsPerMilestone = _remoteConfigService.maxBonusCoinsPerMilestone;
    });

    final userData = Provider.of<UserDataProvider>(context, listen: false).userData;
    if (userData != null && userData.data() != null) {
      final data = userData.data() as Map<String, dynamic>;
      _bestDistance = data['tunnelRunnerBestDistance'] ?? 0;
    }
  }

  void _loadAds() {
    _adService.loadRewardedAd();
    _adService.loadInterstitialAd();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
          log('BannerAd loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          log('BannerAd failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _adService.dispose();
    super.dispose();
  }

  void _sendInitialGameStateToWeb() {
    _controller.runJavaScript('''
      if (window.setInitialGameState) {
        window.setInitialGameState(${jsonEncode(_bestDistance)});
      }
    ''');
  }

  void _handleJavaScriptMessage(String message) {
    final Map<String, dynamic> data = jsonDecode(message);
    final String type = data['type'];

    switch (type) {
      case 'collectCoin':
        final int amount = data['amount'];
        _handleCollectCoin(amount);
        break;
      case 'milestoneReached':
        final int distance = data['distance'];
        _handleMilestoneReached(distance);
        break;
      case 'gameOver':
        final int distance = data['distance'];
        final int coins = data['coins'];
        _handleGameOver(distance, coins);
        break;
      case 'requestAd':
        final String adType = data['adType'];
        _handleAdRequest(adType);
        break;
      case 'gameStarted':
        setState(() {
          _currentCoinsInRun = 0;
          _currentDistance = 0;
        });
        break;
      case 'updateHud':
        setState(() {
          _currentCoinsInRun = data['coins'];
          _currentDistance = data['distance'];
        });
        break;
    }
  }

  Future<void> _handleCollectCoin(int amount) async {
    if (_currentUser == null) return;
    await _userService.updateCoins(_currentUser!.uid, amount);
  }

  Future<void> _handleMilestoneReached(int distance) async {
    if (_currentUser == null) return;
    final int bonus = (distance ~/ 100).clamp(0, _maxBonusCoinsPerMilestone);
    if (bonus > 0) {
      await _userService.updateCoins(_currentUser!.uid, bonus);
      _controller.runJavaScript('window.showGameMessage("Bonus: +$bonus coins!");');
    }
  }

  Future<void> _handleGameOver(int distance, int coins) async {
    if (_currentUser == null) return;

    if (distance > _bestDistance) {
      _bestDistance = distance;
      await _userService.updateUserData(_currentUser!.uid, {'tunnelRunnerBestDistance': _bestDistance});
    }
  }

  void _handleAdRequest(String adType) {
    if (_currentUser == null) {
      _sendAdResultToWeb(false, adType, 0);
      return;
    }

    if (adType == 'revive' || adType == 'bonus') {
      _adService.showRewardedAd(
        onRewardEarned: (int rewardAmount) async {
          final int actualReward = adType == 'revive' ? 20 : 50;
          await _userService.updateCoins(_currentUser!.uid, actualReward);
          _sendAdResultToWeb(true, adType, actualReward);
        },
        onAdFailedToLoad: () {
          _sendAdResultToWeb(false, adType, 0);
        },
        onAdFailedToShow: () {
          _sendAdResultToWeb(false, adType, 0);
        },
      );
    } else if (adType == 'interstitial') {
      _adService.showInterstitialAd(
        onAdDismissed: () {
          _sendAdResultToWeb(true, adType, 0);
        },
        onAdFailedToShow: () {
          _sendAdResultToWeb(false, adType, 0);
        },
      );
    }
  }

  void _sendAdResultToWeb(bool success, String adType, int rewardAmount) {
    _controller.runJavaScript('''
      if (window.handleAdResult) {
        window.handleAdResult(${jsonEncode(success)}, ${jsonEncode(adType)}, ${jsonEncode(rewardAmount)});
      }
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tunnel Runner'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: ShimmerLoading.rectangular(height: 50, width: 200),
            ),
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.black.withAlpha((0.5 * 255).round()),
              child: Text(
                'Distance: $_currentDistance m | Coins: $_currentCoinsInRun',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (_isBannerAdLoaded && _bannerAd != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}
