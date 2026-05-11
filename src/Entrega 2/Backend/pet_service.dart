import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_feeder/models/pet.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Pet?> getPetByRfid(String rfidTag) async {
    try {
      final doc = await _firestore.collection('pets').doc(rfidTag).get();
      if (doc.exists && doc.data() != null) {
        return Pet.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint("PetService: Error getting pet by RFID - $e");
    }
    return null;
  }

  Future<void> registerPet(Pet pet) async {
    try {
      await _firestore.collection('pets').doc(pet.rfidTag).set(pet.toMap());
    } catch (e) {
      debugPrint("PetService: Error registering pet - $e");
      rethrow;
    }
  }

  Future<List<Pet>> getAllPets() async {
    try {
      final snapshot = await _firestore.collection('pets').get();
      return snapshot.docs.map((doc) => Pet.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint("PetService: Error getting all pets - $e");
      return [];
    }
  }
}
