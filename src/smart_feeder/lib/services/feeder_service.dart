import 'dart:async';
import 'package:smart_feeder/models/feeder_data.dart';

abstract class FeederService {
  Stream<FeederData> get feederDataStream;
  Future<void> triggerManualFeeding();
}

// Essa classe será trocada pela conexão real com o ESP32/MQTT futuramente
class MockFeederService implements FeederService {
  final _controller = StreamController<FeederData>.broadcast();
  FeederData _lastData = FeederData(
    foodLevel: 80.0,
    bowlWeight: 150.0,
    lastPetDetected: "Rex (RFID: 12345)",
    isOnline: true,
  );

  MockFeederService() {
    // Simula atualizações vindas do hardware
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _lastData = FeederData(
        foodLevel: (_lastData.foodLevel - 0.5).clamp(0, 100),
        bowlWeight: _lastData.bowlWeight + (timer.tick % 2 == 0 ? 5 : -5),
        lastPetDetected: timer.tick % 3 == 0 ? "Luna (RFID: 67890)" : "Rex (RFID: 12345)",
        isOnline: true,
      );
      _controller.add(_lastData);
    });
  }

  @override
  Stream<FeederData> get feederDataStream => _controller.stream;

  @override
  Future<void> triggerManualFeeding() async {
    // Simula comando via MQTT para o ESP32
    // ignore: avoid_print
    print('Service: Enviando comando de alimentação para o ESP32 via MQTT...');
  }
}
