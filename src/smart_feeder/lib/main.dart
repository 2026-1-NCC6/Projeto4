import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/services/feeder_service.dart';
import 'package:smart_feeder/view_models/feeder_view_model.dart';
import 'package:smart_feeder/views/dashboard_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Aqui definimos qual serviço usar. 
  // No futuro, mude MockFeederService para FirebaseFeederService.
  final feederService = MockFeederService();

  runApp(
    MultiProvider(
      providers: [
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Pet Feeder',
      theme: AppTheme.darkTheme,
      home: const DashboardView(),
    );
  }
}
