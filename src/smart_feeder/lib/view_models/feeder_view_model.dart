import "dart:async";
import "package:flutter/material.dart";
import "package:smart_feeder/models/feeder_data.dart";
import "package:smart_feeder/models/pet.dart";
import "package:smart_feeder/services/feeder_service.dart";
import "package:smart_feeder/services/pet_service.dart";

class FeederViewModel extends ChangeNotifier {
  final FeederService _feederService;
  final PetService _petService;
  StreamSubscription? _subscription;

  FeederData _currentData = FeederData(
    waterLevel: 0,
    waterStatus: "Iniciando...",
    foodWeight: 0,
    lastPetDetected: "Carregando...",
    isOnline: false,
  );

  String? _pendingRfidTag;
  String? get pendingRfidTag => _pendingRfidTag;

  FeederData get currentData => _currentData;

  FeederViewModel(this._feederService, this._petService) {
    _init();
  }

  bool _isRegistrationDialogOpen = false;
  bool get isRegistrationDialogOpen => _isRegistrationDialogOpen;

  void setRegistrationDialogOpen(bool isOpen) {
    _isRegistrationDialogOpen = isOpen;
    // Não chamamos notifyListeners aqui para evitar loops de build se chamado no build
  }

  void _init() {
    _subscription = _feederService.feederDataStream.listen((data) async {
      String rawTag = data.lastPetDetected;
      
      // Se a tag sumiu ou é inválida
      if (rawTag.isEmpty || rawTag == "None" || rawTag == "Carregando...") {
        _currentData = data;
        _pendingRfidTag = null;
        notifyListeners();
        return;
      }

      // Se a tag mudou ou se é a primeira vez que recebemos uma tag
      if (rawTag != _currentData.lastPetDetected && rawTag != _pendingRfidTag) {
        Pet? pet = await _petService.getPetByRfid(rawTag);
        
        if (pet != null) {
          // Pet conhecido!
          _currentData = data.copyWith(lastPetDetected: pet.name);
          _pendingRfidTag = null;
        } else {
          // Pet novo!
          _pendingRfidTag = rawTag;
          _currentData = data;
        }
      } else {
        // Tag é a mesma de antes, apenas atualizamos o resto dos dados (peso, água)
        // Mas mantemos o nome amigável se já tínhamos um
        String displayName = _pendingRfidTag != null ? rawTag : _currentData.lastPetDetected;
        _currentData = data.copyWith(lastPetDetected: displayName);
      }
      
      notifyListeners();
    });
  }

  Future<void> registerPet(String name) async {
    if (_pendingRfidTag != null) {
      final tagToRegister = _pendingRfidTag!;
      await _petService.registerPet(Pet(rfidTag: tagToRegister, name: name));
      
      // Limpa a pendência ANTES de notificar para o dialog fechar e não reabrir
      _pendingRfidTag = null;
      _currentData = _currentData.copyWith(lastPetDetected: name);
      notifyListeners();
    }
  }

  void clearPendingTag() {
    _pendingRfidTag = null;
    notifyListeners();
  }

  Future<void> triggerManualFeeding() async {
    await _feederService.triggerManualFeeding();
  }

  Future<void> tareScale() async {
    await _feederService.tareScale();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Helper to update FeederData without rewriting everything
extension FeederDataExtension on FeederData {
  FeederData copyWith({
    double? waterLevel,
    String? waterStatus,
    double? foodWeight,
    String? lastPetDetected,
    bool? isOnline,
  }) {
    return FeederData(
      waterLevel: waterLevel ?? this.waterLevel,
      waterStatus: waterStatus ?? this.waterStatus,
      foodWeight: foodWeight ?? this.foodWeight,
      lastPetDetected: lastPetDetected ?? this.lastPetDetected,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
