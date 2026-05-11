import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:smart_feeder/services/mqtt_feeder_service.dart';
import 'package:smart_feeder/services/cache_service.dart';
import 'package:smart_feeder/services/history_service.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/view_models/feeder_view_model.dart';
import 'package:smart_feeder/view_models/auth_view_model.dart';
import 'package:smart_feeder/view_models/history_view_model.dart';
import 'package:smart_feeder/view_models/network_config_view_model.dart';
import 'package:smart_feeder/views/dashboard_view.dart';
import 'package:smart_feeder/views/login_view.dart';
import 'package:smart_feeder/view_models/theme_view_model.dart';
import 'package:smart_feeder/services/pet_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final cacheService = CacheService(prefs);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final feederService = MqttFeederService();
  final petService = PetService();
  final historyService = HistoryService();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: cacheService),
        Provider.value(value: historyService),
        ChangeNotifierProvider(create: (_) => ThemeViewModel(cacheService)),
        ChangeNotifierProvider(create: (_) => AuthViewModel(cacheService)),
        ChangeNotifierProvider(create: (_) => HistoryViewModel(historyService, petService)),
        ChangeNotifierProvider(create: (_) => NetworkConfigViewModel()),
        ChangeNotifierProvider(
          create: (_) => FeederViewModel(feederService, petService, cacheService, historyService),
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
    final themeViewModel = context.watch<ThemeViewModel>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Pet Feeder',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeViewModel.themeMode,
      home: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          if (authViewModel.user != null) {
            return const DashboardView();
          }
          return const LoginView();
        },
      ),
    );
  }
}