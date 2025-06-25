import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_dashboard_view.dart';
import 'auth_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    User? user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthView()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/ecotrack_logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 24),
              const Text(
                'Track Your Impact',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Easily log your daily activities to understand and reduce your carbon footprint.',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 150,
                child: LinearProgressIndicator(
                  color: theme.primaryColor,
                  backgroundColor: theme.primaryColor.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}