import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/carbon_activity.dart';
import '../view_models/carbon_log_view_model.dart';

class LogElectricityActivityView extends StatefulWidget {
  final CarbonActivity? activityToEdit;

  const LogElectricityActivityView({super.key, this.activityToEdit});

  @override
  State<LogElectricityActivityView> createState() => _LogElectricityActivityViewState();
}

class _LogElectricityActivityViewState extends State<LogElectricityActivityView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _electricityUsageController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.activityToEdit != null) {
      _isEditing = true;
      _electricityUsageController.text = widget.activityToEdit!.electricityUsage.toString();
    }
  }

  @override
  void dispose() {
    _electricityUsageController.dispose();
    super.dispose();
  }

  void _handleSaveActivity() async {
    if (_formKey.currentState!.validate()) {
      final carbonLogViewModel = Provider.of<CarbonLogViewModel>(context, listen: false);
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User not logged in.')),
          );
        }
        return;
      }

      final activity = CarbonActivity(
        id: _isEditing ? widget.activityToEdit!.id : null,
        userId: userId,
        transportMode: _isEditing ? widget.activityToEdit!.transportMode : 'N/A',
        transportDistance: _isEditing ? widget.activityToEdit!.transportDistance : 0.0,
        electricityUsage: double.parse(_electricityUsageController.text),
        wasteWeight: _isEditing ? widget.activityToEdit!.wasteWeight : 0.0,
        timestamp: _isEditing ? widget.activityToEdit!.timestamp : DateTime.now(),
        type: CarbonActivityType.electricity,
      );

      bool success = false;

      if (_isEditing) {
        await carbonLogViewModel.updateActivity(activity);
        if (carbonLogViewModel.error == null) {
          success = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Activity updated successfully!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update activity: ${carbonLogViewModel.error}')),
            );
          }
        }
      } else {
        await carbonLogViewModel.addActivity(activity);
        if (carbonLogViewModel.error == null) {
          success = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Electricity usage logged successfully!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to log activity: ${carbonLogViewModel.error}')),
            );
          }
        }
      }

      if (mounted && success) {
        Navigator.of(context).pop(true);
      } else if (mounted) {
        Navigator.of(context).pop(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Electricity Usage' : 'Log Electricity Usage',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Modify your electricity details:' : 'Enter your electricity usage details:',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 30),

              Text(
                'Energy Consumption',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColorDark),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Energy Source',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.flash_on),
                ),
                value: 'Grid Electricity',
                items: const [
                  DropdownMenuItem(value: 'Grid Electricity', child: Text('Grid Electricity')),
                  DropdownMenuItem(value: 'Solar Panels', child: Text('Solar Panels')),
                ],
                onChanged: (String? newValue) {
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _electricityUsageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Electricity Usage (kWh)',
                  hintText: 'e.g., 25.0',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.lightbulb),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter electricity usage';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              ElevatedButton.icon(
                icon: Icon(_isEditing ? Icons.save : Icons.eco, color: Colors.white),
                label: Text(
                  _isEditing ? 'Save Changes' : 'Log Activity',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: _handleSaveActivity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}