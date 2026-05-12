/// Representa o estado atual do alimentador inteligente.
/// Na Entrega 1, todos os dados são mockados localmente.
class FeederData {
  final double waterLevel;   // 0–100%
  final double foodWeight;   // gramas
  final String lastPetDetected;
  final bool isOnline;

  FeederData({
    required this.waterLevel,
    required this.foodWeight,
    required this.lastPetDetected,
    required this.isOnline,
  });

  FeederData copyWith({
    double? waterLevel,
    double? foodWeight,
    String? lastPetDetected,
    bool? isOnline,
  }) {
    return FeederData(
      waterLevel: waterLevel ?? this.waterLevel,
      foodWeight: foodWeight ?? this.foodWeight,
      lastPetDetected: lastPetDetected ?? this.lastPetDetected,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
