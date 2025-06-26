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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.9,
          children: [
            _buildActivityTypeGridItem(
              context,
              theme: theme,
              icon: Icons.directions_car,
              text: 'Log Transportation Activity',
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LogTransportActivityView()),
                );
                if (result == true) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop(true);
                  }
                }
              },
            ),
            _buildActivityTypeGridItem(
              context,
              theme: theme,
              icon: Icons.lightbulb,
              text: 'Log Electricity Usage',
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LogElectricityActivityView()),
                );
                if (result == true) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop(true);
                  }
                }
              },
            ),
            _buildActivityTypeGridItem(
              context,
              theme: theme,
              icon: Icons.delete,
              text: 'Log Waste Generation',
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LogWasteActivityView()),
                );
                if (result == true) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop(true);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTypeGridItem(BuildContext context, {required ThemeData theme, required IconData icon, required String text, required VoidCallback onPressed}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.teal.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: theme.primaryColor, size: 50),
              const SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: theme.primaryColorDark, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}