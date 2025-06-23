import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/carbon_activity.dart';
import '../view_models/carbon_log_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
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
      );

      if (_isEditing) {
        await carbonLogViewModel.updateActivity(activity);
        if (carbonLogViewModel.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activity updated successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update activity: ${carbonLogViewModel.error}')),
          );
        }
      } else {
        await carbonLogViewModel.addActivity(activity);
        if (carbonLogViewModel.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transportation activity logged successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to log activity: ${carbonLogViewModel.error}')),
          );
        }
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transport Activity' : 'Log Transport Activity',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
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

              // --- Transportation Section ---
              Text(
                'Transportation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Mode of Transport',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.directions_car, color: Colors.green.shade700),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green.shade700, width: 2.0),
                  ),
                ),
                value: _selectedTransportMode,
                hint: const Text('Select mode'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTransportMode = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a mode' : null,
                items: <String>['Car', 'Motorcycle', 'Public Transport'] // Daftar yang diperbarui
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.route, color: Colors.green.shade700),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green.shade700, width: 2.0),
                  ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size(double.infinity, 50),
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