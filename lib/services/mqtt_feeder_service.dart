import "dart:async";
import "dart:convert";
import "package:flutter/foundation.dart";
import "package:mqtt_client/mqtt_client.dart";
import "package:smart_feeder/core/constants/app_constants.dart";
import "package:smart_feeder/models/feeder_data.dart";
import "package:smart_feeder/services/feeder_service.dart";
import "package:smart_feeder/services/mqtt_setup/mqtt_setup.dart";

class MqttFeederService implements FeederService {
  final MqttClient _client;
  final _controller = StreamController<FeederData>.broadcast();
  Completer<void> _connectionCompleter = Completer<void>();

  MqttFeederService()
      : _client = createMqttClient(
          AppConstants.mqttBroker,
          "flutter_client_${DateTime.now().millisecondsSinceEpoch}",
        ) {
    _init();
  }

  Future<void> _init() async {
    _client.onDisconnected = _onDisconnected;
    _client.onConnected = _onConnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(_client.clientIdentifier)
        .startClean();
    _client.connectionMessage = connMess;

    try {
      debugPrint("MQTT Client: Connecting to ${AppConstants.mqttBroker}...");
      await _client.connect();

      _client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
        if (messages == null) return;
        
        final recMess = messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        if (messages[0].topic == AppConstants.topicStatus) {
          _handleIncomingData(payload);
        }
      });
    } catch (e) {
      debugPrint("MQTT Client: Connection error - $e");
      _client.disconnect();
      if (!_connectionCompleter.isCompleted) {
        _connectionCompleter.completeError(e);
      }
    }
  }

  void _handleIncomingData(String payload) {
    debugPrint("MQTT RECV [${AppConstants.topicStatus}]: $payload");
    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      final feederData = FeederData.fromMap(data);
      debugPrint("MQTT DECODED: Online=${feederData.isOnline}, Food=${feederData.foodWeight}g, Water=${feederData.waterLevel}%");
      _controller.add(feederData);
    } catch (e) {
      debugPrint("Error decoding MQTT JSON: $e");
    }
  }

  void _onConnected() {
    debugPrint("MQTT STATUS: CONNECTED to Broker");
    _client.subscribe(AppConstants.topicStatus, MqttQos.atMostOnce);
    if (!_connectionCompleter.isCompleted) {
      _connectionCompleter.complete();
    }
  }

  void _onDisconnected() {
    debugPrint("MQTT STATUS: DISCONNECTED from Broker");
    _controller.add(FeederData(
      waterLevel: 0,
      foodWeight: 0,
      lastPetDetected: "Desconectado",
      isOnline: false,
    ));
    if (_connectionCompleter.isCompleted) {
      _connectionCompleter = Completer<void>();
    }
  }

  @override
  Stream<FeederData> get feederDataStream => _controller.stream;

  Future<void> _ensureConnected() async {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) return;
    
    if (_client.connectionStatus?.state == MqttConnectionState.connecting) {
      await _connectionCompleter.future;
      return;
    }
    
    _connectionCompleter = Completer<void>();
    await _client.connect();
    await _connectionCompleter.future;
  }

  @override
  Future<void> tareScale() async {
    try {
      await _ensureConnected();
      final builder = MqttClientPayloadBuilder();
      builder.addString("TARE");
      _client.publishMessage(
        AppConstants.topicCommand,
        MqttQos.atLeastOnce,
        builder.payload!,
      );
      debugPrint("MQTT Client: TARE command sent.");
    } catch (e) {
      debugPrint("Error taring scale: $e");
    }
  }

  @override
  Future<void> calibrateScale(double knownWeight) async {
    try {
      await _ensureConnected();
      final builder = MqttClientPayloadBuilder();
      builder.addString("CALIBRATE:$knownWeight");
      _client.publishMessage(
        AppConstants.topicCommand,
        MqttQos.atLeastOnce,
        builder.payload!,
      );
      debugPrint("MQTT Client: CALIBRATE command sent with weight $knownWeight.");
    } catch (e) {
      debugPrint("Error sending calibration command: $e");
    }
  }

  @override
  Future<void> setCalibrationFactor(double factor) async {
    try {
      await _ensureConnected();
      final builder = MqttClientPayloadBuilder();
      builder.addString("SET_FACTOR:$factor");
      _client.publishMessage(
        AppConstants.topicCommand,
        MqttQos.atLeastOnce,
        builder.payload!,
      );
      debugPrint("MQTT Client: SET_FACTOR command sent: $factor.");
    } catch (e) {
      debugPrint("Error sending set factor command: $e");
    }
  }
}
