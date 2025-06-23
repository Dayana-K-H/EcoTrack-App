import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/carbon_log_view_model.dart';
import 'auth_view.dart';
import 'carbon_log_view.dart';
import 'recent_activities_view.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    _DashboardSummaryPage(),
    RecentActivitiesView(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CarbonLogViewModel>(context, listen: false).fetchActivities();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'EcoTrack Dashboard';
      case 1:
        return 'Recent Activities';
      default:
        return 'EcoTrack';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _getAppBarTitle(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green.shade700,
            elevation: 4,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  if (_selectedIndex == 1) { 
                    Provider.of<CarbonLogViewModel>(context, listen: false).fetchActivities();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dashboard data refreshed.')),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await authViewModel.signOutUser();
                  Provider.of<CarbonLogViewModel>(context, listen: false).clearActivities(); 
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AuthView()),
                  );
                },
              ),
            ],
          ),
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Activities',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.green.shade700, 
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped, 
          ),
        );
      },
    );
  }
}

class _DashboardSummaryPage extends StatelessWidget {
  const _DashboardSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final carbonLogViewModel = Provider.of<CarbonLogViewModel>(context); 

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Welcome, ${authViewModel.currentUser?.email ?? 'User'}!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text(
                'Log New Carbon Activity',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CarbonLogView()),
                ).then((_) {
                  carbonLogViewModel.fetchActivities();
                });
              },
            ),
          ),
          const SizedBox(height: 30),

          Text(
            'Your Impact Overview:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700),
          ),
          const SizedBox(height: 10),

          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Carbon Footprint:',
                    style: TextStyle(fontSize: 18, color: Colors.green.shade900),
                  ),
                  const SizedBox(height: 5),
                  if (carbonLogViewModel.isLoading && carbonLogViewModel.activities.isEmpty)
                    const CircularProgressIndicator()
                  else if (carbonLogViewModel.error != null)
                    Text('Error: ${carbonLogViewModel.error}', style: const TextStyle(color: Colors.red))
                  else
                    Text(
                      '${carbonLogViewModel.getTotalCarbonFootprint().toStringAsFixed(2)} kg CO2e',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}