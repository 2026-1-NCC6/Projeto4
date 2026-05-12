import 'package:smart_feeder/models/pet.dart';

/// Serviço de gerenciamento de pets.
/// Na Entrega 1, os dados ficam apenas em memória (sem Firestore).
/// Na Entrega 2, este serviço foi substituído por uma versão com Firebase.
class PetService {
  // Banco de dados em memória — pré-populado com pets de exemplo
  final Map<String, Pet> _pets = {
    'TAG_001': Pet(rfidTag: 'TAG_001', name: 'Rex'),
    'TAG_002': Pet(rfidTag: 'TAG_002', name: 'Mia'),
  };

  /// Busca um pet pelo RFID. Retorna null se não cadastrado.
  Future<Pet?> getPetByRfid(String rfidTag) async {
    return _pets[rfidTag];
  }

  /// Retorna todos os pets cadastrados.
  Future<List<Pet>> getAllPets() async {
    return _pets.values.toList();
  }

  /// Cadastra um novo pet.
  Future<void> registerPet(Pet pet) async {
    _pets[pet.rfidTag] = pet;
  }
}
