import "dart:async";
import "package:flutter/foundation.dart";
import "package:smart_feeder/models/feeder_data.dart";
import "package:smart_feeder/services/feeder_service.dart";

class MockFeederService implements FeederService {
  final _controller = StreamController<FeederData>.broadcast();
  FeederData _lastData = FeederData(
    waterLevel: 45.0,
    waterStatus: "WATER_DETECTED",
    foodWeight: 150.0,
    lastPetDetected: "Rex (RFID: 12345)",
    isOnline: true,
  );

  MockFeederService() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _lastData = FeederData(
        waterLevel: 45.0,
        waterStatus: "WATER_DETECTED",
        foodWeight: _lastData.foodWeight + (timer.tick % 2 == 0 ? 5 : -5),
        lastPetDetected: timer.tick % 3 == 0 ? "None" : "Rex (RFID: 12345)",
        isOnline: true,
      );
      _controller.add(_lastData);
    });
  }

  @override
  Stream<FeederData> get feederDataStream => _controller.stream;

  @override
  Future<void> triggerManualFeeding() async {
    debugPrint("Service: Sending feeding command (MOCK)...");
  }

  @override
  Future<void> tareScale() async {
    debugPrint("Service: Sending TARE command (MOCK)...");
  }
}
