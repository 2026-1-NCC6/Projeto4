import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

MqttClient getClient(String broker, String clientIdentifier) {
  return MqttServerClient(broker, clientIdentifier);
}
