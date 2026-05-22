# Smart Feeder — Entrega 1 (Beta Prototype)

Protótipo funcional do aplicativo Smart Pet Feeder, desenvolvido como base conceitual antes da integração com serviços externos.

## O que é esta entrega?

Esta é a **versão beta** do projeto — um ponto de partida que demonstra a arquitetura e o fluxo principal do app sem depender de infraestrutura externa. A Entrega 2 (alpha) é a versão completa e finalizada com todas as integrações.

## Diferenças em relação à Entrega 2

| Funcionalidade | Entrega 1 (Beta) | Entrega 2 (Alpha) |
|---|---|---|
| Autenticação | ❌ Sem login | ✅ Firebase Auth |
| Dados do alimentador | 🔄 Mock (simulado) | ✅ MQTT real (ESP32) |
| Histórico | 💾 Em memória | ✅ Cloud Firestore |
| Pets cadastrados | 💾 Em memória | ✅ Cloud Firestore |
| Persistência local | ❌ Sem cache | ✅ SharedPreferences |
| Configuração Wi-Fi | ❌ Não implementado | ✅ HTTP para ESP32 |
| Tema persistido | ❌ Reinicia no dark | ✅ Salvo em cache |

## Arquitetura

O projeto segue o padrão **MVVM** com `provider` para gerenciamento de estado — a mesma arquitetura da Entrega 2.

```
MockFeederService (dados simulados a cada 4s)
        │ Stream<FeederData>
        ▼
FeederViewModel (ChangeNotifier)
  - Resolve RFID → nome do pet (PetService em memória)
  - Rastreia consumo por sessão
  - Loga eventos no HistoryService (em memória)
        │ notifyListeners()
        ▼
DashboardView
  - Cards: nível de água, peso da ração, último pet
  - Botões: FEED NOW, TARE SCALE
  - Dialog de cadastro para tags RFID desconhecidas
```

## Como rodar

```bash
cd src/Entrega\ 1/Frontend/smart_feeder
flutter pub get
flutter run
```

Não é necessário configurar Firebase, MQTT ou qualquer serviço externo.

## Estrutura de arquivos

```
lib/
├── main.dart                        # Entry point — sem Firebase
├── core/
│   ├── constants/app_constants.dart
│   └── theme/app_theme.dart         # Tema dark/light (cyber green)
├── models/
│   ├── feeder_data.dart
│   ├── pet.dart
│   └── feeding_event.dart
├── services/
│   ├── feeder_service.dart          # Interface abstrata
│   ├── mock_feeder_service.dart     # Implementação simulada
│   ├── pet_service.dart             # CRUD em memória
│   └── history_service.dart        # Log em memória
├── view_models/
│   ├── feeder_view_model.dart
│   ├── history_view_model.dart
│   └── theme_view_model.dart
├── views/
│   ├── dashboard_view.dart
│   └── history_view.dart
└── widgets/
    ├── status_card.dart
    └── app_drawer.dart
```
