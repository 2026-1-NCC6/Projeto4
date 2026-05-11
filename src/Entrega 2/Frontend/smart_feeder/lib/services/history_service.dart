import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_feeder/models/feeding_event.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logEvent(FeedingEvent event) async {
    await _firestore.collection('feeding_history').add(event.toMap());
  }

  Stream<List<FeedingEvent>> getHistoryStream() {
    return _firestore
        .collection('feeding_history')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FeedingEvent.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<List<FeedingEvent>> getEventsByPet(String rfidTag) async {
    final snapshot = await _firestore
        .collection('feeding_history')
        .where('rfidTag', isEqualTo: rfidTag)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return FeedingEvent.fromMap(doc.data(), doc.id);
    }).toList();
  }
}
