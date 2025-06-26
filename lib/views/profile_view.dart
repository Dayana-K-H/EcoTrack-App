import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/auth_view_model.dart';
import '../view_models/carbon_log_view_model.dart';
import '../utils/carbon_calculator.dart';
import '../models/carbon_activity.dart';
import 'auth_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Map<CarbonActivityType, double> _carbonByType = {};
  double _totalLifetimeCarbon = 0.0;
  int _totalActivitiesLogged = 0;
  String _mostCarbonIntensiveActivity = 'N/A';

  @override
  void initState() {
    super.initState();
    _loadChartDataAndProfileStats();
  }

  void _loadChartDataAndProfileStats() {
    final carbonLogViewModel = Provider.of<CarbonLogViewModel>(context, listen: false);
    final List<CarbonActivity> activities = carbonLogViewModel.activities;

    Map<CarbonActivityType, double> tempCarbonByType = {
      CarbonActivityType.transport: 0.0,
      CarbonActivityType.electricity: 0.0,
      CarbonActivityType.waste: 0.0,
    };

    double currentTotalLifetimeCarbon = 0.0;
    int currentTotalActivitiesLogged = 0;

    for (var activity in activities) {
      double activityCarbon = CarbonCalculator.calculateTotalCarbonForActivity(activity);
      tempCarbonByType[activity.type] = (tempCarbonByType[activity.type] ?? 0.0) + activityCarbon;
      currentTotalLifetimeCarbon += activityCarbon;
      currentTotalActivitiesLogged++;
    }

    String mostIntensive = 'N/A';
    CarbonActivityType? maxType;
    double maxCarbonValue = -1.0;

    if (tempCarbonByType.values.any((value) => value > 0)) {
      tempCarbonByType.forEach((type, value) {
        if (value > maxCarbonValue) {
          maxCarbonValue = value;
          maxType = type;
        }
      });

      if (maxType != null) {
        switch (maxType!) {
          case CarbonActivityType.transport:
            mostIntensive = 'Transportation';
            break;
          case CarbonActivityType.electricity:
            mostIntensive = 'Electricity Usage';
            break;
          case CarbonActivityType.waste:
            mostIntensive = 'Waste Generation';
            break;
        }
      }
    }

    setState(() {
      _carbonByType = tempCarbonByType;
      _totalLifetimeCarbon = currentTotalLifetimeCarbon;
      _totalActivitiesLogged = currentTotalActivitiesLogged;
      _mostCarbonIntensiveActivity = mostIntensive;
    });
  }

  Future<void> _confirmLogout() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final carbonLogViewModel = Provider.of<CarbonLogViewModel>(context, listen: false);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await authViewModel.signOutUser();
                carbonLogViewModel.clearActivities();
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AuthView()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    Provider.of<CarbonLogViewModel>(context);
    final theme = Theme.of(context);

    final String displayName = authViewModel.currentUser?.displayName ?? 
                               (authViewModel.currentUser?.email?.split('@')[0]) ?? 
                               'User';
    final String email = authViewModel.currentUser?.email ?? 'N/A';

    double maxCarbon = _carbonByType.values.isNotEmpty 
                       ? _carbonByType.values.reduce(
                           (value, element) => value > element ? value : element) 
                       : 1.0;

    if (maxCarbon == 0.0) maxCarbon = 1.0;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 20.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hello, $displayName!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColorDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProfileInfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: email,
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    _buildProfileInfoRow(
                      icon: Icons.track_changes,
                      label: 'Total Activities Logged',
                      value: _totalActivitiesLogged.toString(),
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    _buildProfileInfoRow(
                      icon: Icons.public,
                      label: 'Total Lifetime Carbon',
                      value: '${_totalLifetimeCarbon.toStringAsFixed(2)} kg CO2e',
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    _buildProfileInfoRow(
                      icon: Icons.local_fire_department,
                      label: 'Most Carbon-Intensive Activity',
                      value: _mostCarbonIntensiveActivity,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),

            Text(
              'Your Carbon Footprint by Activity Type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColorDark),
            ),
            const SizedBox(height: 20),

            Card(
              margin: const EdgeInsets.only(bottom: 30.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _carbonByType.values.every((element) => element == 0.0)
                    ? Center(
                        child: Text(
                          'No carbon data logged yet. Log some activities to see your footprint by type!',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _carbonByType.entries.map((entry) {
                              final type = entry.key;
                              final carbonValue = entry.value;
                              final barHeight = (carbonValue / maxCarbon) * 150.0; 
                              
                              String label;
                              switch (type) {
                                case CarbonActivityType.transport:
                                  label = 'Transport';
                                  break;
                                case CarbonActivityType.electricity:
                                  label = 'Electricity';
                                  break;
                                case CarbonActivityType.waste:
                                  label = 'Waste';
                                  break;
                              }
                              
                              return Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${carbonValue.toStringAsFixed(1)}kg',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: barHeight > 5 ? barHeight : 5,
                                      width: 40,
                                      color: Colors.teal,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      label,
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.primaryColorDark),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Carbon Footprint by Type (kg CO2e)',
                            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: _confirmLogout,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.primaryColorDark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
