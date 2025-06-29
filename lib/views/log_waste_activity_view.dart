import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/carbon_activity.dart';
import '../view_models/carbon_log_view_model.dart';

class LogWasteActivityView extends StatefulWidget {
  final CarbonActivity? activityToEdit;

  const LogWasteActivityView({super.key, this.activityToEdit});

  @override
  State<LogWasteActivityView> createState() => _LogWasteActivityViewState();
}

class _LogWasteActivityViewState extends State<LogWasteActivityView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _wasteWeightController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.activityToEdit != null) {
      _isEditing = true;
      _wasteWeightController.text = widget.activityToEdit!.wasteWeight.toString();
    }
  }

  @override
  void dispose() {
    _wasteWeightController.dispose();
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
        electricityUsage: _isEditing ? widget.activityToEdit!.electricityUsage : 0.0,
        wasteWeight: double.parse(_wasteWeightController.text),
        timestamp: _isEditing ? widget.activityToEdit!.timestamp : DateTime.now(),
        type: CarbonActivityType.waste,
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
              const SnackBar(content: Text('Waste generation logged successfully!')),
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
          _isEditing ? 'Edit Waste Generation' : 'Log Waste Generation',
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
                _isEditing ? 'Modify your waste generation details:' : 'Enter your waste generation details:',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 30),

              Text(
                'Waste Generation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColorDark),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _wasteWeightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Waste Weight (kg)',
                  hintText: 'e.g., 1.5',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.delete),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter waste weight';
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
