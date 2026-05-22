import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/models/feeding_event.dart';
import 'package:smart_feeder/models/pet.dart';
import 'package:smart_feeder/view_models/history_view_model.dart';
import 'package:smart_feeder/services/localization_service.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HistoryViewModel>();
    final localizationService = context.watch<LocalizationService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizationService.translate('history').toUpperCase()),
          bottom: TabBar(
            tabs: [
              Tab(text: localizationService.translate('history').toUpperCase()),
              Tab(text: localizationService.translate('pet_insights').toUpperCase()),
            ],
            indicatorColor: AppTheme.cyberGreen,
            labelColor: AppTheme.cyberGreen,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
          ),
        ),
        body: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.cyberGreen))
            : TabBarView(
                children: [
                  _buildGlobalLog(context, viewModel, isDark, localizationService),
                  _buildPetInsightsSelection(context, viewModel, isDark, localizationService),
                ],
              ),
        bottomNavigationBar: BottomAppBar(
          color: isDark ? Colors.black : Colors.white,
          elevation: 8,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: OutlinedButton.icon(
                onPressed: () => _showSimulateNotificationDialog(context, viewModel, localizationService),
                icon: const Icon(Icons.notification_important, size: 18),
                label: Text(localizationService.translate('simulate_health_alert'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orangeAccent,
                  side: const BorderSide(color: Colors.orangeAccent),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalLog(BuildContext context, HistoryViewModel viewModel, bool isDark, LocalizationService localizationService) {
    if (viewModel.events.isEmpty) return _buildEmptyState(isDark, localizationService);

    final grouped = viewModel.groupedEvents;
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      itemCount: dates.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _buildGlobalSummaryHeader(viewModel, isDark, localizationService),
            ),
          );
        }
        final date = dates[index - 1];
        final events = grouped[date]!;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildDateGroup(context, date, events, isDark, localizationService),
          ),
        );
      },
    );
  }

  Widget _buildGlobalSummaryHeader(HistoryViewModel viewModel, bool isDark, LocalizationService localizationService) {
    final todayFood = viewModel.getTotalGlobalConsumption(ConsumptionType.food, DateTime.now());
    final todayWater = viewModel.getTotalGlobalConsumption(ConsumptionType.water, DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cyberGreen.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(localizationService.translate('food_weight'), '${todayFood.toStringAsFixed(0)}g', AppTheme.cyberGreen),
          Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.2)),
          _buildSummaryItem(localizationService.translate('water_level'), '${todayWater.toStringAsFixed(0)}%', Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildDateGroup(BuildContext context, DateTime date, List<FeedingEvent> events, bool isDark, LocalizationService localizationService) {
    final dateStr = DateUtils.isSameDay(date, DateTime.now())
        ? localizationService.translate('today')
        : DateUtils.isSameDay(date, DateTime.now().subtract(const Duration(days: 1)))
            ? localizationService.translate('yesterday')
            : DateFormat('EEEE, d MMM', localizationService.locale.languageCode == 'pt' ? 'pt_BR' : localizationService.locale.languageCode).format(date).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Text(
            dateStr,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey),
          ),
        ),
        ...events.map((e) => _HistoryItem(event: e, isDark: isDark)),
      ],
    );
  }

  Widget _buildPetInsightsSelection(BuildContext context, HistoryViewModel viewModel, bool isDark, LocalizationService localizationService) {
    if (viewModel.selectedPetTag != null) {
      return _buildPetDeepDive(context, viewModel, isDark, localizationService);
    }

    if (viewModel.pets.isEmpty) {
      return Center(child: Text(localizationService.translate('no_pets'), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: viewModel.pets.length,
                itemBuilder: (context, index) {
                  final pet = viewModel.pets[index];
                  return GestureDetector(
                    onTap: () => viewModel.selectPet(pet.rfidTag),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.cyberGreen.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pets, color: AppTheme.cyberGreen, size: 32),
                          const SizedBox(height: 12),
                          Text(pet.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(localizationService.translate('view_insights'), style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSimulateNotificationDialog(BuildContext context, HistoryViewModel viewModel, LocalizationService localizationService) {
    String? selectedPetTag = viewModel.pets.isNotEmpty ? viewModel.pets.first.rfidTag : null;
    final controller = TextEditingController();
    final List<String> presetMessages = [
      localizationService.translate('alert_no_food').replaceAll('{hours}', '12'),
      localizationService.translate('alert_no_water').replaceAll('{hours}', '15'),
      'Consumo de alimento 50% abaixo do esperado hoje.',
      'Nível de água baixando mais rápido que o normal.',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(localizationService.translate('simulate_health_alert')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecione o Pet:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: selectedPetTag,
                  isExpanded: true,
                  onChanged: (val) => setState(() => selectedPetTag = val),
                  items: viewModel.pets.map((p) => DropdownMenuItem(value: p.rfidTag, child: Text(p.name))).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Mensagem Customizada:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Digite ou escolha abaixo...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Sugestões:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                ...presetMessages.map((msg) => ListTile(
                  title: Text(msg, style: const TextStyle(fontSize: 11)),
                  onTap: () => controller.text = msg,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(localizationService.translate('cancel'))),
            ElevatedButton(
              onPressed: () {
                final pet = viewModel.pets.firstWhere((p) => p.rfidTag == selectedPetTag);
                viewModel.sendManualNotification(pet, controller.text.isNotEmpty ? controller.text : presetMessages.first);
                Navigator.pop(context);
              },
              child: const Text('ENVIAR'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetDeepDive(BuildContext context, HistoryViewModel viewModel, bool isDark, LocalizationService localizationService) {
    final pet = viewModel.selectedPet;
    final tag = viewModel.selectedPetTag!;
    final foodTrends = viewModel.getWeeklyTrends(tag, ConsumptionType.food);
    final waterTrends = viewModel.getWeeklyTrends(tag, ConsumptionType.water);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: () => viewModel.selectPet(null),
                  ),
                  const Spacer(),
                  _buildPetHeader(pet, isDark, localizationService),
                  const Spacer(flex: 2),
                ],
              ),
              const SizedBox(height: 32),
              Text(localizationService.translate('weekly_trend_food'), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 24),
              _buildWeeklyChart(foodTrends, AppTheme.cyberGreen, isDark),
              const SizedBox(height: 24),
              _buildAnalysisSection(viewModel, tag, ConsumptionType.food, isDark, localizationService),
              const SizedBox(height: 48),
              const Divider(height: 1, color: Colors.white10),
              const SizedBox(height: 48),
              Text(localizationService.translate('weekly_trend_water'), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 24),
              _buildWeeklyChart(waterTrends, Colors.blueAccent, isDark),
              const SizedBox(height: 24),
              _buildAnalysisSection(viewModel, tag, ConsumptionType.water, isDark, localizationService),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetHeader(Pet? pet, bool isDark, LocalizationService localizationService) {
    return Column(
      children: [
        Text(pet?.name.toUpperCase() ?? localizationService.translate('unknown'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        Text('RFID: ${pet?.rfidTag ?? '---'}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildWeeklyChart(List<Map<String, dynamic>> trends, Color barColor, bool isDark) {
    if (trends.isEmpty) return const SizedBox.shrink();
    final maxAmount = trends.map((e) => (e['amount'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
    const chartHeight = 100.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: trends.map((dayData) {
        final amount = (dayData['amount'] as num).toDouble();
        final barHeight = maxAmount > 0 ? (amount / maxAmount) * chartHeight : 0.0;
        return Column(
          children: [
            Text(amount.toStringAsFixed(0), style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              width: 16,
              height: barHeight.clamp(4.0, chartHeight),
              decoration: BoxDecoration(
                color: barColor.withValues(alpha: amount > 0 ? 1.0 : 0.2), 
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(dayData['day'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAnalysisSection(HistoryViewModel viewModel, String tag, ConsumptionType type, bool isDark, LocalizationService localizationService) {
    final statusKey = viewModel.getComparison(tag, type);
    final statusColor = viewModel.getStatusColor(tag, type);
    final icon = type == ConsumptionType.food ? Icons.restaurant : Icons.water_drop;
    final title = localizationService.translate(type == ConsumptionType.food ? 'food_consumption' : 'water_hydration');
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: statusColor, size: 18),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 12)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  localizationService.translate(statusKey),
                  style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            localizationService.translate('daily_monitoring')
              .replaceAll('{type}', localizationService.translate(type == ConsumptionType.food ? 'food' : 'water'))
              .replaceAll('{status}', localizationService.translate(statusKey).toLowerCase()),
            style: TextStyle(height: 1.4, fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, LocalizationService localizationService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 16),
          Text(localizationService.translate('no_history'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final FeedingEvent event;
  final bool isDark;
  const _HistoryItem({required this.event, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = event.type == ConsumptionType.food ? AppTheme.cyberGreen : Colors.blueAccent;
    final icon = event.type == ConsumptionType.food ? Icons.restaurant : Icons.water_drop;
    final unit = event.type == ConsumptionType.food ? 'g' : '%';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.withValues(alpha: 0.5), size: 18),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.petName.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                Text(DateFormat('HH:mm').format(event.timestamp), style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Text('${event.amount.toStringAsFixed(1)}$unit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}
