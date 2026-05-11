import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class NetworkConfigService {
  static const String espIp = '192.168.4.1';
  static const String configEndpoint = 'http://$espIp/config';

  Future<bool> configureWifi(String ssid, String password) async {
    dev.log('Iniciando configuração de rede...', name: 'NetworkService');
    dev.log('SSID: $ssid', name: 'NetworkService');
    dev.log('Endpoint: $configEndpoint', name: 'NetworkService');

    try {
      final response = await http.post(
        Uri.parse(configEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'ssid': ssid,
          'pass': password,
        },
      ).timeout(const Duration(seconds: 15));

      dev.log('Resposta recebida: ${response.statusCode}', name: 'NetworkService');
      dev.log('Corpo da resposta: ${response.body}', name: 'NetworkService');

      return response.statusCode == 200;
    } catch (e) {
      dev.log('ERRO NA REQUISIÇÃO: $e', name: 'NetworkService', error: e);
      return false;
    }
  }
}
