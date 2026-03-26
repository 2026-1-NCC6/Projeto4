class FeederData {
  final double foodLevel; // Percentage 0-100
  final double bowlWeight; // Grams
  final String lastPetDetected;
  final bool isOnline;

  FeederData({
    required this.foodLevel,
    required this.bowlWeight,
    required this.lastPetDetected,
    required this.isOnline,
  });

  factory FeederData.fromMap(Map<String, dynamic> map) {
    return FeederData(
      foodLevel: (map['food_level'] ?? 0.0).toDouble(),
      bowlWeight: (map['bowl_weight'] ?? 0.0).toDouble(),
      lastPetDetected: map['last_pet'] ?? 'Unknown',
      isOnline: map['online'] ?? false,
    );
  }
}
