import 'package:flutter/material.dart';
import 'log_transport_activity_view.dart';
import 'log_electricity_activity_view.dart';
import 'log_waste_activity_view.dart';

class CarbonLogView extends StatelessWidget {
  const CarbonLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Activity Type'),
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
                theme: theme,
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
                theme: theme,
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
                theme: theme,
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

  Widget _buildActivityTypeButton(BuildContext context, {required ThemeData theme, required IconData icon, required String text, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
      onPressed: onPressed,
    );
  }
}