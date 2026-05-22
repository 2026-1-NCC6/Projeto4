import "dart:async";
import "package:smart_feeder/models/feeder_data.dart";

abstract class FeederService {
  Stream<FeederData> get feederDataStream;
  Future<void> tareScale();
  Future<void> calibrateScale(double knownWeight);
  Future<void> setCalibrationFactor(double factor);
}

