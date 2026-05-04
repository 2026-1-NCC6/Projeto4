import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/view_models/feeder_view_model.dart';
import 'package:smart_feeder/widgets/status_card.dart';
import 'package:smart_feeder/widgets/app_drawer.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FeederViewModel>();
    final data = viewModel.currentData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMART FEEDER'),
        actions: [_buildStatusBadge(data.isOnline)],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _GreetingHeader(),
            const SizedBox(height: 32),
            StatusCard(
              title: 'WATER LEVEL',
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
                    title: 'FOOD WEIGHT',
                    value: '${data.foodWeight.toStringAsFixed(0)}g',
                    icon: Icons.scale_outlined,
                    color: AppTheme.cyberGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatusCard(
                    title: 'LAST PET',
                    value: data.lastPetDetected.split(' ')[0],
                    icon: Icons.pets_outlined,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _QuickActionSection(viewModel: viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOnline) {
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
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME BACK', 
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w600, 
            color: Colors.white.withValues(alpha: 0.3),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pet Overview', 
          style: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.w900, 
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _QuickActionSection extends StatelessWidget {
  final FeederViewModel viewModel;
  const _QuickActionSection({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS', 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w600, 
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cyberGreen.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () async {
              await viewModel.triggerManualFeeding();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppTheme.cyberGreen,
                    content: Text('Feeding Triggered', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cyberGreen,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt, size: 24),
                SizedBox(width: 12),
                Text('FEED NOW', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
