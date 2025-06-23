import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/carbon_activity.dart';
import '../view_models/carbon_log_view_model.dart';
import 'log_transport_activity_view.dart';
import 'log_electricity_activity_view.dart';
import 'log_waste_activity_view.dart';

class RecentActivitiesView extends StatelessWidget {
  const RecentActivitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    final carbonLogViewModel = Provider.of<CarbonLogViewModel>(context);

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
                  final vm = Provider.of<CarbonLogViewModel>(context, listen: false);
                  await vm.deleteActivity(activityId);
                  if (vm.error == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Activity deleted successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete activity: ${vm.error}')),
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

    Widget _buildEditButton(BuildContext context, CarbonActivity activity) {
      Widget pageToNavigate;
      switch (activity.type) {
        case CarbonActivityType.transport:
          pageToNavigate = LogTransportActivityView(activityToEdit: activity);
          break;
        case CarbonActivityType.electricity:
          pageToNavigate = LogElectricityActivityView(activityToEdit: activity);
          break;
        case CarbonActivityType.waste:
          pageToNavigate = LogWasteActivityView(activityToEdit: activity);
          break;
      }

      return IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => pageToNavigate),
          ).then((_) {
            Provider.of<CarbonLogViewModel>(context, listen: false).fetchActivities();
          });
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                                    _buildEditButton(context, activity),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _showDeleteConfirmation(context, activity.id!),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (activity.type == CarbonActivityType.transport)
                              Text('Mode: ${activity.transportMode} (${activity.transportDistance.toStringAsFixed(1)} km)'),
                            if (activity.type == CarbonActivityType.electricity)
                              Text('Electricity: ${activity.electricityUsage.toStringAsFixed(1)} kWh'),
                            if (activity.type == CarbonActivityType.waste)
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
    );
  }
}