import 'package:flutter/material.dart';
import 'log_transport_activity_view.dart'; 
import 'log_electricity_activity_view.dart'; 
import 'log_waste_activity_view.dart'; 

class CarbonLogView extends StatelessWidget {
  const CarbonLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Activity Type',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildActivityTypeButton(
                context,
                icon: Icons.directions_car,
                text: 'Log Transportation Activity',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LogTransportActivityView()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildActivityTypeButton(
                context,
                icon: Icons.lightbulb,
                text: 'Log Electricity Usage',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LogElectricityActivityView()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildActivityTypeButton(
                context,
                icon: Icons.delete,
                text: 'Log Waste Generation',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LogWasteActivityView()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTypeButton(BuildContext context, {required IconData icon, required String text, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: onPressed,
    );
  }
}