import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../data/models/health_record.dart';

class TodaysValuesGrid extends StatelessWidget {
  final VoidCallback onValueClicked;
  final HealthRecord? todayRecord;
  final Map<String, dynamic> userGoals;

  const TodaysValuesGrid({
    super.key,
    required this.onValueClicked,
    this.todayRecord,
    required this.userGoals,
  });

  @override
  Widget build(BuildContext context) {
    double getVal(num? val) => (val ?? 0).toDouble();
    double getGoal(String key, double def) =>
        (userGoals[key] ?? def).toDouble();

    final Map<String, Map<String, dynamic>> metrics = {
      'Steps': {
        'icon': Icons.directions_walk,
        'value': getVal(todayRecord?.steps),
        'goal': getGoal('steps', 10000),
        'color': const Color(0xFF66bb6a),
        'unit': '',
      },
      'Calories': {
        'icon': Icons.local_fire_department,
        'value': getVal(todayRecord?.calories),
        'goal': getGoal('calories', 500),
        'color': const Color(0xFFef5350),
        'unit': 'kcal',
      },
      'Water': {
        'icon': Icons.water_drop,
        'value': getVal(todayRecord?.water),
        'goal': getGoal('water', 2000),
        'color': const Color(0xFF42a5f5),
        'unit': 'ml',
      },
      'Sleep': {
        'icon': Icons.bedtime,
        'value': getVal(todayRecord?.sleep),
        'goal': getGoal('sleep', 8),
        'color': const Color(0xFFab47bc),
        'unit': 'hrs',
      },
      'Heart Rate': {
        'icon': Icons.favorite,
        'value': getVal(todayRecord?.heartRate),
        'goal': getGoal('heartRate', 70),
        'color': const Color(0xFFff7043),
        'unit': 'bpm',
        'reverse': true,
      },
      'Weight': {
        'icon': Icons.monitor_weight,
        'value': getVal(todayRecord?.weight),
        'goal': getGoal('weight', 70),
        'color': const Color(0xFF26a69a),
        'unit': 'kg',
        'reverse': true,
      },
      'Fruits': {
        'icon': Icons.apple,
        'value': getVal(todayRecord?.fruits),
        'goal': getGoal('fruits', 5),
        'color': const Color(0xFFffca28),
        'unit': 'servings',
      },
      'Workout': {
        'icon': Icons.fitness_center,
        'value': getVal(todayRecord?.workout),
        'goal': getGoal('workout', 60),
        'color': const Color(0xFF5c6bc0),
        'unit': 'min',
      },
      'Mood': {
        'icon': Icons.sentiment_satisfied,
        'value': getVal(todayRecord?.mood),
        'goal': 10.0,
        'color': const Color(0xFFff7e5f),
        'unit': '/10',
      },
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 15;
        final double itemWidth = (constraints.maxWidth - spacing) / 2;
        final double itemHeight = itemWidth / 1.1;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: metrics.entries.map((entry) {
            final String metric = entry.key;
            final Map<String, dynamic> data = entry.value;

            double progress;
            double val = data['value'];
            double goal = data['goal'];

            if (data['reverse'] == true) {
              progress = val > 0 ? 100.0 : 0.0;
            } else {
              progress = (val / (goal == 0 ? 1 : goal)) * 100;
            }
            progress = progress.clamp(0, 100);

            return SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: _buildValueItem(
                metric: metric,
                icon: data['icon'] as IconData,
                value: data['value'],
                progress: progress,
                color: data['color'] as Color,
                unit: data['unit'] as String,
                onTap: onValueClicked,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildValueItem({
    required String metric,
    required IconData icon,
    required dynamic value,
    required double progress,
    required Color color,
    required String unit,
    required VoidCallback onTap,
  }) {
    String displayValue = value.toString();
    if (value is double && value % 1 == 0) {
      displayValue = value.toInt().toString();
    }

    if (metric == 'Steps' && (value as double) >= 1000) {
      displayValue = '${(value / 1000).toStringAsFixed(1)}k';
    } else if (metric == 'Water' && (value as double) >= 1000) {
      displayValue = '${(value / 1000).toStringAsFixed(1)}L';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFfff9f2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFffe8d6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircularPercentIndicator(
                  radius: 35,
                  lineWidth: 8,
                  percent: progress / 100,
                  center: Text(
                    displayValue,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  backgroundColor: const Color(0xFFffe8d6),
                  progressColor: color,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 14, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              metric,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              unit,
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }
}
