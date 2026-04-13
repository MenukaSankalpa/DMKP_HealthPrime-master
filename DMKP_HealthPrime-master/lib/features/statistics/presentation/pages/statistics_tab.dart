import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthprime/core/providers/records_provider.dart';
import 'package:healthprime/features/statistics/presentation/widgets/weekly_chart.dart';
import 'package:healthprime/features/statistics/presentation/widgets/stat_card.dart';
import '../../../../shared/widgets/app_header.dart';

class StatisticsPage extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAccountTap;

  const StatisticsPage({
    super.key,
    this.onNotificationTap,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfef9f5),
      body: Column(
        children: [
          AppHeader(
            title: 'Statistics',
            showNotification: true,
            showAccount: true,
            onNotificationTap: onNotificationTap,
            onAccountTap: onAccountTap,
          ),
          Expanded(
            child: Consumer<RecordsProvider>(
              builder: (context, provider, child) {
                final stepsData = provider.getWeeklyData('steps');
                final caloriesData = provider.getWeeklyData('calories');
                final waterData = provider.getWeeklyData('water');
                final sleepData = provider.getWeeklyData('sleep');
                final heartData = provider.getWeeklyData('heartRate');
                final weightData = provider.getWeeklyData('weight');
                final fruitsData = provider.getWeeklyData('fruits');
                final workoutData = provider.getWeeklyData('workout');
                final moodData = provider.getWeeklyData('mood');

                // Weekly Charts
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      WeeklyChart(
                        icon: Icons.directions_walk,
                        color: const Color(0xFF66bb6a),
                        title: 'Weekly Steps',
                        values: stepsData,
                        maxValue:
                            12000,
                      ),
                      const SizedBox(height: 15),
                      WeeklyChart(
                        icon: Icons.local_fire_department,
                        color: const Color(0xFFef5350),
                        title: 'Weekly Calories',
                        values: caloriesData,
                        maxValue: 600,
                        unit: 'kcal',
                      ),
                      const SizedBox(height: 15),
                      WeeklyChart(
                        icon: Icons.water_drop,
                        color: const Color(0xFF42a5f5),
                        title: 'Weekly Water (ml)',
                        values: waterData,
                        maxValue: 3000,
                      ),
                      const SizedBox(height: 15),
                      WeeklyChart(
                        icon: Icons.bedtime,
                        color: const Color(0xFFab47bc),
                        title: 'Weekly Sleep (hrs)',
                        values: sleepData,
                        maxValue: 12,
                      ),
                      const SizedBox(height: 15),
                      WeeklyChart(
                        icon: Icons.favorite,
                        color: const Color(0xFFff7043),
                        title: 'Avg Heart Rate (bpm)',
                        values: heartData,
                        maxValue: 150,
                      ),
                      const SizedBox(height: 15),
                      WeeklyChart(
                        icon: Icons.monitor_weight,
                        color: const Color(0xFF26a69a),
                        title: 'Weight Trend (kg)',
                        values: weightData,
                        maxValue: 100,
                      ),
                      const SizedBox(height: 15),
                      WeeklyChart(
                        icon: Icons.apple,
                        color: const Color(0xFFffca28),
                        title: 'Fruits (servings)',
                        values: fruitsData,
                        maxValue: 10,
                      ),
                      const SizedBox(height: 15),
                      WeeklyChart(
                        icon: Icons.fitness_center,
                        color: const Color(0xFF5c6bc0),
                        title: 'Workout (min)',
                        values: workoutData,
                        maxValue: 120,
                      ),
                      const SizedBox(height: 15),
                      WeeklyChart(
                        icon: Icons.sentiment_satisfied,
                        color: const Color(0xFFff7e5f),
                        title: 'Daily Mood',
                        values: moodData,
                        maxValue: 10,
                      ),

                      const SizedBox(height: 10),

                      // Summary Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          StatCard(
                              icon: Icons.list,
                              value: provider.records.length.toString(),
                              label: 'Total Records'),
                          StatCard(
                              icon: Icons.directions_walk,
                              value: provider.getAverage('steps'),
                              label: 'Avg Steps'),
                          StatCard(
                              icon: Icons.local_fire_department,
                              value: provider.getAverage('calories'),
                              label: 'Avg Calories'),
                          StatCard(
                              icon: Icons.water_drop,
                              value: provider.getAverage('water'),
                              label: 'Avg Water (ml)'),
                          StatCard(
                              icon: Icons.bedtime,
                              value: provider.getAverage('sleep'),
                              label: 'Avg Sleep (hrs)'),
                          StatCard(
                              icon: Icons.favorite,
                              value: provider.getAverage('heartRate'),
                              label: 'Avg Heart Rate'),
                          StatCard(
                              icon: Icons.monitor_weight,
                              value: provider.getAverage('weight'),
                              label: 'Avg Weight (kg)'),
                          StatCard(
                              icon: Icons.apple,
                              value: provider.getAverage('fruits'),
                              label: 'Avg Fruits'),
                          StatCard(
                              icon: Icons.fitness_center,
                              value: provider.getAverage('workout'),
                              label: 'Avg Workout (min)'),
                          StatCard(
                              icon: Icons.sentiment_satisfied,
                              value: provider.getAverage('mood'),
                              label: 'Avg Mood'),
                          StatCard(
                              icon: Icons.flash_on,
                              value: provider.currentStreak,
                              label: 'Current Streak'),
                          StatCard(
                              icon: Icons.whatshot,
                              value: provider.getPersonalBest('streak'),
                              label: 'Best Streak'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
