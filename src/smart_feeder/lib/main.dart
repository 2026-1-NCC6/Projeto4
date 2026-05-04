import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Adicionado
import 'firebase_options.dart'; // O arquivo que você gerou agora pouco
import 'package:smart_feeder/services/mqtt_feeder_service.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/services/feeder_service.dart';
import 'package:smart_feeder/view_models/feeder_view_model.dart';
import 'package:smart_feeder/view_models/auth_view_model.dart';
import 'package:smart_feeder/views/dashboard_view.dart';
import 'package:smart_feeder/views/login_view.dart';

import 'package:smart_feeder/view_models/theme_view_model.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase with generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Define the service (MqttFeederService for production, MockFeederService for testing)
  final feederService = MqttFeederService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (_) => FeederViewModel(feederService),
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