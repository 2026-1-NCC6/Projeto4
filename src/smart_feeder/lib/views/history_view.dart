import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/models/feeding_event.dart';
import 'package:smart_feeder/models/pet.dart';
import 'package:smart_feeder/view_models/history_view_model.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HistoryViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FEEDING HISTORY'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'GLOBAL LOG'),
              Tab(text: 'PET INSIGHTS'),
            ],
            indicatorColor: AppTheme.cyberGreen,
            labelColor: AppTheme.cyberGreen,
          ),
        ),
        body: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.cyberGreen))
            : TabBarView(
                children: [
                  _buildGlobalLog(context, viewModel, isDark),
                  _buildPetInsightsSelection(context, viewModel, isDark),
                ],
              ),
      ),
    );
  }

  // --- TAB 1: GLOBAL LOG ---

  Widget _buildGlobalLog(BuildContext context, HistoryViewModel viewModel, bool isDark) {
    if (viewModel.events.isEmpty) return _buildEmptyState(isDark);

    final grouped = viewModel.groupedEvents;
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        _buildGlobalSummaryHeader(viewModel, isDark),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final events = grouped[date]!;
              return _buildDateGroup(context, date, events, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalSummaryHeader(HistoryViewModel viewModel, bool isDark) {
    final todayFood = viewModel.getTotalGlobalConsumption(ConsumptionType.food, DateTime.now());
    final todayWater = viewModel.getTotalGlobalConsumption(ConsumptionType.water, DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.cyberGreen.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('TODAY FOOD', '${todayFood.toStringAsFixed(0)}g', AppTheme.cyberGreen),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          _buildSummaryItem('TODAY WATER', '${todayWater.toStringAsFixed(0)}%', Colors.blueAccent),
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

  Widget _buildDateGroup(BuildContext context, DateTime date, List<FeedingEvent> events, bool isDark) {
    final dateStr = DateUtils.isSameDay(date, DateTime.now())
        ? 'TODAY'
        : DateUtils.isSameDay(date, DateTime.now().subtract(const Duration(days: 1)))
            ? 'YESTERDAY'
            : DateFormat('EEEE, MMM d').format(date).toUpperCase();

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

  // --- TAB 2: PET INSIGHTS ---

  Widget _buildPetInsightsSelection(BuildContext context, HistoryViewModel viewModel, bool isDark) {
    if (viewModel.selectedPetTag != null) {
      return _buildPetDeepDive(context, viewModel, isDark);
    }

    if (viewModel.pets.isEmpty) {
      return const Center(child: Text('NO PETS REGISTERED YET', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: viewModel.pets.length,
      itemBuilder: (context, index) {
        final pet = viewModel.pets[index];
        return GestureDetector(
          onTap: () => viewModel.selectPet(pet.rfidTag),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.cyberGreen.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pets, color: AppTheme.cyberGreen, size: 40),
                const SizedBox(height: 12),
                Text(pet.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 4),
                const Text('VIEW INSIGHTS', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPetDeepDive(BuildContext context, HistoryViewModel viewModel, bool isDark) {
    final pet = viewModel.selectedPet;
    final tag = viewModel.selectedPetTag!;
    final foodTrends = viewModel.getWeeklyTrends(tag, ConsumptionType.food);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
              _buildPetHeader(pet, isDark),
              const Spacer(flex: 2),
            ],
          ),
          const SizedBox(height: 32),
          const Text('WEEKLY FOOD TREND', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          _buildWeeklyChart(foodTrends, isDark),
          const SizedBox(height: 40),
          _buildAnalysisSection(viewModel, tag, isDark),
        ],
      ),
    );
  }

  Widget _buildPetHeader(Pet? pet, bool isDark) {
    return Column(
      children: [
        Text(pet?.name.toUpperCase() ?? 'UNKNOWN', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        Text('RFID: ${pet?.rfidTag ?? '---'}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildWeeklyChart(List<Map<String, dynamic>> trends, bool isDark) {
    if (trends.isEmpty) return const SizedBox.shrink();
    final maxAmount = trends.map((e) => e['amount'] as double).reduce((a, b) => a > b ? a : b);
    const chartHeight = 150.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: trends.map((dayData) {
        final amount = dayData['amount'] as double;
        final barHeight = maxAmount > 0 ? (amount / maxAmount) * chartHeight : 0.0;
        return Column(
          children: [
            Text('${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
            const SizedBox(height: 4),
            Container(
              width: 20,
              height: barHeight.clamp(4.0, chartHeight),
              decoration: BoxDecoration(color: AppTheme.cyberGreen, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 8),
            Text(dayData['day'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAnalysisSection(HistoryViewModel viewModel, String tag, bool isDark) {
    final foodComp = viewModel.getComparison(tag, ConsumptionType.food);
    final statusColor = viewModel.getStatusColor(tag, ConsumptionType.food);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: statusColor),
              const SizedBox(width: 12),
              const Text('BEHAVIOR ANALYSIS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Pet is currently $foodComp. Data indicates consistent patterns.',
            style: TextStyle(height: 1.5, color: isDark ? Colors.white70 : Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: isDark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 16),
          const Text('NO HISTORY YET', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey)),
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
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(0.5), size: 18),
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
