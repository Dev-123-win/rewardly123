import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:rewardly_app/auth_service.dart';
import 'package:rewardly_app/firebase_options.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rewardly_app/remote_config_service.dart';
import 'package:rewardly_app/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  MobileAds.instance.initialize(); // Initialize AdMob
  await RemoteConfigService().initialize(); // Initialize Remote Config
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: AuthService().user,
          initialData: null,
        ),
        ChangeNotifierProvider(
          create: (context) => UserDataProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Rewardly App',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const Wrapper(),
      ),
    );
  }
}
