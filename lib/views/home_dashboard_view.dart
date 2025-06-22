import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import 'auth_view.dart';

class HomeDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'EcoTrack Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green.shade700,
            elevation: 4,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await authViewModel.signOutUser();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AuthView()),
                  );
                },
              ),
            ],
          ),
          body: const SizedBox.shrink(),
        );
      },
    );
  }
}