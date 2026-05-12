import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_feeder/models/feeder_data.dart';
import 'package:smart_feeder/models/feeding_event.dart';
import 'package:smart_feeder/models/pet.dart';
import 'package:smart_feeder/services/feeder_service.dart';
import 'package:smart_feeder/services/pet_service.dart';
import 'package:smart_feeder/services/history_service.dart';

/// ViewModel principal do dashboard.
/// Gerencia o estado do alimentador, resolução de RFID e registro de consumo.
class FeederViewModel extends ChangeNotifier {
  final FeederService _feederService;
  final PetService _petService;
  final HistoryService _historyService;
  StreamSubscription? _subscription;

  FeederData _currentData = FeederData(
    waterLevel: 0,
    foodWeight: 0,
    lastPetDetected: 'Carregando...',
    isOnline: false,
  );

  FeederData get currentData => _currentData;

  // Controle de sessão do pet ativo
  String? _activePetTag;
  String? _activePetName;
  double? _startFoodWeight;
  double? _startWaterLevel;

  // Tag pendente de cadastro
  String? _pendingRfidTag;
  String? get pendingRfidTag => _pendingRfidTag;

  bool _isRegistrationDialogOpen = false;
  bool get isRegistrationDialogOpen => _isRegistrationDialogOpen;

  void setRegistrationDialogOpen(bool value) {
    _isRegistrationDialogOpen = value;
  }

  FeederViewModel(this._feederService, this._petService, this._historyService) {
    _init();
  }

  void _init() {
    _subscription = _feederService.feederDataStream.listen((data) async {
      final rawTag = data.lastPetDetected;

      if (rawTag.isEmpty || rawTag == 'None') {
        // Pet saiu — registra consumo
        _handlePetLeft();
        _currentData = data;
        _pendingRfidTag = null;
      } else if (rawTag != _activePetTag && rawTag != _pendingRfidTag) {
        // Nova tag detectada
        _handlePetLeft();

        final pet = await _petService.getPetByRfid(rawTag);

        if (pet != null) {
          // Pet conhecido
          _activePetTag = rawTag;
          _activePetName = pet.name;
          _startFoodWeight = data.foodWeight;
          _startWaterLevel = data.waterLevel;
          _currentData = data.copyWith(lastPetDetected: pet.name);
          _pendingRfidTag = null;
        } else {
          // Pet desconhecido — aguarda cadastro
          _pendingRfidTag = rawTag;
          _currentData = data;
        }
      } else {
        // Mesma tag de antes
        final displayName = _activePetName ?? rawTag;
        _currentData = data.copyWith(lastPetDetected: displayName);
      }

      notifyListeners();
    });
  }

  void _handlePetLeft() {
    if (_activePetTag != null && _activePetName != null) {
      final foodConsumed = (_startFoodWeight ?? 0) - _currentData.foodWeight;
      final waterConsumed = (_startWaterLevel ?? 0) - _currentData.waterLevel;

      if (foodConsumed > 1.0) {
        _historyService.logEvent(FeedingEvent(
          petName: _activePetName!,
          amount: foodConsumed,
          type: ConsumptionType.food,
          timestamp: DateTime.now(),
        ));
      }

      if (waterConsumed > 0.5) {
        _historyService.logEvent(FeedingEvent(
          petName: _activePetName!,
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
      final tag = _pendingRfidTag!;
      await _petService.registerPet(Pet(rfidTag: tag, name: name));
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
    _handlePetLeft();
    _subscription?.cancel();
    super.dispose();
  }
}
