import 'package:ecotrack_app/models/carbon_activity.dart';
import 'package:ecotrack_app/views/log_electricity_activity_view.dart';
import 'package:ecotrack_app/views/log_transport_activity_view.dart';
import 'package:ecotrack_app/views/log_waste_activity_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/carbon_log_view_model.dart';
import 'auth_view.dart';
import 'carbon_log_view.dart';


class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CarbonLogViewModel>(context, listen: false).fetchActivities();
    });
  }

  void _showDeleteConfirmation(BuildContext context, String activityId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this activity?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); 
                final carbonLogViewModel = Provider.of<CarbonLogViewModel>(context, listen: false);
                await carbonLogViewModel.deleteActivity(activityId);
                if (carbonLogViewModel.error == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Activity deleted successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete activity: ${carbonLogViewModel.error}')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, CarbonLogViewModel>(
      builder: (context, authViewModel, carbonLogViewModel, child) {
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
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => carbonLogViewModel.fetchActivities(),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await authViewModel.signOutUser();
                  carbonLogViewModel.clearActivities();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AuthView()),
                  );
                },
              ),
            ],
          ),
          body: Padding(
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
                        MaterialPageRoute(builder: (context) => const CarbonLogView()), // Navigasi ke pemilih jenis aktivitas
                      ).then((_) {
                        carbonLogViewModel.fetchActivities(); // Refresh setelah kembali
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),

                Text(
                  'Your Recent Activities:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                ),
                const SizedBox(height: 10),

                if (carbonLogViewModel.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (carbonLogViewModel.error != null)
                  Center(child: Text('Error: ${carbonLogViewModel.error}', style: const TextStyle(color: Colors.red)))
                else if (carbonLogViewModel.activities.isEmpty)
                  Center(
                      child: Text(
                        'No carbon activities logged yet.\nLog one to see it here!',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    )
                else
                  Expanded(
                    child: ListView.builder(
                        itemCount: carbonLogViewModel.activities.length,
                        itemBuilder: (context, index) {
                          final activity = carbonLogViewModel.activities[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 2,
                            color: Colors.green.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Date: ${activity.timestamp.toLocal().toString().split(' ')[0]}',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900),
                                      ),
                                      Row(
                                        children: [
                                          _buildEditButton(context, activity, activity.transportMode),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _showDeleteConfirmation(context, activity.id!),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (activity.transportMode != 'N/A') 
                                    Text('Mode: ${activity.transportMode} (${activity.transportDistance.toStringAsFixed(1)} km)'),
                                  if (activity.electricityUsage != 0.0)
                                    Text('Electricity: ${activity.electricityUsage.toStringAsFixed(1)} kWh'),
                                  if (activity.wasteWeight != 0.0)
                                    Text('Waste: ${activity.wasteWeight.toStringAsFixed(1)} kg'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Carbon Footprint: ${activity.calculateCarbonFootprint().toStringAsFixed(2)} kg CO2e',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ),
                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'Total Carbon Footprint: ${carbonLogViewModel.getTotalCarbonFootprint().toStringAsFixed(2)} kg CO2e',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditButton(BuildContext context, CarbonActivity activity, String mode) {
    if (mode != 'N/A') { 
      if (mode == 'Car' || mode == 'Motorcycle' || mode == 'Public Transport' || mode == 'Bicycle' || mode == 'Walk') {
        return IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => LogTransportActivityView(activityToEdit: activity)),
            ).then((_) {
              Provider.of<CarbonLogViewModel>(context, listen: false).fetchActivities();
            });
          },
        );
      } else if (activity.electricityUsage != 0.0 && activity.transportMode == 'N/A' && activity.wasteWeight == 0.0) {
        return IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => LogElectricityActivityView(activityToEdit: activity)),
            ).then((_) {
              Provider.of<CarbonLogViewModel>(context, listen: false).fetchActivities();
            });
          },
        );
      } else if (activity.wasteWeight != 0.0 && activity.transportMode == 'N/A' && activity.electricityUsage == 0.0) {
        return IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => LogWasteActivityView(activityToEdit: activity)),
            ).then((_) {
              Provider.of<CarbonLogViewModel>(context, listen: false).fetchActivities();
            });
          },
        );
      }
    }
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CarbonLogView()),
        ).then((_) {
          Provider.of<CarbonLogViewModel>(context, listen: false).fetchActivities();
        });
      },
    );
  }
}