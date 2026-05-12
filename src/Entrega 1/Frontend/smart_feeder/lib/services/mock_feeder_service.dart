import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:smart_feeder/models/feeder_data.dart';
import 'package:smart_feeder/services/feeder_service.dart';

/// Implementação mock do FeederService.
/// Simula dados do alimentador sem precisar de hardware ou MQTT.
/// Esta é a única implementação disponível na Entrega 1.
class MockFeederService implements FeederService {
  final _controller = StreamController<FeederData>.broadcast();
  final _random = Random();

  FeederData _currentData = FeederData(
    waterLevel: 72.0,
    foodWeight: 180.0,
    lastPetDetected: 'None',
    isOnline: true,
  );

  // Tags RFID simuladas para demonstração
  static const List<String> _simulatedTags = ['TAG_001', 'TAG_002', 'None'];
  int _tagCycle = 0;

  MockFeederService() {
    // Emite dados a cada 4 segundos simulando o ESP32
    Timer.periodic(const Duration(seconds: 4), _emitData);
  }

  void _emitData(Timer timer) {
    // Simula variação natural nos sensores
    final newWater = (_currentData.waterLevel - _random.nextDouble() * 0.5)
        .clamp(0.0, 100.0);
    final newFood = (_currentData.foodWeight + (_random.nextBool() ? 2.0 : -3.0))
        .clamp(0.0, 500.0);

    // Cicla entre pets simulados a cada ~20 segundos
    if (timer.tick % 5 == 0) {
      _tagCycle = (_tagCycle + 1) % _simulatedTags.length;
    }

    _currentData = FeederData(
      waterLevel: newWater,
      foodWeight: newFood,
      lastPetDetected: _simulatedTags[_tagCycle],
      isOnline: true,
    );

    _controller.add(_currentData);
  }

  @override
  Stream<FeederData> get feederDataStream => _controller.stream;

  @override
  Future<void> triggerManualFeeding() async {
    debugPrint('[MockFeeder] Comando FEED enviado (simulado)');
    // Simula a ração sendo dispensada: aumenta o peso
    _currentData = _currentData.copyWith(
      foodWeight: (_currentData.foodWeight + 30.0).clamp(0.0, 500.0),
    );
    _controller.add(_currentData);
  }

  @override
  Future<void> tareScale() async {
    debugPrint('[MockFeeder] Comando TARE enviado (simulado)');
    // Simula a tara: zera o peso
    _currentData = _currentData.copyWith(foodWeight: 0.0);
    _controller.add(_currentData);
  }

  void dispose() {
    _controller.close();
  }
}
