class FeederData {
  final double waterLevel;    // Valor 0-100%
  final String waterStatus;   // "AGUA_DETECTADA" ou "SECO"
  final double foodWeight;    // Peso em gramas
  final String lastPetDetected;
  final bool isOnline;
  final double calibrationFactor;
  final int rawWeight;

  FeederData({
    required this.waterLevel,
    this.waterStatus = "Unknown",
    required this.foodWeight,
    required this.lastPetDetected,
    required this.isOnline,
    this.calibrationFactor = 1.0,
    this.rawWeight = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'waterLevel': waterLevel,
      'waterStatus': waterStatus,
      'foodWeight': foodWeight,
      'lastTag': lastPetDetected,
      'isOnline': isOnline,
      'calibrationFactor': calibrationFactor,
      'rawWeight': rawWeight,
    };
  }

  factory FeederData.fromMap(Map<String, dynamic> map) {
    // Normalization: ESP sends 0-1023, we convert to 0-100%
    double rawWater = (map["waterLevel"] ?? map["currentWater"] ?? 0.0).toDouble();
    double normalizedWater = rawWater > 101 ? (rawWater / 1023.0) * 100.0 : rawWater;

    return FeederData(
      waterLevel: normalizedWater.clamp(0.0, 100.0),
      waterStatus: map["waterStatus"] ?? (normalizedWater > 5 ? "WATER_DETECTED" : "DRY"),
      foodWeight: (map["foodWeight"] ?? map["currentFood"] ?? 0.0).toDouble(),
      lastPetDetected: map["lastTag"] ?? "None",
      isOnline: map["isOnline"] ?? true,
      calibrationFactor: (map["calibrationFactor"] ?? 1.0).toDouble(),
      rawWeight: (map["rawWeight"] ?? 0).toInt(),
    );
  }
}