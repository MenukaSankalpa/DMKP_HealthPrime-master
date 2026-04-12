import 'package:flutter/material.dart';

class DashboardGrid extends StatelessWidget {
  final String healthScore;
  final String activeDays;
  final String currentStreak;
  final String goalsCompleted;

  const DashboardGrid({
    super.key,
    required this.healthScore,
    required this.activeDays,
    required this.currentStreak,
    required this.goalsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildDashboardCard(
          icon: Icons.favorite,
          iconColor: const Color(0xFF4caf50),
          title: 'Health Score',
          value: healthScore,
          subtext: 'Out of 100',
          trend: 'Based on today',
          isUp: true,
        ),
        _buildDashboardCard(
          icon: Icons.local_fire_department,
          iconColor: const Color(0xFFff7e5f),
          title: 'Active Days',
          value: activeDays,
          subtext: 'Total Records',
          trend: 'Keep tracking!',
          isUp: true,
        ),
        _buildDashboardCard(
          icon: Icons.flash_on,
          iconColor: const Color(0xFFffc107),
          title: 'Current Streak',
          value: currentStreak,
          subtext: 'Days in a row',
          trend: 'Consistancy is key',
          isUp: true,
        ),
        _buildDashboardCard(
          icon: Icons.track_changes,
          iconColor: const Color(0xFF9c27b0),
          title: 'Goals',
          value: goalsCompleted,
          subtext: 'Completed today',
          trend: 'Daily Targets',
          isUp: true,
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtext,
    required String trend,
    required bool isUp,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFffe8d6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 30,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFFff7e5f),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}
