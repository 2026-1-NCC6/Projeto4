import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/models/feeding_event.dart';
import 'package:smart_feeder/view_models/history_view_model.dart';

/// Tela de histórico de alimentação.
/// Exibe todos os eventos registrados agrupados por data.
class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HistoryViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final events = viewModel.events;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FEEDING HISTORY'),
      ),
      body: events.isEmpty
          ? _buildEmptyState(isDark)
          : Column(
              children: [
                _buildSummaryHeader(viewModel, isDark),
                Expanded(
                  child: _buildEventList(viewModel, isDark),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryHeader(HistoryViewModel viewModel, bool isDark) {
    final todayFood = viewModel.getTotalConsumption(
      ConsumptionType.food,
      DateTime.now(),
    );
    final todayWater = viewModel.getTotalConsumption(
      ConsumptionType.water,
      DateTime.now(),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.cyberGreen.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'TODAY FOOD',
            '${todayFood.toStringAsFixed(0)}g',
            AppTheme.cyberGreen,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          _buildSummaryItem(
            'TODAY WATER',
            '${todayWater.toStringAsFixed(0)}%',
            Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEventList(HistoryViewModel viewModel, bool isDark) {
    final grouped = viewModel.groupedEvents;
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final dayEvents = grouped[date]!;
        return _buildDateGroup(date, dayEvents, isDark);
      },
    );
  }

  Widget _buildDateGroup(
    DateTime date,
    List<FeedingEvent> events,
    bool isDark,
  ) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final String label;
    if (DateUtils.isSameDay(date, now)) {
      label = 'TODAY';
    } else if (DateUtils.isSameDay(date, yesterday)) {
      label = 'YESTERDAY';
    } else {
      label = DateFormat('EEEE, MMM d').format(date).toUpperCase();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
        ),
        ...events.map((e) => _EventItem(event: e, isDark: isDark)),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          const Text(
            'NO HISTORY YET',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Events will appear here after pets eat or drink.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EventItem extends StatelessWidget {
  final FeedingEvent event;
  final bool isDark;

  const _EventItem({required this.event, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isFood = event.type == ConsumptionType.food;
    final color = isFood ? AppTheme.cyberGreen : Colors.blueAccent;
    final icon = isFood ? Icons.restaurant : Icons.water_drop;
    final unit = isFood ? 'g' : '%';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.withValues(alpha: 0.6), size: 18),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.petName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(event.timestamp),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${event.amount.toStringAsFixed(1)}$unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
