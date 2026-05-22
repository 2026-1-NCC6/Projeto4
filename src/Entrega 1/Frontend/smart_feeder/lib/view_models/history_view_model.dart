import 'package:flutter/material.dart';
import 'package:smart_feeder/models/feeding_event.dart';
import 'package:smart_feeder/services/history_service.dart';
import 'package:smart_feeder/services/pet_service.dart';

/// ViewModel da tela de histórico.
/// Agrupa e expõe os eventos de alimentação para a UI.
class HistoryViewModel extends ChangeNotifier {
  final HistoryService _historyService;
  final PetService _petService;

  HistoryViewModel(this._historyService, this._petService);

  List<FeedingEvent> get events => _historyService.getEvents();

  /// Agrupa eventos por data (dia).
  Map<DateTime, List<FeedingEvent>> get groupedEvents {
    final Map<DateTime, List<FeedingEvent>> grouped = {};
    for (final event in events) {
      final day = DateTime(
        event.timestamp.year,
        event.timestamp.month,
        event.timestamp.day,
      );
      grouped.putIfAbsent(day, () => []).add(event);
    }
    return grouped;
  }

  /// Total consumido de um tipo no dia informado.
  double getTotalConsumption(ConsumptionType type, DateTime day) {
    return events
        .where((e) =>
            e.type == type &&
            DateUtils.isSameDay(e.timestamp, day))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Recarrega o histórico e notifica a UI.
  void refresh() {
    notifyListeners();
  }
}
