class FeederData {
  final double waterLevel;    // Valor 0-100%
  final String waterStatus;   // "AGUA_DETECTADA" ou "SECO"
  final double foodWeight;    // Peso em gramas
  final String lastPetDetected;
  final bool isOnline;

  FeederData({
    required this.waterLevel,
    this.waterStatus = "Unknown",
    required this.foodWeight,
    required this.lastPetDetected,
    required this.isOnline,
  });

  Map<String, dynamic> toMap() {
    return {
      'waterLevel': waterLevel,
      'waterStatus': waterStatus,
      'foodWeight': foodWeight,
      'lastTag': lastPetDetected,
      'isOnline': isOnline,
    };
  }

  factory FeederData.fromMap(Map<String, dynamic> map) {
    // Normalization: ESP sends 0-1023, we convert to 0-100%
    // If we're loading from cache, it might already be normalized.
    // Let's check if the raw value looks like it's already 0-100.
    double rawWater = (map["waterLevel"] ?? 0.0).toDouble();
    
    // Simple heuristic: if it's > 100, it's probably raw from ESP
    double normalizedWater = rawWater > 101 ? (rawWater / 1023.0) * 100.0 : rawWater;

    return FeederData(
      waterLevel: normalizedWater.clamp(0.0, 100.0),
      waterStatus: map["waterStatus"] ?? "Unknown",
      foodWeight: (map["foodWeight"] ?? 0.0).toDouble(),
      lastPetDetected: map["lastTag"] ?? "None",
      isOnline: map["isOnline"] ?? true,
    );
  }
}