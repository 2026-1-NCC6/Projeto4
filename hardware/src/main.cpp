#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <SPI.h>
#include <MFRC522.h>
#include <HX711.h>
#include <EEPROM.h>

// --- CONFIGURAÇÃO DE PINOS ---
#define RST_RFID    16  // D0
#define SS_RFID     15  // D8
#define HX711_DT     4  // D2
#define HX711_SCK    5  // D1
#define WATER_PIN    A0

#define EEPROM_SIZE 64 

WiFiClient espClient;
PubSubClient client(espClient);
MFRC522 rfid(SS_RFID, RST_RFID);
HX711 scale;

// --- CONFIGURAÇÕES DE REDE ---
const char* ssid = "Galaxy A55 5G F804";
const char* password = "hww8zs6rravjqcx";
const char* mqtt_server = "broker.emqx.io";

// --- VARIÁVEIS DE ESTADO E CALIBRAÇÃO ---
String tagAtual = "None";
bool petPresente = false;
unsigned long tempoUltimaVerificacao = 0;
const long intervaloVerificacao = 500; 

float pesoInicialComida = 0;
int nivelInicialAgua = 0;

// Estrutura para salvar na memória flash do ESP
struct Configs {
  float fatorCalibracao;
} configs;

// --- FUNÇÕES DE MEMÓRIA (EEPROM) ---
void carregarConfiguracoes() {
  EEPROM.begin(EEPROM_SIZE);
  EEPROM.get(0, configs);
  
  if (isnan(configs.fatorCalibracao) || configs.fatorCalibracao == 0) {
    configs.fatorCalibracao = 420.0;
  }
  Serial.printf("[MEMÓRIA] Fator de calibração carregado: %.2f\n", configs.fatorCalibracao);
}

void salvarConfiguracoes() {
  EEPROM.put(0, configs);
  EEPROM.commit();
  Serial.println("[MEMÓRIA] Fator salvo com sucesso!");
}

// --- CALLBACK PARA RECEBER COMANDOS DO APP ---
void callback(char* topic, byte* payload, unsigned int length) {
  String message = "";
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  
  Serial.println("\n[MQTT] Comando recebido: " + message);

  if (message == "TARE") {
    if (scale.is_ready()) {
      scale.tare(10);
      Serial.println("[BALANÇA] Tara realizada!");
    } else {
      Serial.println("[BALANÇA] Erro: Sensor não está pronto para tara.");
    }
  } 
  else if (message.startsWith("CALIBRATE:")) {
    float pesoConhecido = message.substring(10).toFloat();
    if (pesoConhecido > 0 && scale.is_ready()) {
      long leituraBruta = scale.get_value(10); 
      configs.fatorCalibracao = (float)leituraBruta / pesoConhecido;
      scale.set_scale(configs.fatorCalibracao);
      salvarConfiguracoes();
      Serial.printf("[BALANÇA] Calibrado com peso %.2fg. Novo Fator: %.2f\n", pesoConhecido, configs.fatorCalibracao);
    } else {
      Serial.println("[BALANÇA] Erro: Sensor não pronto ou peso inválido.");
    }
  }
  else if (message.startsWith("SET_FACTOR:")) {
    float novoFator = message.substring(11).toFloat();
    if (novoFator != 0) {
      configs.fatorCalibracao = novoFator;
      scale.set_scale(configs.fatorCalibracao);
      salvarConfiguracoes();
      Serial.printf("[BALANÇA] Fator manual aplicado: %.2f\n", configs.fatorCalibracao);
    }
  }
}

// --- CONEXÃO MQTT ---
void reconnect() {
  while (!client.connected()) {
    Serial.print("[MQTT] Tentando conexão...");
    String clientId = "SmartFeeder-" + String(ESP.getChipId());
    
    if (client.connect(clientId.c_str())) {
      Serial.println(" Conectado com sucesso!");
      client.subscribe("smartfeeder/command");
    } else {
      Serial.print(" Falhou, rc=");
      Serial.print(client.state());
      Serial.println(" Tentando novamente em 5 segundos...");
      for(int i = 0; i < 500; i++) {
        delay(10);
        yield();
      }
    }
  }
}

// --- CONFIGURAÇÃO INICIAL ---
void setup() {
  Serial.begin(115200);
  delay(50);
  Serial.println("\n\n--- INICIALIZANDO SMART FEEDER ---");
  
  carregarConfiguracoes();
  
  Serial.printf("[WIFI] Conectando a rede: %s ", ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    yield();
  }
  Serial.println("\n[WIFI] WiFi Conectado com sucesso!");
  
  Serial.println("[RFID] Inicializando leitor MFRC522...");
  SPI.begin();
  rfid.PCD_Init();
  
  Serial.println("[BALANÇA] Inicializando módulo HX711...");
  scale.begin(HX711_DT, HX711_SCK);
  Serial.println("[BALANÇA] Aguardando estabilização do sensor...");
  delay(1000); 
  
  scale.set_scale(configs.fatorCalibracao);
  if (scale.is_ready()) {
    scale.read();
    scale.read();
    scale.tare(20);
    Serial.println("[BALANÇA] Sensor estabilizado e tarado com sucesso!");
  } else {
    Serial.println("[ERRO] HX711 não encontrado! Verifique as conexões físicas.");
  }
  
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
  Serial.println("-----------------------------------\n");
}

// --- FUNÇÃO AUXILIAR: VERIFICAR PRESENÇA RFID ---
bool verificarPresencaTag() {
  MFRC522::StatusCode status;
  byte bufferATQA[2];
  byte bufferSize = sizeof(bufferATQA);

  status = rfid.PICC_WakeupA(bufferATQA, &bufferSize);
  if (status == MFRC522::STATUS_OK) {
    if (rfid.PICC_ReadCardSerial()) {
      return true;
    }
  }
  return false;
}

// --- FUNÇÃO PARA ATUALIZAR O DASHBOARD ---
void enviarStatusMQTT() {
  // 'static' guarda o último valor lido para não enviar zero se a balança estiver ocupada
  static long ultimoValorBruto = 0;
  static int ultimoPesoCalculado = 0;
  
  if (scale.is_ready()) {
    ultimoValorBruto = scale.get_value(1); // 1 leitura rápida
    ultimoPesoCalculado = (int)scale.get_units(1); 
  }
  
  int aguaAtual = analogRead(WATER_PIN);
  
  StaticJsonDocument<256> statusDoc;
  statusDoc["currentWater"] = aguaAtual;
  statusDoc["currentFood"] = ultimoPesoCalculado; 
  statusDoc["petPresent"] = petPresente;
  statusDoc["lastTag"] = tagAtual;
  
  statusDoc["calibrationFactor"] = configs.fatorCalibracao;
  statusDoc["rawWeight"] = ultimoValorBruto; 
  
  char statusBuffer[256];
  serializeJson(statusDoc, statusBuffer);
  client.publish("smartfeeder/status", statusBuffer);
}

// --- LOOP PRINCIPAL ---
void loop() {
  yield(); 

  if (!client.connected()) {
    reconnect();
  }
  client.loop(); 

  // 1. DETECÇÃO DE ENTRADA
  if (!petPresente) {
    if (rfid.PICC_IsNewCardPresent() && rfid.PICC_ReadCardSerial()) {
      String leitura = "";
      for (byte i = 0; i < rfid.uid.size; i++) {
        leitura += String(rfid.uid.uidByte[i] < 0x10 ? "0" : "");
        leitura += String(rfid.uid.uidByte[i], HEX);
      }
      leitura.toUpperCase();

      tagAtual = leitura;
      petPresente = true;
      
      Serial.println("\n===================================");
      Serial.printf("[SESSÃO] Pet Detectado! Tag RFID: %s\n", tagAtual.c_str());
      
      delay(50); 
      
      long timeout = millis() + 500; 
      while (!scale.is_ready() && millis() < timeout) {
        delay(1);
        yield();
      }

      if (scale.is_ready()) {
        pesoInicialComida = scale.get_units(3); 
        Serial.printf("[BALANÇA] Peso Inicial registrado: %.2fg\n", pesoInicialComida);
      } else {
        pesoInicialComida = 0;
        Serial.println("[BALANÇA] Erro: Sensor indisponível no momento (Timeout).");
      }
      
      nivelInicialAgua = analogRead(WATER_PIN);
      Serial.printf("[SENSOR ÁGUA] Nível Inicial registrado: %d\n", nivelInicialAgua);
      Serial.println("===================================\n");
      
      enviarStatusMQTT();
    }
  } 
  
  // 2. MONITORAMENTO DE SAÍDA
  else {
    if (millis() - tempoUltimaVerificacao > intervaloVerificacao) {
      tempoUltimaVerificacao = millis();
      
      // Checagem principal
      if (!verificarPresencaTag()) {
        delay(20); // Fôlego contra ruído de RF
        
        // Dupla checagem (Filtro para evitar piscar o status do Pet)
        if (!verificarPresencaTag()) {
          float pesoFinal = 0;
          if (scale.is_ready()) {
            pesoFinal = scale.get_units(3);
          }
          
          int nivelFinal = analogRead(WATER_PIN);
          float consumoComida = pesoInicialComida - pesoFinal;
          int consumoAgua = nivelInicialAgua - nivelFinal;

          if (consumoComida < 0) consumoComida = 0;
          if (consumoAgua < 0) consumoAgua = 0;

          Serial.println("\n===================================");
          Serial.printf("[SESSÃO] Pet [Tag: %s] se afastou.\n", tagAtual.c_str());
          Serial.printf("[CONSUMO] Comida: %.2fg (Restou: %.2fg)\n", consumoComida, pesoFinal);
          Serial.printf("[CONSUMO] Água consumida: %d unidades (Nível atual: %d)\n", consumoAgua, nivelFinal);

          StaticJsonDocument<256> logDoc;
          logDoc["event"] = "session_end";
          logDoc["tag"] = tagAtual;
          logDoc["food_consumed"] = consumoComida;
          logDoc["water_consumed"] = consumoAgua;
          
          char logBuffer[256];
          serializeJson(logDoc, logBuffer);
          client.publish("smartfeeder/logs", logBuffer);
          Serial.println("[MQTT] Dados da sessão enviados para 'smartfeeder/logs'.");
          Serial.println("===================================\n");

          tagAtual = "None";
          petPresente = false;
          
          enviarStatusMQTT();
        }
      }
    }
  }

  // 3. TELEMETRIA DE ESTADO (Pulso contínuo)
  static unsigned long lastMsg = 0;
  if (millis() - lastMsg > 3000) {
    lastMsg = millis();
    enviarStatusMQTT();
  }
}