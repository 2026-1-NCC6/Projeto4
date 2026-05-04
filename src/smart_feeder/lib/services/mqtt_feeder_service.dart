import "dart:async";
import "dart:convert";
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
      print("MQTT Client: Connecting to ${AppConstants.mqttBroker}...");
      await _client.connect();

      _client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
        if (messages == null) return;
        
        final recMess = messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        if (messages[0].topic == AppConstants.topicWaterLevel) {
          _handleIncomingData(payload);
        }
      });
    } catch (e) {
      print("MQTT Client: Connection error - $e");
      _client.disconnect();
      if (!_connectionCompleter.isCompleted) {
        _connectionCompleter.completeError(e);
      }
    }
  }

  void _handleIncomingData(String payload) {
    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      _controller.add(FeederData.fromMap(data));
    } catch (e) {
      print("Error decoding MQTT JSON: $e");
    }
  }

  void _onConnected() {
    print("MQTT Client: CONNECTED!");
    _client.subscribe(AppConstants.topicWaterLevel, MqttQos.atMostOnce);
    if (!_connectionCompleter.isCompleted) {
      _connectionCompleter.complete();
    }
  }

  void _onDisconnected() {
    print("MQTT Client: DISCONNECTED");
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
  Future<void> triggerManualFeeding() async {
    try {
      await _ensureConnected();
      final builder = MqttClientPayloadBuilder();
      builder.addString("FEED");
      _client.publishMessage(
        AppConstants.topicCommand,
        MqttQos.atLeastOnce,
        builder.payload!,
      );
      print("MQTT Client: FEED command sent.");
    } catch (e) {
      print("Error triggering feeding: $e");
    }
  }
}
