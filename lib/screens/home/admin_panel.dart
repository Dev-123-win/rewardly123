import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rewardly_app/remote_config_service.dart';
import 'package:rewardly_app/shared/loading.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  int _dailyAdLimit = 0;
  int _coinsPerAd = 0;

  @override
  void initState() {
    super.initState();
    _loadRemoteConfig();
  }

  Future<void> _loadRemoteConfig() async {
    await _remoteConfigService.initialize();
    setState(() {
      _dailyAdLimit = _remoteConfigService.dailyAdLimit;
      _coinsPerAd = _remoteConfigService.coinsPerAd;
    });
  }

  Future<void> _updateRemoteConfig() async {
    await _remoteConfigService.initialize(); // Re-initialize to ensure latest values
    await _remoteConfigService.setConfigDefaults({
      'daily_ad_limit': _dailyAdLimit,
      'coins_per_ad': _coinsPerAd,
    });
    await _remoteConfigService.fetchAndActivate();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remote Config updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Remote Config Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _dailyAdLimit.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily Ad Limit',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _dailyAdLimit = int.tryParse(val) ?? 0;
                });
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: _coinsPerAd.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Coins Per Ad',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _coinsPerAd = int.tryParse(val) ?? 0;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateRemoteConfig,
              child: const Text('Update Remote Config'),
            ),
            const SizedBox(height: 40),
            const Text(
              'User Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loading();
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(data['email'] ?? 'N/A'),
                          subtitle: Text('Coins: ${data['coins']}, Ads Watched Today: ${data['adsWatchedToday']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final currentContext = context;
                              await _firestore.collection('users').doc(document.id).delete();
                              if (!currentContext.mounted) return;
                              ScaffoldMessenger.of(currentContext).showSnackBar(
                                const SnackBar(content: Text('User deleted!')),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
