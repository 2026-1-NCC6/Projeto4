// lib/services/mqtt_setup/mqtt_setup_web.dart
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

MqttClient getClient(String broker, String clientIdentifier) {
  final client = MqttBrowserClient('ws://broker.emqx.io/mqtt', clientIdentifier);
  client.port = 8083;
  
  // IMPORTANTE: Adicione esta linha para compatibilidade com HiveMQ WebSockets
  client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
  
  return client;
}