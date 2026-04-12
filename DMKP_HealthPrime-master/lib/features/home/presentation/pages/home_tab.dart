import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthprime/core/providers/records_provider.dart';
import 'package:healthprime/core/providers/auth_provider.dart';
import 'package:healthprime/shared/widgets/app_header.dart';
import 'package:healthprime/features/home/presentation/widgets/dashboard_grid.dart';
import 'package:healthprime/features/home/presentation/widgets/todays_values_grid.dart';
import 'package:healthprime/features/home/presentation/widgets/add_edit_record_overlay.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAccountTap;
  final VoidCallback? onAiTap;

  const HomePage({
    super.key,
    this.onNotificationTap,
    this.onAccountTap,
    this.onAiTap,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfef9f5),
      body: Column(
        children: [
          AppHeader(
            title: 'HealthPrime',
            showNotification: true,
            showAccount: true,
            onNotificationTap: widget.onNotificationTap,
            onAccountTap: widget.onAccountTap,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: Consumer2<RecordsProvider, AuthProvider>(
                  builder: (context, recordsProvider, authProvider, _) {
                    final goals = authProvider.healthGoals ?? {};

                    return Column(
                      children: [
                        DashboardGrid(
                          healthScore: recordsProvider.calculateHealthScore(goals),
                          activeDays: recordsProvider.activeDays,
                          currentStreak: recordsProvider.currentStreak,
                          goalsCompleted: recordsProvider.calculateGoalsCompleted(goals),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: widget.onAiTap,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFff7e5f), Color(0xFFfeb47b)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFff7e5f).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "AI Health Insights",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Get personalized suggestions",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.95),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.auto_awesome,
                                      color: Colors.white, size: 24),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFffe8d6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Color(0xFFff7e5f), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Today's Values",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),
                              TodaysValuesGrid(
                                todayRecord: recordsProvider.todayRecord,
                                userGoals: goals,
                                onValueClicked: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AddEditRecordOverlay(
                                      isEditing: recordsProvider.todayRecord != null,
                                      record: recordsProvider.todayRecord,
                                    ),
                                  );
                                },
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
          ),
        ],
      ),
    );
  }
}