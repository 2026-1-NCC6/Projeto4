/// Representa um evento de alimentação registrado.
/// Na Entrega 1, os eventos são armazenados apenas em memória (sem Firebase).
enum ConsumptionType { food, water }

class FeedingEvent {
  final String petName;
  final double amount;
  final ConsumptionType type;
  final DateTime timestamp;

  FeedingEvent({
    required this.petName,
    required this.amount,
    required this.type,
    required this.timestamp,
  });
}
