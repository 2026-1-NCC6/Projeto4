class AppConstants {
  // MQTT Configuration
  static const String mqttBroker = "broker.emqx.io";
  static const int mqttPort = 1883; // Standard MQTT port
  static const int mqttWsPort = 8083; // Standard WebSocket port
  
  // MQTT Topics
  static const String topicWaterLevel = "smartfeeder/water_level";
  static const String topicCommand = "smartfeeder/command";
  
  // App Strings
  static const String appName = "SMART FEEDER";
  static const String appVersion = "v1.0.0";
}
