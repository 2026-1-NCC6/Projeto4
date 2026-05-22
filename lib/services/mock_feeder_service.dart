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
      final newFoodWeight = (_lastData.foodWeight - (timer.tick % 8 == 0 ? 2.5 : 0)).clamp(0.0, 5000.0);
      final newWaterLevel = (_lastData.waterLevel - (timer.tick % 12 == 0 ? 1.0 : 0)).clamp(0.0, 100.0);
      
      String nextTag = "None";
      if (timer.tick % 15 < 10) {
        nextTag = (timer.tick % 30 < 15) ? "12345" : "67890";
      }

      _lastData = FeederData(
        waterLevel: newWaterLevel,
        waterStatus: newWaterLevel > 5 ? "WATER_DETECTED" : "DRY",
        foodWeight: newFoodWeight,
        lastPetDetected: nextTag,
        isOnline: true,
      );
      _controller.add(_lastData);
    });
  }

  @override
  Stream<FeederData> get feederDataStream => _controller.stream;

  @override
  Future<void> tareScale() async {
    debugPrint("Service: Sending TARE command (MOCK)...");
  }

  @override
  Future<void> calibrateScale(double knownWeight) async {
    debugPrint("Service: Sending CALIBRATE command ($knownWeight) (MOCK)...");
  }

  @override
  Future<void> setCalibrationFactor(double factor) async {
    debugPrint("Service: Setting Manual Factor ($factor) (MOCK)...");
  }
}
