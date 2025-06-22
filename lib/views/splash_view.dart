import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_view.dart';
import 'home_dashboard_view.dart';

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 3));

    User? user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthView()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
              SizedBox(height: 24),
              Text(
                'Track Your Impact',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Easily log your daily activities to understand and reduce your carbon footprint.',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 40),
              SizedBox( 
                width: 150,
                child: LinearProgressIndicator(
                  color: Colors.green.shade700,
                  backgroundColor: Colors.green.shade100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}