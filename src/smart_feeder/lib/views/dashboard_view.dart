import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            const SizedBox(height: 24),
            StatusCard(
              title: 'FOOD RESERVE',
              value: '${data.foodLevel.toStringAsFixed(1)}%',
              icon: Icons.inventory_2,
              color: data.foodLevel < 20 ? Colors.redAccent : Colors.greenAccent,
              progress: data.foodLevel / 100,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatusCard(
                    title: 'BOWL WEIGHT',
                    value: '${data.bowlWeight.toStringAsFixed(1)}g',
                    icon: Icons.monitor_weight_outlined,
                    color: Colors.blueAccent,
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
            const SizedBox(height: 32),
            _QuickActionSection(viewModel: viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOnline) {
    final color = isOnline ? Colors.greenAccent : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello!', style: TextStyle(fontSize: 16, color: Colors.grey)),
        Text('Pet Status', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
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
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            await viewModel.triggerManualFeeding();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.greenAccent,
                  content: Text('Command sent: Manual Feeding Triggered', style: TextStyle(color: Colors.black)),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 10,
            shadowColor: Colors.greenAccent.withValues(alpha: 0.3),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 24),
              SizedBox(width: 12),
              Text('FEED NOW', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}
