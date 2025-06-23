import '../utils/carbon_calculator.dart';

class CarbonActivity {
  final String? id;
  final String userId;
  final String transportMode;
  final double transportDistance;
  final double electricityUsage;
  final double wasteWeight;
  final DateTime timestamp;

  CarbonActivity({
    this.id,
    required this.userId,
    required this.transportMode,
    required this.transportDistance,
    required this.electricityUsage,
    required this.wasteWeight,
    required this.timestamp,
  });

  double calculateCarbonFootprint() {
    return CarbonCalculator.calculateTotalFootprint(this);
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'transport_mode': transportMode,
      'transport_distance': transportDistance,
      'electricity_usage': electricityUsage,
      'waste_weight': wasteWeight,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CarbonActivity.fromJson(Map<String, dynamic> json) {
    return CarbonActivity(
      id: json['id'],
      userId: json['user_id'],
      transportMode: json['transport_mode'],
      transportDistance: json['transport_distance'].toDouble(),
      electricityUsage: json['electricity_usage'].toDouble(),
      wasteWeight: json['waste_weight'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}