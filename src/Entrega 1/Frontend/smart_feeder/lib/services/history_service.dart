import 'package:smart_feeder/models/feeding_event.dart';

/// Serviço de histórico de alimentação.
/// Na Entrega 1, os eventos ficam apenas em memória (sem Firestore).
/// Na Entrega 2, este serviço foi substituído por uma versão com Firebase.
class HistoryService {
  final List<FeedingEvent> _events = [];

  /// Registra um novo evento de alimentação.
  void logEvent(FeedingEvent event) {
    _events.add(event);
  }

  /// Retorna todos os eventos registrados, do mais recente ao mais antigo.
  List<FeedingEvent> getEvents() {
    return List.unmodifiable(_events.reversed.toList());
  }

  /// Retorna eventos de um pet específico.
  List<FeedingEvent> getEventsByPet(String petName) {
    return _events
        .where((e) => e.petName == petName)
        .toList()
        .reversed
        .toList();
  }
}
