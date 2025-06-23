import 'package:ecotrack_app/views/carbon_log_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'view_models/auth_view_model.dart';
import 'view_models/carbon_log_view_model.dart';
import 'views/splash_view.dart';
import 'views/auth_view.dart';
import 'views/home_dashboard_view.dart';
import 'views/log_transport_activity_view.dart';
import 'views/log_electricity_activity_view.dart';
import 'views/log_waste_activity_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  try {
    // Coba akses aplikasi Firebase default.
    // Jika aplikasi sudah ada, ini akan berhasil.
    Firebase.app();
  } catch (e) {
    // Jika terjadi error saat mencoba mengakses aplikasi (berarti belum diinisialisasi),
    // maka lanjutkan dengan inisialisasi.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTrack',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: SplashView(),
      routes: {
        '/splash': (context) => SplashView(),
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