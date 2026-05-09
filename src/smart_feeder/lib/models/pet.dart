class Pet {
  final String rfidTag;
  final String name;

  Pet({
    required this.rfidTag,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'rfidTag': rfidTag,
      'name': name,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      rfidTag: map['rfidTag'] ?? '',
      name: map['name'] ?? 'Unknown',
    );
  }
}
