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
import 'package:rewardly_app/screens/home/aqua_blast_screen.dart';
import 'package:rewardly_app/screens/home/offer_pro_screen.dart';
import 'package:rewardly_app/screens/home/read_and_earn_screen.dart';
import 'package:rewardly_app/screens/home/play_game_screen.dart';
import 'package:rewardly_app/screens/home/daily_stream_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 2; // Set Home as initial selected index
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
        admin = await UserService().isAdmin(user.uid);
      }
      setState(() {
        _isAdmin = admin;
      });
    }
  }

  List<Widget> _buildScreens() {
    return [
      const WithdrawScreen(), // Index 0 (Redeem)
      const ReferralScreen(), // Index 1 (Invite)
      _buildHomePageContent(), // Index 2 (Home)
      const ProfileScreen(), // Index 3 (Profile)
      if (_isAdmin) const AdminPanel(), // Index 4 (Admin)
    ];
  }

  List<BottomNavigationBarItem> _buildNavBarItems() {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.redeem),
        label: 'Redeem',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_add),
        label: 'Invite',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
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
    final AuthService authService = AuthService(); // Access AuthService here

    if (user == null) {
      return const HomeScreenLoading();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // White AppBar background
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: Text(
            user.email ?? 'Rewardly App',
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18), // Darker text
          ),
        ),
        elevation: 1.0, // Subtle shadow
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.logout, color: Theme.of(context).primaryColor), // Primary color icon
            label: Text('Logout', style: TextStyle(color: Theme.of(context).primaryColor)), // Primary color text
            onPressed: () async {
              await authService.signOut();
            },
          )
        ],
      ),
      body: _buildScreens()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _buildNavBarItems(),
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor, // Primary color for selected item
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomePageContent() {
    final user = Provider.of<User?>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (user == null || userDataProvider.userData == null) {
      return const HomeScreenLoading();
    }

    Map<String, dynamic> userData = userDataProvider.userData!.data() as Map<String, dynamic>;
    int coins = userData['coins'] ?? 0;
    double totalBalanceINR = coins / 1000.0; // 1000 coins = 1 INR

    return SingleChildScrollView(
      child: Container(
        color: Colors.white, // White background for home content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email ?? 'Rewardly App',
                        style: const TextStyle(color: Colors.black87, fontSize: 16), // Darker text
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WithdrawScreen()),
                      );
                    },
                    child: Card(
                      color: Colors.grey[100], // Light grey card
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_wallet, color: Theme.of(context).primaryColor, size: 20), // Primary color icon
                            const SizedBox(width: 8),
                            Text(
                              'Total Balance\n₹${totalBalanceINR.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.black87, fontSize: 14), // Darker text
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Available Coins',
                style: TextStyle(color: Colors.black54, fontSize: 16), // Darker text
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB((Colors.white.alpha * 0.5).round(), Colors.white.red, Colors.white.green, Colors.white.blue),
                              Color.fromARGB((Colors.white.alpha * 0.2).round(), Colors.white.red, Colors.white.green, Colors.white.blue),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(
                                (((Colors.black.value >> 24) & 0xFF) * 0.1).round(),
                                (Colors.black.value >> 16) & 0xFF,
                                (Colors.black.value >> 8) & 0xFF,
                                Colors.black.value & 0xFF,
                              ),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: Color.fromARGB(
                              (((Colors.white.value >> 24) & 0xFF) * 0.2).round(),
                              (Colors.white.value >> 16) & 0xFF,
                              (Colors.white.value >> 8) & 0xFF,
                              Colors.white.value & 0xFF,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset('assets/AppLogo.png', height: 40, width: 40), // Placeholder for coin icon
                                const SizedBox(width: 10),
                                Text(
                                  '${coins}K', // Assuming K for thousands, adjust as needed
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87), // Darker text
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Coins',
                              style: TextStyle(fontSize: 16, color: Colors.black54), // Darker text
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB((Colors.white.alpha * 0.5).round(), Colors.white.red, Colors.white.green, Colors.white.blue),
                              Color.fromARGB((Colors.white.alpha * 0.2).round(), Colors.white.red, Colors.white.green, Colors.white.blue),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(
                                (((Colors.black.value >> 24) & 0xFF) * 0.1).round(),
                                (Colors.black.value >> 16) & 0xFF,
                                (Colors.black.value >> 8) & 0xFF,
                                Colors.black.value & 0xFF,
                              ),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: Color.fromARGB(
                              (((Colors.white.value >> 24) & 0xFF) * 0.2).round(),
                              (Colors.white.value >> 16) & 0xFF,
                              (Colors.white.value >> 8) & 0xFF,
                              Colors.white.value & 0xFF,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.diamond, size: 40, color: Theme.of(context).primaryColor), // Primary color icon
                                const SizedBox(width: 10),
                                Text(
                                  '0', // Diamonds are not tracked, so display 0
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87), // Darker text
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Diamonds',
                              style: TextStyle(fontSize: 16, color: Colors.black54), // Darker text
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Super Offer Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(
                        (((Theme.of(context).primaryColor.value >> 24) & 0xFF) * 0.8).round(),
                        (Theme.of(context).primaryColor.value >> 16) & 0xFF,
                        (Theme.of(context).primaryColor.value >> 8) & 0xFF,
                        Theme.of(context).primaryColor.value & 0xFF,
                      ),
                      Color.fromARGB(
                        (((Theme.of(context).primaryColor.value >> 24) & 0xFF) * 0.6).round(),
                        (Theme.of(context).primaryColor.value >> 16) & 0xFF,
                        (Theme.of(context).primaryColor.value >> 8) & 0xFF,
                        Theme.of(context).primaryColor.value & 0xFF,
                      ),
                    ], // Primary color gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Super Offer',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Get coin Upto ${RemoteConfigService().coinsPerAd * RemoteConfigService().dailyAdLimit}k', // Example, adjust as needed
                            style: const TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EarnCoinsScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Get now!', style: TextStyle(color: Theme.of(context).primaryColor)), // Primary color text
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Offer Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildOfferCard(
                    context,
                    title: 'Aqua Blast',
                    subtitle: 'Get coin Upto ∞',
                    icon: Icons.gamepad,
                    startColor: const Color(0xFF6A5ACD), // SlateBlue
                    endColor: const Color(0xFF836FFF), // LightSlateBlue
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AquaBlastScreen()));
                    },
                  ),
                  _buildOfferCard(
                    context,
                    title: 'OfferPro',
                    subtitle: 'Get coin Upto 100K',
                    icon: Icons.local_offer,
                    startColor: const Color(0xFF483D8B), // DarkSlateBlue
                    endColor: const Color(0xFF6A5ACD), // SlateBlue
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const OfferProScreen()));
                    },
                  ),
                  _buildOfferCard(
                    context,
                    title: 'Read & Earn',
                    subtitle: 'Earn Upto',
                    icon: Icons.menu_book,
                    startColor: const Color(0xFFDAA520), // GoldenRod
                    endColor: const Color(0xFFFFD700), // Gold
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ReadAndEarnScreen()));
                    },
                  ),
                  _buildOfferCard(
                    context,
                    title: 'Play Game!',
                    subtitle: 'Earn Upto',
                    icon: Icons.sports_esports,
                    startColor: const Color(0xFF8B008B), // DarkMagenta
                    endColor: const Color(0xFFBA55D3), // MediumPurple
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayGameScreen()));
                    },
                  ),
                  _buildOfferCard(
                    context,
                    title: 'Daily Stream',
                    subtitle: 'Earn Upto',
                    icon: Icons.stream,
                    startColor: const Color(0xFF00CED1), // DarkTurquoise
                    endColor: const Color(0xFF40E0D0), // Turquoise
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DailyStreamScreen()));
                    },
                  ),
                  _buildOfferCard(
                    context,
                    title: 'Watch Ads',
                    subtitle: 'Earn Upto ${RemoteConfigService().coinsPerAd} coins per ad',
                    icon: Icons.play_circle_fill,
                    startColor: Colors.green,
                    endColor: Colors.lightGreen,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EarnCoinsScreen()));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(
                  (((Colors.white.value >> 24) & 0xFF) * 0.5).round(),
                  (Colors.white.value >> 16) & 0xFF,
                  (Colors.white.value >> 8) & 0xFF,
                  Colors.white.value & 0xFF,
                ),
                Color.fromARGB(
                  (((Colors.white.value >> 24) & 0xFF) * 0.2).round(),
                  (Colors.white.value >> 16) & 0xFF,
                  (Colors.white.value >> 8) & 0xFF,
                  Colors.white.value & 0xFF,
                ),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(
                    (((Colors.black.value >> 24) & 0xFF) * 0.1).round(),
                    (Colors.black.value >> 16) & 0xFF,
                    (Colors.black.value >> 8) & 0xFF,
                    Colors.black.value & 0xFF,
                  ),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: Color.fromARGB(
                (((Colors.white.value >> 24) & 0xFF) * 0.2).round(),
                (Colors.white.value >> 16) & 0xFF,
                (Colors.white.value >> 8) & 0xFF,
                Colors.white.value & 0xFF,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor), // Primary color icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), // Darker text
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54), // Darker text
                  ),
                ],
              ),
            ],
          ),
        ),
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
        backgroundColor: Colors.white, // White AppBar background
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
          color: Colors.white, // White background
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
