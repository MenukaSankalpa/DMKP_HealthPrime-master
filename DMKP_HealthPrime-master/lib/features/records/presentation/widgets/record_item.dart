import 'package:flutter/material.dart';
import 'package:healthprime/core/utils/helpers.dart';
import 'package:healthprime/data/models/health_record.dart';
import 'package:healthprime/features/home/presentation/widgets/add_edit_record_overlay.dart';

class RecordItem extends StatelessWidget {
  final HealthRecord record;

  const RecordItem({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AddEditRecordOverlay(
            isEditing: true,
            record: record,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFffe8d6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 0),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Color(0xFFff7e5f), size: 12),
                    const SizedBox(width: 6),
                    Text(
                      Helpers.formatRecordDate(record.date),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildStatItem(
                    icon: Icons.directions_walk,
                    value: Helpers.formatNumber(record.steps.toDouble()),
                    label: 'Steps'),
                _buildStatItem(
                    icon: Icons.local_fire_department,
                    value: record.calories.toString(),
                    label: 'Calories'),
                _buildStatItem(
                    icon: Icons.water_drop,
                    value: record.water.toString(),
                    label: 'Water'),
                _buildStatItem(
                    icon: Icons.bedtime,
                    value: record.sleep.toString(),
                    label: 'Sleep'),
                _buildStatItem(
                    icon: Icons.favorite,
                    value: record.heartRate.toString(),
                    label: 'Heart'),
                _buildStatItem(
                    icon: Icons.monitor_weight,
                    value: record.weight?.toString() ?? '-',
                    label: 'Weight'),
                _buildStatItem(
                    icon: Icons.apple,
                    value: record.fruits?.toString() ?? '-',
                    label: 'Fruits'),
                _buildStatItem(
                    icon: Icons.fitness_center,
                    value: record.workout?.toString() ?? '-',
                    label: 'Workout'),
                _buildStatItem(
                    icon: Icons.sentiment_satisfied,
                    value: record.mood.toString(),
                    label: 'Mood'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: const Color(0xFFff7e5f)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333))),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
      ],
    );
  }
}
