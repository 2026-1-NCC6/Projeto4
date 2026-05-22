import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/view_models/feeder_view_model.dart';
import 'package:smart_feeder/widgets/status_card.dart';
import 'package:smart_feeder/widgets/app_drawer.dart';
import 'package:smart_feeder/services/localization_service.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FeederViewModel>();
    final localizationService = context.watch<LocalizationService>();
    final data = viewModel.currentData;

    // Escuta por novas tags para cadastro
    if (viewModel.pendingRfidTag != null && !viewModel.isRegistrationDialogOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRegisterPetDialog(context, viewModel, localizationService);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizationService.translate('app_name')),
        actions: [_buildStatusBadge(data.isOnline, localizationService)],
      ),
      drawer: const AppDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: isWide ? 1000 : 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GreetingHeader(localizationService: localizationService),
                    const SizedBox(height: 32),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                StatusCard(
                                  title: localizationService.translate('water_level'),
                                  value: '${data.waterLevel.toStringAsFixed(1)}%',
                                  icon: Icons.water_drop_outlined,
                                  color: Colors.blueAccent,
                                  progress: data.waterLevel / 100,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatusCard(
                                        title: localizationService.translate('food_weight'),
                                        value: '${data.foodWeight.toStringAsFixed(0)}g',
                                        icon: Icons.scale_outlined,
                                        color: AppTheme.cyberGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: StatusCard(
                                        title: localizationService.translate('last_pet'),
                                        value: localizationService.translate(data.lastPetDetected.split(' ')[0]),
                                        icon: Icons.pets_outlined,
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: _QuickActionSection(viewModel: viewModel, localizationService: localizationService),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          StatusCard(
                            title: localizationService.translate('water_level'),
                            value: '${data.waterLevel.toStringAsFixed(1)}%',
                            icon: Icons.water_drop_outlined,
                            color: Colors.blueAccent,
                            progress: data.waterLevel / 100,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: StatusCard(
                                  title: localizationService.translate('food_weight'),
                                  value: '${data.foodWeight.toStringAsFixed(0)}g',
                                  icon: Icons.scale_outlined,
                                  color: AppTheme.cyberGreen,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: StatusCard(
                                  title: localizationService.translate('last_pet'),
                                  value: localizationService.translate(data.lastPetDetected.split(' ')[0]),
                                  icon: Icons.pets_outlined,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          _QuickActionSection(viewModel: viewModel, localizationService: localizationService),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRegisterPetDialog(BuildContext context, FeederViewModel viewModel, LocalizationService localizationService) {
    final tag = viewModel.pendingRfidTag;
    if (tag == null) return;

    final controller = TextEditingController();
    viewModel.setRegistrationDialogOpen(true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localizationService.translate('new_pet_detected')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tag RFID: $tag', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: localizationService.translate('pet_name'),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.clearPendingTag();
              viewModel.setRegistrationDialogOpen(false);
              Navigator.pop(context);
            },
            child: Text(localizationService.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await viewModel.registerPet(controller.text, tag);
                viewModel.setRegistrationDialogOpen(false);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(localizationService.translate('register')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isOnline, LocalizationService localizationService) {
    final color = isOnline ? AppTheme.cyberGreen : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4, spreadRadius: 1),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? localizationService.translate('online') : localizationService.translate('offline'),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final LocalizationService localizationService;
  const _GreetingHeader({required this.localizationService});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('welcome_back'), 
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w600, 
            color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          localizationService.translate('pet_overview'), 
          style: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.w900, 
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}

class _QuickActionSection extends StatelessWidget {
  final FeederViewModel viewModel;
  final LocalizationService localizationService;
  const _QuickActionSection({required this.viewModel, required this.localizationService});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.translate('quick_actions'), 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w600, 
            color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () async {
            await viewModel.tareScale();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizationService.translate('scale_tared')),
                ),
              );
            }
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.scale_outlined, size: 20, color: isDark ? Colors.white70 : Colors.black54),
              const SizedBox(width: 12),
              Text(
                localizationService.translate('tare_scale'), 
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w700, 
                  letterSpacing: 1.1,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
