import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/carbon_activity.dart';
import '../view_models/carbon_log_view_model.dart';

class LogTransportActivityView extends StatefulWidget {
  final CarbonActivity? activityToEdit;

  const LogTransportActivityView({super.key, this.activityToEdit});

  @override
  State<LogTransportActivityView> createState() => _LogTransportActivityViewState();
}

class _LogTransportActivityViewState extends State<LogTransportActivityView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _transportDistanceController = TextEditingController();

  String? _selectedTransportMode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.activityToEdit != null) {
      _isEditing = true;
      _selectedTransportMode = widget.activityToEdit!.transportMode;
      _transportDistanceController.text = widget.activityToEdit!.transportDistance.toString();
    }
  }

  @override
  void dispose() {
    _transportDistanceController.dispose();
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
        transportMode: _selectedTransportMode!,
        transportDistance: double.parse(_transportDistanceController.text),
        electricityUsage: _isEditing ? widget.activityToEdit!.electricityUsage : 0.0,
        wasteWeight: _isEditing ? widget.activityToEdit!.wasteWeight : 0.0,
        timestamp: _isEditing ? widget.activityToEdit!.timestamp : DateTime.now(),
        type: CarbonActivityType.transport,
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
              const SnackBar(content: Text('Transportation activity logged successfully!')),
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
          _isEditing ? 'Edit Transport Activity' : 'Log Transport Activity',
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
                _isEditing ? 'Modify your transportation details:' : 'Enter your transportation details:',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 30),

              Text(
                'Transportation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColorDark),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Mode of Transport',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                value: _selectedTransportMode,
                hint: const Text('Select mode'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTransportMode = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a mode' : null,
                items: <String>['Car', 'Motorcycle', 'Public Transport']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _transportDistanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Distance (km)',
                  hintText: 'e.g., 10.5',
                  prefixIcon: Icon(Icons.route),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter distance';
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
