import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/services/mock_feeder_service.dart';
import 'package:smart_feeder/services/pet_service.dart';
import 'package:smart_feeder/services/history_service.dart';
import 'package:smart_feeder/view_models/feeder_view_model.dart';
import 'package:smart_feeder/view_models/history_view_model.dart';
import 'package:smart_feeder/view_models/theme_view_model.dart';
import 'package:smart_feeder/views/dashboard_view.dart';

/// Entrega 1 — Protótipo Beta do Smart Feeder
///
/// Diferenças em relação à Entrega 2 (Alpha):
/// - Sem Firebase (sem autenticação, sem Firestore)
/// - Sem MQTT real — usa MockFeederService com dados simulados
/// - Sem persistência local (sem SharedPreferences)
/// - Sem tela de login/registro
/// - Histórico e pets ficam apenas em memória
///
/// O objetivo é demonstrar a arquitetura MVVM e o fluxo principal
/// do app antes de integrar os serviços externos.
void main() {
  final feederService = MockFeederService();
  final petService = PetService();
  final historyService = HistoryService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(
          create: (_) => FeederViewModel(feederService, petService, historyService),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryViewModel(historyService, petService),
        ),
      ],
      child: const SmartFeederApp(),
    ),
  );
}

class SmartFeederApp extends StatelessWidget {
  const SmartFeederApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Pet Feeder',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeVM.themeMode,
      // Na Entrega 1 não há login — vai direto para o dashboard
      home: const DashboardView(),
    );
  }
}
