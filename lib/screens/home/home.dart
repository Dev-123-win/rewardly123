import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:rewardly_app/auth_service.dart';
import 'package:rewardly_app/remote_config_service.dart';
import 'package:rewardly_app/user_service.dart';
import 'package:rewardly_app/shared/shimmer_loading.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';
import 'package:rewardly_app/screens/home/admin_panel.dart';
import 'package:rewardly_app/screens/home/earn_coins_screen.dart';
import 'package:rewardly_app/screens/home/referral_screen.dart';
import 'package:rewardly_app/screens/home/profile_screen.dart';
import 'package:rewardly_app/screens/home/withdraw_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  int _selectedIndex = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = Provider.of<User?>(context, listen: false);
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    if (user != null) {
      bool admin = false;
      if (userDataProvider.userData != null) {
        admin = userDataProvider.userData!['isAdmin'] ?? false;
      } else {
        // Fallback to direct service call if provider data is not yet available
        admin = await UserService().isAdmin(user.uid);
      }
      setState(() {
        _isAdmin = admin;
      });
    }
  }

  List<Widget> _buildScreens() {
    return [
      // EarnCoinsScreen is now accessed via a shortcut card on the main home body
      const ReferralScreen(),
      const ProfileScreen(),
      if (_isAdmin) const AdminPanel(),
    ];
  }

  List<BottomNavigationBarItem> _buildNavBarItems() {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.share),
        label: 'Referral',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
    if (_isAdmin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const HomeScreenLoading();
    }

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
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: Text(
            user.email ?? 'Rewardly App',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WithdrawScreen()),
              );
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await _auth.signOut();
            },
          )
        ],
      ),
      body: _selectedIndex == 0 // If selected index is 0, show the main home content with shortcut cards
          ? SingleChildScrollView(
              child: Container(
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
                      // Watch & Earn Shortcut Card
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EarnCoinsScreen()),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.green, Colors.lightGreen],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
                                SizedBox(height: 10),
                                Text(
                                  'Watch Ads & Earn Coins',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Tap to watch rewarded videos and get coins!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Consumer<UserDataProvider>(
                        builder: (context, userDataProvider, child) {
                          if (userDataProvider.userData == null) {
                            return const Center(
                              child: Column(
                                children: [
                                  ShimmerLoading.rectangular(height: 30, width: 150),
                                  SizedBox(height: 10),
                                  ShimmerLoading.rectangular(height: 18, width: 200),
                                ],
                              ),
                            );
                          }
                          Map<String, dynamic> userData = userDataProvider.userData!.data() as Map<String, dynamic>;
                          int coins = userData['coins'] ?? 0;
                          int adsWatchedToday = userData['adsWatchedToday'] ?? 0;
                          return Column(
                            children: [
                              Text(
                                'Coins: $coins',
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Ads Watched Today: $adsWatchedToday / ${_remoteConfigService.dailyAdLimit}',
                                style: const TextStyle(fontSize: 18, color: Colors.white70),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          : _buildScreens()[_selectedIndex - 1], // Adjust index for screens in bottom nav
      bottomNavigationBar: BottomNavigationBar(
        items: _buildNavBarItems(),
        currentIndex: _selectedIndex == 0 ? 0 : _selectedIndex - 1, // Adjust index for bottom nav
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            _selectedIndex = index + 1; // Adjust index for screens in bottom nav
          });
        },
      ),
    );
  }
}

class HomeScreenLoading extends StatelessWidget {
  const HomeScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: const ShimmerLoading.rectangular(height: 18, width: 150),
        actions: <Widget>[
          const ShimmerLoading.circular(width: 40, height: 40),
          const SizedBox(width: 10),
          const ShimmerLoading.rectangular(height: 40, width: 80),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
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
                const ShimmerLoading.rectangular(height: 200, width: double.infinity),
                const SizedBox(height: 20),
                const ShimmerLoading.rectangular(height: 30, width: 150),
                const SizedBox(height: 10),
                const ShimmerLoading.rectangular(height: 18, width: 200),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const ShimmerLoading.rectangular(height: 56),
    );
  }
}
