import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/carbon_activity.dart';
import '../view_models/carbon_log_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
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
        type: CarbonActivityType.electricity, // NEW: Tetapkan jenis aktivitas
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
            const SnackBar(content: Text('Electricity usage logged successfully!')),
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
          _isEditing ? 'Edit Electricity Usage' : 'Log Electricity Usage',
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
                _isEditing ? 'Modify your electricity details:' : 'Enter your electricity usage details:',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 30),

              // --- Energy Consumption Section ---
              Text(
                'Energy Consumption',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _electricityUsageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Electricity Usage (kWh)',
                  hintText: 'e.g., 25.0',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.lightbulb, color: Colors.green.shade700),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green.shade700, width: 2.0),
                  ),
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