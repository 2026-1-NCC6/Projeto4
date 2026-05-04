import "dart:async";
import "package:flutter/material.dart";
import "package:smart_feeder/models/feeder_data.dart";
import "package:smart_feeder/services/feeder_service.dart";

class FeederViewModel extends ChangeNotifier {
  final FeederService _feederService;
  StreamSubscription? _subscription;

  FeederData _currentData = FeederData(
    waterLevel: 0,
    waterStatus: "Iniciando...",
    foodLevel: 0,
    foodWeight: 0,
    lastPetDetected: "Carregando...",
    isOnline: false,
  );

  FeederData get currentData => _currentData;

  FeederViewModel(this._feederService) {
    _init();
  }

  void _init() {
    _subscription = _feederService.feederDataStream.listen((data) {
      _currentData = data;
      notifyListeners();
    });
  }

  Future<void> triggerManualFeeding() async {
    await _feederService.triggerManualFeeding();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
