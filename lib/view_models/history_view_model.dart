import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/models/feeding_event.dart';
import 'package:smart_feeder/models/pet.dart';
import 'package:smart_feeder/services/history_service.dart';
import 'package:smart_feeder/services/pet_service.dart';
import 'package:smart_feeder/services/notification_service.dart';

class HistoryViewModel extends ChangeNotifier {
  final HistoryService _historyService;
  final PetService _petService;
  final NotificationService _notificationService = NotificationService();
  List<FeedingEvent> _events = [];
  List<Pet> _pets = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;
  StreamSubscription? _petsSubscription;
  String? _selectedPetTag;

  // Configuration for alerts
  static const int inactivityThresholdHours = 12; // Example: 12 hours without eating/drinking

  List<FeedingEvent> get events => _events;
  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get selectedPetTag => _selectedPetTag;

  Pet? get selectedPet => _pets.where((p) => p.rfidTag == _selectedPetTag).firstOrNull;

  HistoryViewModel(this._historyService, this._petService) {
    _init();
  }

  void selectPet(String? rfidTag) {
    _selectedPetTag = rfidTag;
    notifyListeners();
  }

  Future<void> _init() async {
    _petsSubscription = _petService.getPetsStream().listen((data) {
      _pets = data;
      notifyListeners();
    });

    _subscription = _historyService.getHistoryStream().listen((data) {
      _events = data;
      _isLoading = false;
      checkHealthAndNotify();
      notifyListeners();
    });
  }

  void checkHealthAndNotify() {
    final now = DateTime.now();
    for (var pet in _pets) {
      // Check Food Inactivity
      final lastFood = _events
          .where((e) => e.rfidTag == pet.rfidTag && e.type == ConsumptionType.food)
          .fold<DateTime?>(null, (last, e) => (last == null || e.timestamp.isAfter(last)) ? e.timestamp : last);

      if (lastFood != null) {
        final hoursSinceFood = now.difference(lastFood).inHours;
        if (hoursSinceFood >= inactivityThresholdHours) {
          _notificationService.showHealthAlert(
            id: pet.rfidTag.hashCode + 1,
            petName: pet.name,
            message: 'Não come há $hoursSinceFood horas. Isso pode ser um sinal de mal-estar.',
          );
        }
      }

      // Check Water Inactivity
      final lastWater = _events
          .where((e) => e.rfidTag == pet.rfidTag && e.type == ConsumptionType.water)
          .fold<DateTime?>(null, (last, e) => (last == null || e.timestamp.isAfter(last)) ? e.timestamp : last);

      if (lastWater != null) {
        final hoursSinceWater = now.difference(lastWater).inHours;
        if (hoursSinceWater >= inactivityThresholdHours) {
          _notificationService.showHealthAlert(
            id: pet.rfidTag.hashCode + 2,
            petName: pet.name,
            message: 'Não consome água há $hoursSinceWater horas. Verifique sinais de desidratação.',
          );
        }
      }
    }
  }

  void simulateHealthAlert() {
    if (_pets.isNotEmpty) {
      final pet = _pets.first;
      final messages = [
        'Não come há 12 horas. Isso pode ser um sinal de mal-estar.',
        'Não consome água há 15 horas. Verifique sinais de desidratação.',
        'Consumo de alimento 50% abaixo do esperado hoje.',
        'Nível de água baixando mais rápido que o normal.',
      ];
      final randomMessage = (messages..shuffle()).first;

      _notificationService.showHealthAlert(
        id: DateTime.now().millisecond,
        petName: pet.name,
        message: 'SIMULAÇÃO: $randomMessage',
      );
    }
  }

  void sendManualNotification(Pet pet, String message) {
    _notificationService.showHealthAlert(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      petName: pet.name,
      message: message,
    );
  }

  Map<DateTime, List<FeedingEvent>> get groupedEvents {
    final Map<DateTime, List<FeedingEvent>> grouped = {};
    for (var event in _events) {
      final date = DateUtils.dateOnly(event.timestamp);
      if (grouped[date] == null) grouped[date] = [];
      grouped[date]!.add(event);
    }
    return grouped;
  }

  double getTotalGlobalConsumption(ConsumptionType type, DateTime date) {
    final targetDate = DateUtils.dateOnly(date);
    return _events
        .where((e) => e.type == type && DateUtils.isSameDay(e.timestamp, targetDate))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _petsSubscription?.cancel();
    super.dispose();
  }

  // Returns a translation key for the UI
  String getComparison(String rfidTag, ConsumptionType type) {
    final pet = _pets.where((p) => p.rfidTag == rfidTag).firstOrNull;
    if (pet == null) return "status_normal";

    final todayConsumption = getTodayConsumption(rfidTag, type);
    final expected = type == ConsumptionType.food ? pet.expectedFoodPerDay : pet.expectedWaterPerDay;

    if (todayConsumption < expected * 0.5) return "status_waiting"; 
    if (todayConsumption < expected * 0.8) return "status_below";
    if (todayConsumption > expected * 1.2) return "status_above";
    return "status_on_track";
  }

  double getTodayConsumption(String rfidTag, ConsumptionType type) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    
    return _events
        .where((e) => e.rfidTag == rfidTag && e.type == type && DateUtils.isSameDay(e.timestamp, today))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> getPetStatus(String rfidTag, ConsumptionType type) {
    final petEvents = _events.where((e) => e.rfidTag == rfidTag && e.type == type).toList();
    if (petEvents.isEmpty) return {'average': 0.0, 'days': 0.0, 'today': 0.0};

    final dates = petEvents.map((e) => DateUtils.dateOnly(e.timestamp)).toSet();
    final days = dates.length;

    final total = petEvents.fold(0.0, (sum, e) => sum + e.amount);
    final average = total / days;
    
    return {
      'average': average, 
      'days': days.toDouble(),
      'today': getTodayConsumption(rfidTag, type),
    };
  }

  Color getStatusColor(String rfidTag, ConsumptionType type) {
    final statusKey = getComparison(rfidTag, type);
    if (statusKey == "status_on_track" || statusKey == "status_waiting") return AppTheme.cyberGreen;
    return Colors.orangeAccent;
  }

  // Weekly trends (last 7 days)
  List<Map<String, dynamic>> getWeeklyTrends(String rfidTag, ConsumptionType type) {
    final now = DateTime.now();
    final results = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateUtils.dateOnly(now.subtract(Duration(days: i)));
      final total = _events
          .where((e) => e.rfidTag == rfidTag && e.type == type && DateUtils.isSameDay(e.timestamp, date))
          .fold(0.0, (sum, e) => sum + e.amount);
      
      results.add({
        'day': _getDayInitial(date.weekday),
        'amount': total,
      });
    }
    return results;
  }

  String _getDayInitial(int weekday) {
    // These could also be localized if needed, but initials are usually okay if simple.
    // For now, let's keep it simple or use a format that works across languages.
    switch (weekday) {
      case 1: return 'S'; // Seg / Mon
      case 2: return 'T'; // Ter / Tue
      case 3: return 'Q'; // Qua / Wed
      case 4: return 'Q'; // Qui / Thu
      case 5: return 'S'; // Sex / Fri
      case 6: return 'S'; // Sab / Sat
      case 7: return 'D'; // Dom / Sun
      default: return '';
    }
  }
}

extension ListFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
