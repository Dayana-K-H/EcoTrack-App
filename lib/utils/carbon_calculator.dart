import '../models/carbon_activity.dart';

class CarbonCalculator {
  static const double _carEmissionFactor = 0.18;
  static const double _motorcycleEmissionFactor = 0.08;
  static const double _publicTransportEmissionFactor = 0.05;
  static const double _gridElectricityEmissionFactor = 0.5;
  static const double _wasteEmissionFactor = 0.2;

  static double calculateTransportCarbon(String mode, double distance) {
    switch (mode) {
      case 'Car':
        return distance * _carEmissionFactor;
      case 'Motorcycle':
        return distance * _motorcycleEmissionFactor;
      case 'Public Transport':
        return distance * _publicTransportEmissionFactor;
      default:
        return 0.0;
    }
  }

  static double calculateElectricityCarbon(double usageKWh) {
    return usageKWh * _gridElectricityEmissionFactor;
  }

  static double calculateWasteCarbon(double wasteKg) {
    return wasteKg * _wasteEmissionFactor;
  }

  static double calculateTotalCarbonForActivity(CarbonActivity activity) {
    double total = 0.0;
    if (activity.type == CarbonActivityType.transport) {
      total += calculateTransportCarbon(activity.transportMode, activity.transportDistance);
    } else if (activity.type == CarbonActivityType.electricity) {
      total += calculateElectricityCarbon(activity.electricityUsage);
    } else if (activity.type == CarbonActivityType.waste) {
      total += calculateWasteCarbon(activity.wasteWeight);
    }
    return total;
  }

  static double toTreesNeeded(double carbonKg) {
    return carbonKg / 22.0;
  }

  static double toKgArcticIceMelted(double carbonKg) {
    return carbonKg * 3.0;
  }

  static double toKgCoalBurned(double carbonKg) {
    return carbonKg / 2.5;
  }
}
