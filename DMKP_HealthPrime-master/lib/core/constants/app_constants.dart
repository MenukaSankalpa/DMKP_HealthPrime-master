import 'dart:ui';

class AppConstants {
  static const String appName = 'HealthPrime';

  static const Color successColor = Color(0xFF66bb6a);

  static const List<String> healthMetrics = [
    'Steps',
    'Calories',
    'Water',
    'Sleep',
    'Heart Rate',
    'Weight',
    'Fruits',
    'Workout',
    'Mood',
  ];

  static const Map<String, String> metricIcons = {
    'Steps': 'fas fa-shoe-prints',
    'Calories': 'fas fa-fire',
    'Water': 'fas fa-tint',
    'Sleep': 'fas fa-bed',
    'Heart Rate': 'fas fa-heart',
    'Weight': 'fas fa-weight',
    'Fruits': 'fas fa-apple-alt',
    'Workout': 'fas fa-dumbbell',
    'Mood': 'fas fa-smile',
  };

  static const Map<String, Color> metricColors = {
    'Steps': Color(0xFF66bb6a),
    'Calories': Color(0xFFef5350),
    'Water': Color(0xFF42a5f5),
    'Sleep': Color(0xFFab47bc),
    'Heart Rate': Color(0xFFff7043),
    'Weight': Color(0xFF26a69a),
    'Fruits': Color(0xFFffca28),
    'Workout': Color(0xFF5c6bc0),
    'Mood': Color(0xFFff7e5f),
  };

  static const Map<String, double> defaultGoals = {
    'Steps': 10000.0,
    'Calories': 500.0,
    'Water': 2000.0,
    'Sleep': 8.0,
    'Heart Rate': 70.0,
    'Weight': 70.0,
    'Fruits': 5.0,
    'Workout': 60.0,
    'Mood': 10.0,
  };

  static const Map<String, String> metricUnits = {
    'Steps': '',
    'Calories': 'kcal',
    'Water': 'ml',
    'Sleep': 'hrs',
    'Heart Rate': 'bpm',
    'Weight': 'kg',
    'Fruits': 'servings',
    'Workout': 'min',
    'Mood': '/10',
  };
}