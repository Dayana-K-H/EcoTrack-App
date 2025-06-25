import '../models/carbon_activity.dart';

class CarbonCalculator {
  static const Map<String, double> _transportEmissionFactors = {
    'Car': 0.18,          
    'Motorcycle': 0.1,  
    'Public Transport': 0.05,
  };
  static const double _electricityEmissionFactor = 0.23; 
  static const double _wasteEmissionFactor = 0.5;     

  static const double _kgCo2ePerTreePerYear = 21.0;
  static const double _kgCo2eToKgArcticIceMelted = 3.0;
  static const double _kgCo2ePerKgCoalBurned = 2.42;

  static double calculateTotalFootprint(CarbonActivity activity) {
    double totalCarbon = 0.0;

    if (activity.transportMode != 'N/A' && activity.transportDistance > 0) {
      final transportFactor = _transportEmissionFactors[activity.transportMode] ?? 0.0;
      totalCarbon += activity.transportDistance * transportFactor;
    }

    if (activity.electricityUsage > 0) {
      totalCarbon += activity.electricityUsage * _electricityEmissionFactor;
    }

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

  static double toTreesNeeded(double totalKgCo2e) {
    if (totalKgCo2e <= 0) return 0.0;
    return totalKgCo2e / _kgCo2ePerTreePerYear;
  }

  static double toKgArcticIceMelted(double totalKgCo2e) {
    if (totalKgCo2e <= 0) return 0.0;
    return totalKgCo2e * _kgCo2eToKgArcticIceMelted;
  }

  static double toKgCoalBurned(double totalKgCo2e) {
    if (totalKgCo2e <= 0 || _kgCo2ePerKgCoalBurned == 0) return 0.0;
    return totalKgCo2e / _kgCo2ePerKgCoalBurned;
  }
}
