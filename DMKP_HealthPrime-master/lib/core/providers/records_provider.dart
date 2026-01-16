import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/models/health_record.dart';
import '../services/offline_service.dart';

class RecordsProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final OfflineService _offlineService = OfflineService();
  User? _user;

  List<HealthRecord> _firestoreRecords = [];
  List<HealthRecord> _pendingRecords = [];
  List<String> _pendingDeletes = [];

  List<HealthRecord> _combinedRecords = [];
  int _visibleLimit = 10;
  bool _isOnline = true;

  StreamSubscription? _firestoreSub;
  StreamSubscription? _connectivitySub;

  RecordsProvider() {
    _initConnectivity();
  }

  void _initConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      bool isConnected = results.any((r) => r != ConnectivityResult.none);

      if (isConnected && !_isOnline) {
        _isOnline = true;
        _syncPendingData();
      } else if (!isConnected) {
        _isOnline = false;
      }
      notifyListeners();
    });
  }

  void updateUser(User? user) {
    _user = user;
    if (_user != null) {
      _loadLocalData();
      _listenToRecords();
    } else {
      _firestoreRecords = [];
      _pendingRecords = [];
      _pendingDeletes = [];
      _updateCombinedList();
    }
  }

  // Load Local Data
  Future<void> _loadLocalData() async {
    _pendingRecords = await _offlineService.getPendingRecords();
    _pendingDeletes = await _offlineService.getPendingDeletes();
    _updateCombinedList();
  }

  void _listenToRecords() {
    _firestoreSub = _db
        .collection('users')
        .doc(_user!.uid)
        .collection('records')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _firestoreRecords =
          snapshot.docs.map((doc) => HealthRecord.fromFirestore(doc)).toList();
      _updateCombinedList();
    });
  }

  // Update Combined List
  void _updateCombinedList() {
    Map<String, HealthRecord> recordsMap = {
      for (var r in _firestoreRecords) r.id: r
    };

    for (var id in _pendingDeletes) {
      recordsMap.remove(id);
    }

    for (var r in _pendingRecords) {
      recordsMap[r.id] = r;
    }

    _combinedRecords = recordsMap.values.toList();
    _combinedRecords.sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
  }

  List<HealthRecord> get records => _combinedRecords;
  List<HealthRecord> get displayedRecords =>
      _combinedRecords.take(_visibleLimit).toList();
  List<HealthRecord> get allRecordsForSearch => _combinedRecords;
  bool get hasMoreRecords => _combinedRecords.length > _visibleLimit;
  String get activeDays => _combinedRecords.length.toString();

  // Get Today's Record
  HealthRecord? get todayRecord {
    final now = DateTime.now();
    try {
      return _combinedRecords
          .firstWhere((r) => _isSameDay(r.date.toLocal(), now));
    } catch (e) {
      return null;
    }
  }

  // Save Record
  Future<void> saveRecord(HealthRecord record) async {
    if (_user == null) return;

    final connectivity = await Connectivity().checkConnectivity();
    bool isConnected = connectivity.any((r) => r != ConnectivityResult.none);

    if (isConnected) {
      final data = record.toMap();
      data['date'] = Timestamp.fromDate(record.date);

      if (record.id.isEmpty || record.id.startsWith('temp_')) {
        await _db
            .collection('users')
            .doc(_user!.uid)
            .collection('records')
            .add(data);
      } else {
        await _db
            .collection('users')
            .doc(_user!.uid)
            .collection('records')
            .doc(record.id)
            .update(data);
      }
    } else {
      String id = record.id;
      if (id.isEmpty) {
        id = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      }

      final localRecord = HealthRecord(
        id: id,
        date: record.date,
        steps: record.steps,
        calories: record.calories,
        water: record.water,
        sleep: record.sleep,
        heartRate: record.heartRate,
        weight: record.weight,
        fruits: record.fruits,
        workout: record.workout,
        mood: record.mood,
      );

      await _offlineService.savePendingRecord(localRecord);

      _pendingRecords.removeWhere((r) => r.id == id);
      _pendingRecords.add(localRecord);
      _updateCombinedList();
    }
  }

  // Delete Record
  Future<void> deleteRecord(String id) async {
    if (_user == null) return;

    final connectivity = await Connectivity().checkConnectivity();
    bool isConnected = connectivity.any((r) => r != ConnectivityResult.none);

    if (isConnected) {
      if (id.startsWith('temp_')) {
        await _offlineService.clearPendingRecord(id);
        _pendingRecords.removeWhere((r) => r.id == id);
      } else {
        await _db
            .collection('users')
            .doc(_user!.uid)
            .collection('records')
            .doc(id)
            .delete();
      }
    } else {
      if (id.startsWith('temp_')) {
        await _offlineService.clearPendingRecord(id);
        _pendingRecords.removeWhere((r) => r.id == id);
      } else {
        await _offlineService.savePendingDelete(id);
        _pendingDeletes.add(id);
      }
      _updateCombinedList();
    }
  }

  // Sync Pending Data
  Future<void> _syncPendingData() async {
    if (_user == null) return;
    print("Starting Sync...");

    for (String id in List.from(_pendingDeletes)) {
      try {
        await _db
            .collection('users')
            .doc(_user!.uid)
            .collection('records')
            .doc(id)
            .delete();
        await _offlineService.clearPendingDelete(id);
        _pendingDeletes.remove(id);
      } catch (e) {
        print("Sync delete failed for $id: $e");
      }
    }

    for (HealthRecord r in List.from(_pendingRecords)) {
      try {
        final data = r.toMap();
        data['date'] = Timestamp.fromDate(r.date);

        if (r.id.startsWith('temp_')) {
          await _db
              .collection('users')
              .doc(_user!.uid)
              .collection('records')
              .add(data);
        } else {
          await _db
              .collection('users')
              .doc(_user!.uid)
              .collection('records')
              .doc(r.id)
              .update(data);
        }

        await _offlineService.clearPendingRecord(r.id);
        _pendingRecords.remove(r);
      } catch (e) {
        print("Sync update failed for ${r.id}: $e");
      }
    }

    _updateCombinedList();
    print("Sync Complete");
  }

  // Load More Records
  void loadMoreRecords() {
    if (hasMoreRecords) {
      _visibleLimit += 10;
      notifyListeners();
    }
  }

  // Get Weekly Data
  List<double> getWeeklyData(String metric) {
    List<double> data = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final record = _combinedRecords.firstWhere(
        (r) => _isSameDay(r.date.toLocal(), date),
        orElse: () => HealthRecord(id: '', date: date),
      );

      double value = 0;
      switch (metric) {
        case 'steps':
          value = record.steps.toDouble();
          break;
        case 'calories':
          value = record.calories.toDouble();
          break;
        case 'water':
          value = record.water.toDouble();
          break;
        case 'sleep':
          value = record.sleep;
          break;
        case 'weight':
          value = record.weight ?? 0;
          break;
        case 'heartRate':
          value = record.heartRate.toDouble();
          break;
        case 'fruits':
          value = (record.fruits ?? 0).toDouble();
          break;
        case 'workout':
          value = (record.workout ?? 0).toDouble();
          break;
        case 'mood':
          value = record.mood.toDouble();
          break;
      }
      data.add(value);
    }
    return data;
  }

  // Get Averages
  String getAverage(String metric) {
    if (_combinedRecords.isEmpty) return "0";
    double total = 0;
    int count = 0;

    for (var r in _combinedRecords) {
      double val = 0;
      bool isValid = true;
      switch (metric) {
        case 'steps':
          val = r.steps.toDouble();
          break;
        case 'calories':
          val = r.calories.toDouble();
          break;
        case 'water':
          val = r.water.toDouble();
          break;
        case 'sleep':
          val = r.sleep;
          break;
        case 'heartRate':
          val = r.heartRate.toDouble();
          break;
        case 'weight':
          val = r.weight ?? 0;
          if (val == 0) isValid = false;
          break;
        case 'fruits':
          val = (r.fruits ?? 0).toDouble();
          break;
        case 'workout':
          val = (r.workout ?? 0).toDouble();
          break;
        case 'mood':
          val = r.mood.toDouble();
          break;
      }
      if (isValid) {
        total += val;
        count++;
      }
    }

    if (count == 0) return "0";
    double avg = total / count;
    if (['steps', 'calories', 'water', 'heartRate', 'workout']
        .contains(metric)) {
      return avg.toInt().toString();
    }
    return avg.toStringAsFixed(1);
  }

  // Get Personal Bests
  String getPersonalBest(String metric) {
    if (_combinedRecords.isEmpty) return "0";
    if (metric == 'streak') return _calculateBestStreak().toString();

    double maxVal = 0;
    for (var r in _combinedRecords) {
      double val = 0;
      switch (metric) {
        case 'steps':
          val = r.steps.toDouble();
          break;
        case 'calories':
          val = r.calories.toDouble();
          break;
        case 'water':
          val = r.water.toDouble();
          break;
        case 'sleep':
          val = r.sleep;
          break;
        case 'heartRate':
          val = r.heartRate.toDouble();
          break;
        case 'weight':
          val = r.weight ?? 0;
          break;
        case 'fruits':
          val = (r.fruits ?? 0).toDouble();
          break;
        case 'workout':
          val = (r.workout ?? 0).toDouble();
          break;
        case 'mood':
          val = r.mood.toDouble();
          break;
      }
      if (val > maxVal) maxVal = val;
    }

    if (['steps', 'calories', 'water'].contains(metric)) {
      if (maxVal >= 1000) return '${(maxVal / 1000).toStringAsFixed(1)}k';
      return maxVal.toInt().toString();
    }
    return maxVal
        .toStringAsFixed(metric == 'sleep' || metric == 'weight' ? 1 : 0);
  }

  // Get Current Streak
  String get currentStreak {
    if (_combinedRecords.isEmpty) return "0";
    final sorted = List<HealthRecord>.from(_combinedRecords);
    sorted.sort((a, b) => b.date.compareTo(a.date));

    List<DateTime> uniqueDays = [];
    DateTime? lastAdded;
    for (var r in sorted) {
      final date = r.date.toLocal();
      final day = DateTime(date.year, date.month, date.day);
      if (lastAdded == null || !_isSameDay(day, lastAdded)) {
        uniqueDays.add(day);
        lastAdded = day;
      }
    }

    if (uniqueDays.isEmpty) return "0";
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final latest = uniqueDays.first;
    final diffFromToday = todayMidnight.difference(latest).inDays;

    if (diffFromToday > 1) return "0";

    int streak = 1;
    DateTime previousDate = uniqueDays.first;
    for (int i = 1; i < uniqueDays.length; i++) {
      final currentDate = uniqueDays[i];
      final difference = previousDate.difference(currentDate).inDays;
      if (difference == 1) {
        streak++;
      } else {
        break;
      }
      previousDate = currentDate;
    }
    return streak.toString();
  }

  // Calculate Best Streak
  int _calculateBestStreak() {
    if (_combinedRecords.isEmpty) return 0;
    final sorted = List<HealthRecord>.from(_combinedRecords);
    sorted.sort((a, b) => a.date.compareTo(b.date));

    int maxStreak = 0;
    int currentRun = 0;
    DateTime? prevDate;

    for (var record in sorted) {
      final date = record.date.toLocal();
      if (prevDate == null) {
        currentRun = 1;
      } else {
        if (_isSameDay(date, prevDate))
          continue;
        else if (_isSameDay(date, prevDate.add(const Duration(days: 1)))) {
          currentRun++;
        } else {
          if (currentRun > maxStreak) maxStreak = currentRun;
          currentRun = 1;
        }
      }
      prevDate = date;
    }
    if (currentRun > maxStreak) maxStreak = currentRun;
    return maxStreak;
  }

  // Calculate Number of Goals Completed
  String calculateGoalsCompleted(Map<String, dynamic> goals) {
    if (todayRecord == null) return "0/9";
    int completed = 0;
    final r = todayRecord!;
    if (r.steps >= (goals['steps'] ?? 10000)) completed++;
    if (r.calories >= (goals['calories'] ?? 500)) completed++;
    if (r.water >= (goals['water'] ?? 2000)) completed++;
    if (r.sleep >= (goals['sleep'] ?? 8)) completed++;
    if (r.heartRate > 0 && r.heartRate <= (goals['heartRate'] ?? 100))
      completed++;
    if ((r.weight ?? 0) > 0) completed++;
    if ((r.fruits ?? 0) >= (goals['fruits'] ?? 5)) completed++;
    if ((r.workout ?? 0) >= (goals['workout'] ?? 30)) completed++;
    if (r.mood >= (goals['mood'] ?? 8)) completed++;
    return "$completed/9";
  }

  // Calculate Health Score
  String calculateHealthScore(Map<String, dynamic> goals) {
    if (todayRecord == null) return "0";

    double score = 0;
    final r = todayRecord!;

    if (r.steps >= (goals['steps'] ?? 10000)) score += 20;
    if (r.sleep >= (goals['sleep'] ?? 8)) score += 20;
    if (r.water >= (goals['water'] ?? 2000)) score += 20;
    if (r.workout != null && r.workout! >= (goals['workout'] ?? 30)) score += 20;
    if (r.mood >= 8) score += 20;

    return score.toInt().clamp(0, 100).toString();
  }

  // Check If It's Same Date
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  @override
  void dispose() {
    _firestoreSub?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}
