import 'package:cloud_firestore/cloud_firestore.dart';

class HealthRecord {
  final String id;
  final DateTime date;
  final int steps;
  final int calories;
  final int water;
  final double sleep;
  final int heartRate;
  final double? weight;
  final int? fruits;
  final int? workout;
  final int mood;

  HealthRecord({
    required this.id,
    required this.date,
    this.steps = 0,
    this.calories = 0,
    this.water = 0,
    this.sleep = 0.0,
    this.heartRate = 0,
    this.weight,
    this.fruits,
    this.workout,
    this.mood = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'steps': steps,
      'calories': calories,
      'water': water,
      'sleep': sleep,
      'heartRate': heartRate,
      'weight': weight,
      'fruits': fruits,
      'workout': workout,
      'mood': mood,
    };
  }

  factory HealthRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthRecord(
      id: doc.id,
      date: data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      steps: data['steps'] ?? 0,
      calories: data['calories'] ?? 0,
      water: data['water'] ?? 0,
      sleep: (data['sleep'] ?? 0).toDouble(),
      heartRate: data['heartRate'] ?? 0,
      weight: (data['weight'] ?? 0).toDouble(),
      fruits: data['fruits'] ?? 0,
      workout: data['workout'] ?? 0,
      mood: data['mood'] ?? 0,
    );
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date']),
      steps: map['steps'] ?? 0,
      calories: map['calories'] ?? 0,
      water: map['water'] ?? 0,
      sleep: (map['sleep'] ?? 0).toDouble(),
      heartRate: map['heartRate'] ?? 0,
      weight: map['weight'] != null ? (map['weight']).toDouble() : 0.0,
      fruits: map['fruits'] ?? 0,
      workout: map['workout'] ?? 0,
      mood: map['mood'] ?? 0,
    );
  }
}