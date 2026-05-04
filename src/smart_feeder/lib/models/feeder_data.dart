class FeederData {
  final double waterLevel;    // Valor 0-100%
  final String waterStatus;   // "AGUA_DETECTADA" ou "SECO"
  final double foodLevel;     // Porcentagem de comida
  final double foodWeight;    // Peso em gramas
  final String lastPetDetected;
  final bool isOnline;

  FeederData({
    required this.waterLevel,
    this.waterStatus = "Unknown",
    required this.foodLevel,
    required this.foodWeight,
    required this.lastPetDetected,
    required this.isOnline,
  });

  factory FeederData.fromMap(Map<String, dynamic> map) {
    // Normalization: ESP sends 0-1023, we convert to 0-100%
    double rawWater = (map["waterLevel"] ?? 0.0).toDouble();
    double normalizedWater = (rawWater / 1023.0) * 100.0;

    return FeederData(
      waterLevel: normalizedWater.clamp(0.0, 100.0),
      waterStatus: map["waterStatus"] ?? "Unknown",
      foodLevel: (map["foodLevel"] ?? 0.0).toDouble(),
      foodWeight: (map["foodWeight"] ?? 0.0).toDouble(),
      lastPetDetected: map["lastPetDetected"] ?? "None",
      isOnline: map["isOnline"] ?? true,
    );
  }
}