import "dart:async";
import "package:flutter/material.dart";
import "package:smart_feeder/models/feeder_data.dart";
import "package:smart_feeder/models/pet.dart";
import "package:smart_feeder/models/feeding_event.dart";
import "package:smart_feeder/services/feeder_service.dart";
import "package:smart_feeder/services/pet_service.dart";
import "package:smart_feeder/services/cache_service.dart";
import "package:smart_feeder/services/history_service.dart";

class FeederViewModel extends ChangeNotifier {
  final FeederService _feederService;
  final PetService _petService;
  final CacheService _cacheService;
  final HistoryService _historyService;
  StreamSubscription? _subscription;

  FeederData _currentData;
  
  // Tracking consumption
  String? _activePetTag;
  String? _activePetName;
  double? _startFoodWeight;
  double? _startWaterLevel;

  String? _pendingRfidTag;
  String? get pendingRfidTag => _pendingRfidTag;

  FeederData get currentData => _currentData;

  FeederViewModel(this._feederService, this._petService, this._cacheService, this._historyService)
      : _currentData = _cacheService.getCachedFeederData() ??
            FeederData(
              waterLevel: 0,
              waterStatus: "Iniciando...",
              foodWeight: 0,
              lastPetDetected: "Carregando...",
              isOnline: false,
            ) {
    _init();
  }

  bool _isRegistrationDialogOpen = false;
  bool get isRegistrationDialogOpen => _isRegistrationDialogOpen;

  void setRegistrationDialogOpen(bool isOpen) {
    _isRegistrationDialogOpen = isOpen;
  }

  void _init() {
    _subscription = _feederService.feederDataStream.listen((data) async {
      String rawTag = data.lastPetDetected;
      
      // Se a tag sumiu ou é inválida
      if (rawTag.isEmpty || rawTag == "None" || rawTag == "Carregando...") {
        _handlePetLeft();
        _currentData = data;
        _pendingRfidTag = null;
      } else if (rawTag != _activePetTag && rawTag != _pendingRfidTag) {
        // Se a tag mudou ou se é a primeira vez que recebemos uma tag
        _handlePetLeft(); // Close previous session if any
        
        Pet? pet = await _petService.getPetByRfid(rawTag);
        
        if (pet != null) {
          // Pet conhecido!
          _activePetTag = rawTag;
          _activePetName = pet.name;
          _startFoodWeight = data.foodWeight;
          _startWaterLevel = data.waterLevel;
          
          _currentData = data.copyWith(lastPetDetected: pet.name);
          _pendingRfidTag = null;
        } else {
          // Pet novo!
          _pendingRfidTag = rawTag;
          _currentData = data;
        }
      } else {
        // Tag é a mesma de antes
        String displayName = _pendingRfidTag != null ? rawTag : (_activePetName ?? _currentData.lastPetDetected);
        _currentData = data.copyWith(lastPetDetected: displayName);
      }
      
      _cacheService.cacheFeederData(_currentData);
      notifyListeners();
    });
  }

  void _handlePetLeft() {
    if (_activePetTag != null && _activePetName != null) {
      double foodConsumed = (_startFoodWeight ?? 0) - _currentData.foodWeight;
      double waterConsumed = (_startWaterLevel ?? 0) - _currentData.waterLevel;

      // Only log if significant consumption occurred (> 1g or > 0.5%)
      if (foodConsumed > 1.0) {
        _historyService.logEvent(FeedingEvent(
          petName: _activePetName!,
          rfidTag: _activePetTag!,
          amount: foodConsumed,
          type: ConsumptionType.food,
          timestamp: DateTime.now(),
        ));
      }

      if (waterConsumed > 0.5) {
        _historyService.logEvent(FeedingEvent(
          petName: _activePetName!,
          rfidTag: _activePetTag!,
          amount: waterConsumed,
          type: ConsumptionType.water,
          timestamp: DateTime.now(),
        ));
      }
    }

    _activePetTag = null;
    _activePetName = null;
    _startFoodWeight = null;
    _startWaterLevel = null;
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
    _handlePetLeft(); // Finalize any active session before disposing
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
