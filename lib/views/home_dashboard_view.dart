import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/carbon_log_view_model.dart';
import '../utils/carbon_calculator.dart';
import 'carbon_log_view.dart';
import 'recent_activities_view.dart';
import 'profile_view.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const _DashboardSummaryPage(),
      const RecentActivitiesView(),
      const ProfileView(),
    ];
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
      case 2:
        return 'Your Profile';
      default:
        return 'EcoTrack';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_selectedIndex == 1 || _selectedIndex == 0) {
                Provider.of<CarbonLogViewModel>(context, listen: false).fetchActivities();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data refreshed.')),
                );
              }
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _DashboardSummaryPage extends StatelessWidget {
  const _DashboardSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final carbonLogViewModel = Provider.of<CarbonLogViewModel>(context);
    final totalCarbon = carbonLogViewModel.getTotalCarbonFootprint();
    final theme = Theme.of(context);

    final treesNeeded = CarbonCalculator.toTreesNeeded(totalCarbon);
    final kgArcticIceMelted = CarbonCalculator.toKgArcticIceMelted(totalCarbon);
    final kgCoalBurned = CarbonCalculator.toKgCoalBurned(totalCarbon);

    String _getSimplifiedDamageDescription(double carbonKg) {
      if (carbonKg <= 0) {
        return 'Start logging your activities to see your environmental impact and tips for a greener lifestyle!';
      } else if (carbonKg < 100) {
        return 'Your carbon footprint contributes to climate change. Reducing emissions from daily activities like transportation, energy, and waste is key for a healthier planet.';
      } else {
        return 'Your emissions have a noticeable impact. Significant efforts to reduce travel, conserve energy, and manage waste can lead to a positive change for the environment.';
      }
    }

    final String displayName = authViewModel.currentUser?.displayName ?? 
                               (authViewModel.currentUser?.email?.split('@')[0]) ?? 
                               'User';
    print('Dashboard: Displaying name: $displayName');


    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Welcome, $displayName!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.primaryColorDark,
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
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CarbonLogView()),
                );

                if (result == true) {
                  carbonLogViewModel.fetchActivities();
                  if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Activity logged successfully!')),
                      );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 30),

          Text(
            'Eco Tip of the Day:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColorDark),
          ),
          const SizedBox(height: 10),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            color: theme.cardTheme.color,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                carbonLogViewModel.currentTip,
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: theme.primaryColorDark),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 30),

          Text(
            'Your Impact Overview:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColorDark),
          ),
          const SizedBox(height: 10),

          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            color: theme.cardTheme.color,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Carbon Footprint:',
                    style: TextStyle(fontSize: 18, color: theme.primaryColorDark),
                  ),
                  const SizedBox(height: 5),
                  if (carbonLogViewModel.isLoading && carbonLogViewModel.activities.isEmpty)
                    const CircularProgressIndicator()
                  else if (carbonLogViewModel.error != null)
                    Text('Error: ${carbonLogViewModel.error}', style: const TextStyle(color: Colors.red))
                  else
                    Text(
                      '${totalCarbon.toStringAsFixed(2)} kg CO2e',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.primaryColor),
                    ),
                  const SizedBox(height: 15),

                  Text(
                    'Equivalent to:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.primaryColorDark),
                  ),
                  const SizedBox(height: 5),
                  if (totalCarbon > 0) ...[
                    _buildImpactRow(
                      icon: Icons.park,
                      iconColor: Colors.green,
                      text: '${treesNeeded.toStringAsFixed(1)} trees for 1 year absorption',
                      theme: theme,
                    ),
                    const SizedBox(height: 5),
                    _buildImpactRow(
                      icon: Icons.ac_unit,
                      iconColor: Colors.lightBlue,
                      text: '${kgArcticIceMelted.toStringAsFixed(1)} kg of Arctic ice melted',
                      theme: theme,
                    ),
                    const SizedBox(height: 5),
                    _buildImpactRow(
                      icon: Icons.fireplace,
                      iconColor: Colors.brown,
                      text: '${kgCoalBurned.toStringAsFixed(1)} kg of coal burned',
                      theme: theme,
                    ),
                  ] else ...[
                    Text(
                      'Log activities to see equivalents!',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          Card( 
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4, 
            color: Colors.orange.shade50, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, size: 28, color: Colors.deepOrange),
                      const SizedBox(width: 10),
                      Text(
                        'Environmental Impact:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade800),
                      ),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1, color: Colors.orange),
                  Text(
                    _getSimplifiedDamageDescription(totalCarbon),
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Reducing emissions from transportation, electricity, and waste are crucial for a healthier planet.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactRow({
    required IconData icon,
    required Color iconColor,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: theme.primaryColorDark),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
