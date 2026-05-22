import 'package:smart_feeder/models/feeding_event.dart';
import 'package:smart_feeder/models/pet.dart';
import 'package:smart_feeder/services/history_service.dart';
import 'package:smart_feeder/services/pet_service.dart';

class DatabaseSeeder {
  static Future<void> seed() async {
    final petService = PetService();
    final historyService = HistoryService();

    // 1. Create a mock Pet
    final rex = Pet(
      rfidTag: "E200410",
      name: "Rex",
      expectedFoodPerDay: 250.0,
      expectedWaterPerDay: 40.0,
    );
    await petService.registerPet(rex);

    final luna = Pet(
      rfidTag: "A1B2C3D",
      name: "Luna",
      expectedFoodPerDay: 180.0,
      expectedWaterPerDay: 30.0,
    );
    await petService.registerPet(luna);

    // 2. Create some historical events for the last 3 days
    final now = DateTime.now();
    
    final events = [
      // Rex - 3 days ago
      FeedingEvent(
        petName: "Rex",
        rfidTag: "E200410",
        amount: 220.0,
        type: ConsumptionType.food,
        timestamp: now.subtract(const Duration(days: 3, hours: 8)),
      ),
      FeedingEvent(
        petName: "Rex",
        rfidTag: "E200410",
        amount: 35.0,
        type: ConsumptionType.water,
        timestamp: now.subtract(const Duration(days: 3, hours: 7)),
      ),

      // Rex - 2 days ago
      FeedingEvent(
        petName: "Rex",
        rfidTag: "E200410",
        amount: 260.0,
        type: ConsumptionType.food,
        timestamp: now.subtract(const Duration(days: 2, hours: 6)),
      ),
      FeedingEvent(
        petName: "Rex",
        rfidTag: "E200410",
        amount: 42.0,
        type: ConsumptionType.water,
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
      ),

      // Rex - Yesterday
      FeedingEvent(
        petName: "Rex",
        rfidTag: "E200410",
        amount: 80.0,
        type: ConsumptionType.food,
        timestamp: now.subtract(const Duration(days: 1, hours: 4)),
      ),
      FeedingEvent(
        petName: "Rex",
        rfidTag: "E200410",
        amount: 15.0,
        type: ConsumptionType.water,
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      FeedingEvent(
        petName: "Rex",
        rfidTag: "E200410",
        amount: 120.0,
        type: ConsumptionType.food,
        timestamp: now.subtract(const Duration(days: 1, hours: 10)),
      ),

      // Luna - Yesterday
      FeedingEvent(
        petName: "Luna",
        rfidTag: "A1B2C3D",
        amount: 190.0,
        type: ConsumptionType.food,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      FeedingEvent(
        petName: "Luna",
        rfidTag: "A1B2C3D",
        amount: 28.0,
        type: ConsumptionType.water,
        timestamp: now.subtract(const Duration(days: 1, hours: 1)),
      ),

      // Rex - Today
      FeedingEvent(
        petName: "Rex",
        rfidTag: "E200410",
        amount: 90.0,
        type: ConsumptionType.food,
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      FeedingEvent(
        petName: "Rex",
        rfidTag: "E200410",
        amount: 25.0,
        type: ConsumptionType.water,
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
    ];

    for (var event in events) {
      await historyService.logEvent(event);
    }
  }
}
