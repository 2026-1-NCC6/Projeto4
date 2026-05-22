import 'package:cloud_firestore/cloud_firestore.dart';

enum ConsumptionType { food, water }

class FeedingEvent {
  final String? id;
  final String petName;
  final String rfidTag;
  final double amount; // Weight in grams or Level in %
  final ConsumptionType type;
  final DateTime timestamp;

  FeedingEvent({
    this.id,
    required this.petName,
    required this.rfidTag,
    required this.amount,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'petName': petName,
      'rfidTag': rfidTag,
      'amount': amount,
      'type': type.index,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory FeedingEvent.fromMap(Map<String, dynamic> map, String id) {
    return FeedingEvent(
      id: id,
      petName: map['petName'] ?? 'Unknown',
      rfidTag: map['rfidTag'] ?? 'Unknown',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: ConsumptionType.values[map['type'] ?? 0],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
