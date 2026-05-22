import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_feeder/view_models/theme_view_model.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/utils/seeder.dart';
import 'package:smart_feeder/services/localization_service.dart';
import 'package:smart_feeder/view_models/feeder_view_model.dart';
import 'delete_account_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final localizationService = context.watch<LocalizationService>();
    final isDark = themeViewModel.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizationService.translate('settings')),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new, 
            size: 20, 
            color: isDark ? AppTheme.cyberGreen : Colors.black
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSectionHeader(context, localizationService.translate('language')),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(localizationService.translate('language')),
                    trailing: DropdownButton<String>(
                      value: localizationService.locale.languageCode,
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          localizationService.setLocale(Locale(newValue));
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 'pt', child: Text('Português')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'es', child: Text('Español')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, localizationService.translate('calibrate_scale').toUpperCase()),
                  const _CalibrationSection(),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, localizationService.translate('appearance')),
                  SwitchListTile(
                    activeThumbColor: AppTheme.cyberGreen,
                    title: Text(localizationService.translate('dark_mode'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(localizationService.translate('dark_mode_desc'), style: const TextStyle(fontSize: 12)),
                    value: isDark,
                    onChanged: (value) => themeViewModel.toggleTheme(),
                    secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: isDark ? AppTheme.cyberGreen : Colors.orange),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, localizationService.translate('account')),
                  _buildSettingsItem(
                    context,
                    Icons.person_outline,
                    localizationService.translate('profile_info'),
                    localizationService.translate('profile_info_desc'),
                    null,
                  ),
                  _buildSettingsItem(
                    context,
                    Icons.notifications_none,
                    localizationService.translate('notifications'),
                    localizationService.translate('notifications_desc'),
                    null,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, localizationService.translate('developer')),
                  _buildSettingsItem(
                    context,
                    Icons.data_array,
                    localizationService.translate('seed_data'),
                    localizationService.translate('seed_data_desc'),
                    () async {
                      await DatabaseSeeder.seed();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(localizationService.translate('seed_success'))),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, localizationService.translate('danger_zone')),
                  _buildSettingsItem(
                    context,
                    Icons.delete_forever_outlined,
                    localizationService.translate('delete_account'),
                    localizationService.translate('delete_account_desc'),
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const DeleteAccountView()),
                      );
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive ? Colors.redAccent : (isDark ? Colors.white : Colors.black);
    
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color.withValues(alpha: 0.7)),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: color.withValues(alpha: 0.4), fontSize: 12),
      ),
      trailing: Icon(Icons.chevron_right, color: color.withValues(alpha: 0.2), size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _CalibrationSection extends StatefulWidget {
  const _CalibrationSection();

  @override
  State<_CalibrationSection> createState() => _CalibrationSectionState();
}

class _CalibrationSectionState extends State<_CalibrationSection> {
  late TextEditingController _weightController;
  late TextEditingController _factorController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _factorController = TextEditingController();
    
    // Inicializa o fator com o valor atual, mas apenas uma vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<FeederViewModel>(context, listen: false);
      _factorController.text = viewModel.currentData.calibrationFactor.toStringAsFixed(2);
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _factorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Escuta mudanças apenas para o Monitor de Valor Bruto, 
    // mas os controllers permanecem estáveis no State.
    final viewModel = context.watch<FeederViewModel>();
    final localizationService = context.watch<LocalizationService>();
    final data = viewModel.currentData;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizationService.translate('calibration_step_1'), style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => viewModel.tareScale(),
              icon: const Icon(Icons.scale, size: 18),
              label: Text(localizationService.translate('tare_scale')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cyberGreen,
                foregroundColor: Colors.black,
              ),
            ),
            const Divider(height: 32),
            // Monitor de Valor Bruto
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(localizationService.translate('current_raw'), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(data.rawWeight.toString(), style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: AppTheme.cyberGreen)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(localizationService.translate('calibration_step_2'), style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: localizationService.translate('known_weight'),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Text(localizationService.translate('calibration_step_3'), style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  final weight = double.tryParse(_weightController.text);
                  if (weight != null && weight > 0) {
                    viewModel.calibrateScale(weight);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizationService.translate('calibration_started'))),
                    );
                  }
                },
                child: Text(localizationService.translate('calibrate')),
              ),
            ),
            const Divider(height: 32),
            // Configuração Manual do Fator
            Text(localizationService.translate('manual_factor'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _factorController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final factor = double.tryParse(_factorController.text);
                    if (factor != null) {
                      viewModel.setCalibrationFactor(factor);
                    }
                  },
                  child: Text(localizationService.translate('apply_factor')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
