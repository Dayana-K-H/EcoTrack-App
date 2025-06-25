import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';

import 'view_models/auth_view_model.dart';
import 'view_models/carbon_log_view_model.dart';
import 'views/splash_view.dart';
import 'views/auth_view.dart';
import 'views/home_dashboard_view.dart';
import 'views/carbon_log_view.dart';
import 'views/log_transport_activity_view.dart';
import 'views/log_electricity_activity_view.dart';
import 'views/log_waste_activity_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  try {
    Firebase.app();
    print('Firebase already initialized.');
  } catch (e) {
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully.');
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CarbonLogViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTrack',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',

        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          accentColor: Colors.deepOrangeAccent,
          backgroundColor: Colors.white,
        ),

        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          prefixIconColor: Colors.teal.shade700,
          floatingLabelStyle: TextStyle(color: Colors.teal.shade700),
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Colors.teal.shade700,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.teal.shade50,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.teal.shade700,
            side: BorderSide(color: Colors.teal.shade600, width: 2.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.teal.shade700,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.teal.shade700,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const SplashView(),
      routes: {
        '/splash': (context) => const SplashView(),
        '/auth_view': (context) => AuthView(),
        '/home_dashboard': (context) => const HomeDashboard(),
        '/carbon_log': (context) => const CarbonLogView(),
        '/log_transport': (context) => const LogTransportActivityView(),
        '/log_electricity': (context) => const LogElectricityActivityView(),
        '/log_waste': (context) => const LogWasteActivityView(),
      },
    );
  }
}