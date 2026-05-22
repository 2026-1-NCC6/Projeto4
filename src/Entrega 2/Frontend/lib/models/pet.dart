class Pet {
  final String rfidTag;
  final String name;
  final double expectedFoodPerDay; // in grams
  final double expectedWaterPerDay; // in % drop or milliliters (let's stick to grams/units)

  Pet({
    required this.rfidTag,
    required this.name,
    this.expectedFoodPerDay = 200.0,
    this.expectedWaterPerDay = 50.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'rfidTag': rfidTag,
      'name': name,
      'expectedFoodPerDay': expectedFoodPerDay,
      'expectedWaterPerDay': expectedWaterPerDay,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      rfidTag: map['rfidTag'] ?? '',
      name: map['name'] ?? 'Unknown',
      expectedFoodPerDay: (map['expectedFoodPerDay'] ?? 200.0).toDouble(),
      expectedWaterPerDay: (map['expectedWaterPerDay'] ?? 50.0).toDouble(),
    );
  }
}
