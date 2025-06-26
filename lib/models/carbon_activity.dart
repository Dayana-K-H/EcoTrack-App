import '../utils/carbon_calculator.dart';

enum CarbonActivityType { transport, electricity, waste }

class CarbonActivity {
  final String? id; 
  final String userId; 
  final String transportMode; 
  final double transportDistance; 
  final double electricityUsage;
  final double wasteWeight; 
  final DateTime timestamp;
  final CarbonActivityType type;

  CarbonActivity({
    this.id,
    required this.userId,
    this.transportMode = 'N/A',
    this.transportDistance = 0.0,
    this.electricityUsage = 0.0,
    this.wasteWeight = 0.0,
    required this.timestamp,
    required this.type,
  });

  double calculateCarbonFootprint() {
    return CarbonCalculator.calculateTotalCarbonForActivity(this);
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'transport_mode': transportMode,
      'transport_distance': transportDistance,
      'electricity_usage': electricityUsage,
      'waste_weight': wasteWeight,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
    };
  }

  factory CarbonActivity.fromJson(Map<String, dynamic> json) {
    return CarbonActivity(
      id: json['id'],
      userId: json['user_id'],
      transportMode: json['transport_mode'] ?? 'N/A',
      transportDistance: json['transport_distance']?.toDouble() ?? 0.0,
      electricityUsage: json['electricity_usage']?.toDouble() ?? 0.0,
      wasteWeight: json['waste_weight']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
      type: CarbonActivityType.values.firstWhere(
        (e) => e.name == (json['type'] ?? CarbonActivityType.transport.name),
        orElse: () => CarbonActivityType.transport,
      ),
    );
  }
}