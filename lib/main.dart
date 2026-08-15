import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turfix_owner/firebase_options.dart';
import 'package:turfix_owner/view/auth/splash_screen.dart';
import 'package:turfix_owner/view_model/add_turf_provider.dart';
import 'package:turfix_owner/view_model/bookig_provider.dart';
import 'package:turfix_owner/view_model/common_provider.dart';
import 'package:turfix_owner/view_model/geo_locator_provider.dart';
import 'package:turfix_owner/view_model/sports_selecting_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CommonProvider()),
        ChangeNotifierProvider(create: (context) => BookingProvider()),
        ChangeNotifierProvider(create: (context) => SportsSelectingProvider()),
        ChangeNotifierProvider(create: (context) => AddTurfProvider()),
        ChangeNotifierProvider(create: (context) => GeoLocatorProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
