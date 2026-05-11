import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import 'package:smart_feeder/models/feeding_event.dart';
import 'package:smart_feeder/models/pet.dart';
import 'package:smart_feeder/services/history_service.dart';
import 'package:smart_feeder/services/pet_service.dart';

class HistoryViewModel extends ChangeNotifier {
  final HistoryService _historyService;
  final PetService _petService;
  List<FeedingEvent> _events = [];
  List<Pet> _pets = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;
  String? _selectedPetTag;

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
    _pets = await _petService.getAllPets();

    _subscription = _historyService.getHistoryStream().listen((data) {
      _events = data;
      _isLoading = false;
      notifyListeners();
    });
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
    super.dispose();
  }

  // Returns a comparison for the UI
  String getComparison(String rfidTag, ConsumptionType type) {
    final pet = _pets.where((p) => p.rfidTag == rfidTag).firstOrNull;
    if (pet == null) return "NORMAL";

    final todayConsumption = getTodayConsumption(rfidTag, type);
    final expected = type == ConsumptionType.food ? pet.expectedFoodPerDay : pet.expectedWaterPerDay;

    if (todayConsumption < expected * 0.5) return "WAITING..."; 
    if (todayConsumption < expected * 0.8) return "BELOW TARGET";
    if (todayConsumption > expected * 1.2) return "ABOVE TARGET";
    return "ON TRACK";
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
    final comparison = getComparison(rfidTag, type);
    if (comparison == "ON TRACK" || comparison == "WAITING...") return AppTheme.cyberGreen;
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
        'day': _getDayName(date.weekday),
        'amount': total,
      });
    }
    return results;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'M';
      case 2: return 'T';
      case 3: return 'W';
      case 4: return 'T';
      case 5: return 'F';
      case 6: return 'S';
      case 7: return 'S';
      default: return '';
    }
  }
}

extension ListFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
