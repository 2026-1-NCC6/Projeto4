import 'package:mqtt_client/mqtt_client.dart';

MqttClient getClient(String broker, String clientIdentifier) =>
    throw UnsupportedError('Cannot create a client without dart:html or dart:io');
