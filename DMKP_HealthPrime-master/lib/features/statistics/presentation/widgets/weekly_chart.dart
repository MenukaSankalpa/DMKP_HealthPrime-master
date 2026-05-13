import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyChart extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<double> values;
  final double maxValue;
  final String unit;

  const WeeklyChart({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.values,
    required this.maxValue,
    this.unit = '',
  });

  List<String> _getLast7Days() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DateFormat('E').format(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final labels = _getLast7Days();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFffe8d6)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 180,
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          return _buildBarItem(
                            value: values[index],
                            maxValue: maxValue,
                            color: color,
                            availableHeight: constraints.maxHeight,
                          );
                        }),
                      );
                    },
                  ),
                ),

                Container(
                  height: 1,
                  width: double.infinity,
                  color: const Color(0xFFffe8d6),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    return SizedBox(
                      width: 30,
                      child: Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF666666),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarItem({
    required double value,
    required double maxValue,
    required Color color,
    required double availableHeight,
  }) {
    // Calculate Height
    final percentage = (value / maxValue).clamp(0.0, 1.0);

    const double textHeight = 20.0;
    const double spacing = 4.0;

    final double maxBarHeight = availableHeight - textHeight - spacing;

    final double barHeight = maxBarHeight * percentage;

    // Format Display Text
    String displayValue = value.toStringAsFixed(1);
    if (value % 1 == 0) {
      displayValue = value.toInt().toString();
    }
    if (value >= 1000) {
      displayValue = '${(value / 1000).toStringAsFixed(1)}k';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Value Text
        SizedBox(
          height: textHeight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              displayValue,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ),
        const SizedBox(height: spacing),

        // Bar
        Container(
          height: barHeight > 0 ? barHeight : 0,
          width: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                color.withOpacity(0.7),
                color,
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}