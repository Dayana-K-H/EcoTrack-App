import '../models/carbon_activity.dart';

class CarbonCalculator {
  static const Map<String, double> _transportEmissionFactors = {
    'Car': 0.18,          // kg CO2e per km
    'Motorcycle': 0.1,    // kg CO2e per km
    'Public Transport': 0.05, // kg CO2e per km
  };
  static const double _electricityEmissionFactor = 0.23; // kg CO2e per kWh
  static const double _wasteEmissionFactor = 0.5;       // kg CO2e per kg

  static double calculateTotalFootprint(CarbonActivity activity) {
    double totalCarbon = 0.0;

    // Transportation 
    if (activity.transportMode != 'N/A' && activity.transportDistance > 0) {
      final transportFactor = _transportEmissionFactors[activity.transportMode] ?? 0.0;
      totalCarbon += activity.transportDistance * transportFactor;
    }

    // Elictricity
    if (activity.electricityUsage > 0) {
      totalCarbon += activity.electricityUsage * _electricityEmissionFactor;
    }

    // Waste generation
    if (activity.wasteWeight > 0) {
      totalCarbon += activity.wasteWeight * _wasteEmissionFactor;
    }

    return totalCarbon;
  }

  static double calculateTransportFootprint(String mode, double distance) {
    final factor = _transportEmissionFactors[mode] ?? 0.0;
    return distance * factor;
  }

  static double calculateElectricityFootprint(double usageKWh) {
    return usageKWh * _electricityEmissionFactor;
  }

  static double calculateWasteFootprint(double weightKg) {
    return weightKg * _wasteEmissionFactor;
  }
}