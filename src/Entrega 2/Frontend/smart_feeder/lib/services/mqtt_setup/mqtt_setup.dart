import 'package:mqtt_client/mqtt_client.dart';
import 'mqtt_setup_stub.dart'
    if (dart.library.io) 'mqtt_setup_io.dart'
    if (dart.library.html) 'mqtt_setup_web.dart';

MqttClient createMqttClient(String broker, String clientIdentifier) =>
    getClient(broker, clientIdentifier);
