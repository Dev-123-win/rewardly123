import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import User
import 'package:rewardly_app/ad_reward_service.dart'; // Assuming this service handles rewarded ads

class EarnCoinsScreen extends StatefulWidget {
  const EarnCoinsScreen({super.key});

  @override
  State<EarnCoinsScreen> createState() => _EarnCoinsScreenState();
}

class _EarnCoinsScreenState extends State<EarnCoinsScreen> {
  late AdRewardService _adRewardService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<User?>(context);
    _adRewardService = AdRewardService(user);
  }

  // Placeholder data for ad cards
  final List<Map<String, dynamic>> _adOffers = [
    {'title': 'Ad Title 1', 'points': 100},
    {'title': 'Ad Title 2', 'points': 150},
    {'title': 'Ad Title 3', 'points': 200},
    {'title': 'Ad Title 4', 'points': 50},
  ];

  @override
  void initState() {
    super.initState();
    _adRewardService.loadRewardedAd(); // Load ad when screen initializes
  }

  void _watchAd(int points) {
    _adRewardService.showRewardedAd(
      onRewardEarned: () {
        // Handle reward logic here, e.g., update user's coins
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You earned $points points!')),
        );
        // You might want to update the user's balance via a provider or service
      },
      onAdFailedToLoad: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load ad. Please try again.')),
        );
      },
      onAdFailedToShow: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to show ad. Please try again.')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch & Earn', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _adOffers.length,
        itemBuilder: (context, index) {
          final offer = _adOffers[index];
          return _AdCard(
            title: offer['title'],
            points: offer['points'],
            onWatchAd: () => _watchAd(offer['points']),
          );
        },
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final String title;
  final int points;
  final VoidCallback onWatchAd;

  const _AdCard({
    required this.title,
    required this.points,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.8),
              Colors.white.withOpacity(0.5),
              Colors.purple.withOpacity(0.1), // Light purple hint
              Colors.yellow.withOpacity(0.1), // Light yellow hint
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.green[700], size: 20),
                      const SizedBox(width: 5),
                      Text(
                        '$points Points',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onWatchAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen, // Green button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Watch Ad',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
