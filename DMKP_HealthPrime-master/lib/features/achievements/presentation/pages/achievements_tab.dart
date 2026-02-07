import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthprime/core/providers/records_provider.dart';
import 'package:healthprime/features/achievements/presentation/widgets/medal_item.dart';
import 'package:healthprime/features/achievements/presentation/widgets/personal_best_item.dart';
import '../../../../shared/widgets/app_header.dart';

class AchievementsPage extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAccountTap;

  const AchievementsPage({
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
            title: 'Achievements',
            showNotification: true,
            showAccount: true,
            onNotificationTap: onNotificationTap,
            onAccountTap: onAccountTap,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Consumer<RecordsProvider>(
                builder: (context, provider, _) {
                  // Raw Values for Checking Thresholds
                  double maxSteps =
                      _parseVal(provider.getPersonalBest('steps'));
                  double maxCalories =
                      _parseVal(provider.getPersonalBest('calories'));
                  double maxWater =
                      _parseVal(provider.getPersonalBest('water'));
                  double maxSleep =
                      _parseVal(provider.getPersonalBest('sleep'));
                  double maxWorkout =
                      _parseVal(provider.getPersonalBest('workout'));
                  double bestStreak =
                      _parseVal(provider.getPersonalBest('streak'));

                  // Medals Logic
                  final medals = [
                    // Steps
                    _getMedal(
                        Icons.directions_walk, '5K Steps', maxSteps >= 5000),
                    _getMedal(
                        Icons.directions_run, '10K Steps', maxSteps >= 10000),
                    _getMedal(Icons.hiking, '20K Steps', maxSteps >= 20000),

                    // Calories
                    _getMedal(Icons.local_fire_department, '500 Cal',
                        maxCalories >= 500),
                    _getMedal(Icons.whatshot, '1000 Cal', maxCalories >= 1000),

                    // Water
                    _getMedal(Icons.water_drop, '2L Water', maxWater >= 2000),
                    _getMedal(Icons.opacity, '3L Water', maxWater >= 3000),

                    // Sleep
                    _getMedal(Icons.bedtime, '7h Sleep', maxSleep >= 7),
                    _getMedal(Icons.nights_stay, '8h Sleep', maxSleep >= 8),

                    // Workout
                    _getMedal(
                        Icons.fitness_center, '30m Workout', maxWorkout >= 30),
                    _getMedal(Icons.sports_gymnastics, '60m Workout',
                        maxWorkout >= 60),
                    _getMedal(Icons.timer, '90m Workout', maxWorkout >= 90),

                    // Streak
                    _getMedal(Icons.flash_on, '3 Day Streak', bestStreak >= 3),
                    _getMedal(
                        Icons.electric_bolt, '7 Day Streak', bestStreak >= 7),
                    _getMedal(
                        Icons.emoji_events, '30 Day Streak', bestStreak >= 30),
                  ];

                  return Column(
                    children: [
                      // Personal Best Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFffe8d6)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFff7e5f).withOpacity(0.15),
                              blurRadius: 8,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.star,
                                    color: Color(0xFFff7e5f), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Personal Best',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              crossAxisCount: 2,
                              childAspectRatio: 1.3,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              children: [
                                PersonalBestItem(
                                    icon: Icons.directions_walk,
                                    value: provider.getPersonalBest('steps'),
                                    label: 'Most Steps'),
                                PersonalBestItem(
                                    icon: Icons.local_fire_department,
                                    value: provider.getPersonalBest('calories'),
                                    label: 'Most Calories'),
                                PersonalBestItem(
                                    icon: Icons.water_drop,
                                    value: provider.getPersonalBest('water'),
                                    label: 'Most Water'),
                                PersonalBestItem(
                                    icon: Icons.bedtime,
                                    value: provider.getPersonalBest('sleep'),
                                    label: 'Most Sleep'),
                                PersonalBestItem(
                                    icon: Icons.favorite,
                                    value:
                                        provider.getPersonalBest('heartRate'),
                                    label: 'Highest Heart Rate'),
                                PersonalBestItem(
                                    icon: Icons.monitor_weight,
                                    value: provider.getPersonalBest('weight'),
                                    label: 'Weight Record'),
                                PersonalBestItem(
                                    icon: Icons.apple,
                                    value: provider.getPersonalBest('fruits'),
                                    label: 'Most Fruits'),
                                PersonalBestItem(
                                    icon: Icons.fitness_center,
                                    value: provider.getPersonalBest('workout'),
                                    label: 'Longest Workout'),
                                PersonalBestItem(
                                    icon: Icons.sentiment_satisfied,
                                    value: provider.getPersonalBest('mood'),
                                    label: 'Best Mood'),
                                PersonalBestItem(
                                    icon: Icons.whatshot,
                                    value: provider.getPersonalBest('streak'),
                                    label: 'Best Streak'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Medals Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFffe8d6)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFff7e5f).withOpacity(0.15),
                              blurRadius: 8,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.emoji_events,
                                    color: Color(0xFFff7e5f), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Achievements',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              crossAxisCount: 3,
                              childAspectRatio: 0.9,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              children: medals,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construct Medal
  Widget _getMedal(IconData icon, String text, bool isUnlocked) {
    return MedalItem(
      icon: icon,
      text: text,
      isUnlocked: isUnlocked,
    );
  }

  // Prase Value
  double _parseVal(String val) {
    // Remove Non Numeric Values Except Dots
    String clean = val.replaceAll(RegExp(r'[^\d.]'), '');
    if (clean.isEmpty) return 0;

    double num = double.tryParse(clean) ?? 0;

    // Use 'k' for Thousand
    if (val.contains('k')) num *= 1000;

    return num;
  }
}
