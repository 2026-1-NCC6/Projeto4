/// Representa um pet cadastrado no sistema.
/// Na Entrega 1, os pets são armazenados apenas em memória (sem persistência).
class Pet {
  final String rfidTag;
  final String name;

  Pet({
    required this.rfidTag,
    required this.name,
  });
}
