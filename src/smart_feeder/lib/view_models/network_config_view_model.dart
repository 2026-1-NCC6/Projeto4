import 'package:flutter/material.dart';
import '../services/network_config_service.dart';

class NetworkConfigViewModel extends ChangeNotifier {
  final NetworkConfigService _service = NetworkConfigService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  Future<void> configureNetwork(String ssid, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final success = await _service.configureWifi(ssid, password);
      if (success) {
        _isSuccess = true;
      } else {
        _errorMessage = 'Falha ao enviar configuração. Verifique se está conectado à rede "SmartFeeder_Setup".';
      }
    } catch (e) {
      _errorMessage = 'Ocorreu um erro: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }
}
