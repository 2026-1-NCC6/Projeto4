import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/view_models/feeder_view_model.dart';
import 'package:smart_feeder/widgets/status_card.dart';
import 'package:smart_feeder/widgets/app_drawer.dart';

/// Tela principal do app — exibe o estado atual do alimentador.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FeederViewModel>();
    final data = viewModel.currentData;

    // Detecta nova tag RFID desconhecida e abre o dialog de cadastro
    if (viewModel.pendingRfidTag != null && !viewModel.isRegistrationDialogOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRegisterPetDialog(context, viewModel);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMART FEEDER'),
        actions: [_buildOnlineBadge(data.isOnline)],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _GreetingHeader(),
            const SizedBox(height: 32),

            // Nível de água com barra de progresso
            StatusCard(
              title: 'WATER LEVEL',
              value: '${data.waterLevel.toStringAsFixed(1)}%',
              icon: Icons.water_drop_outlined,
              color: Colors.blueAccent,
              progress: data.waterLevel / 100,
            ),
            const SizedBox(height: 16),

            // Peso da ração e último pet em linha
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
                    value: data.lastPetDetected == 'None'
                        ? '—'
                        : data.lastPetDetected,
                    icon: Icons.pets_outlined,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Ações rápidas
            _QuickActions(viewModel: viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineBadge(bool isOnline) {
    final color = isOnline ? AppTheme.cyberGreen : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
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
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _showRegisterPetDialog(BuildContext context, FeederViewModel viewModel) {
    final tag = viewModel.pendingRfidTag;
    if (tag == null) return;

    final controller = TextEditingController();
    viewModel.setRegistrationDialogOpen(true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('NOVO PET DETECTADO'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tag RFID: $tag',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nome do Pet',
                border: OutlineInputBorder(),
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
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await viewModel.registerPet(controller.text);
                viewModel.setRegistrationDialogOpen(false);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('CADASTRAR'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME BACK',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.3),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pet Overview',
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

class _QuickActions extends StatelessWidget {
  final FeederViewModel viewModel;
  const _QuickActions({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 16),

        // Botão principal: alimentar agora
        ElevatedButton(
          onPressed: () async {
            await viewModel.triggerManualFeeding();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppTheme.cyberGreen,
                  content: Text(
                    'Feeding Triggered',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt, size: 24),
              SizedBox(width: 12),
              Text(
                'FEED NOW',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Botão secundário: tarar balança
        OutlinedButton(
          onPressed: () async {
            await viewModel.tareScale();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scale Tared Successfully')),
              );
            }
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: BorderSide(
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.scale_outlined,
                size: 20,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              const SizedBox(width: 12),
              Text(
                'TARE SCALE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
