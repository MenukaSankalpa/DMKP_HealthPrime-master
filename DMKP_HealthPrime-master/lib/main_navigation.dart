import 'package:flutter/material.dart';
import 'package:healthprime/features/home/presentation/pages/home_tab.dart';
import 'package:healthprime/features/records/presentation/pages/records_tab.dart';
import 'package:healthprime/features/statistics/presentation/pages/statistics_tab.dart';
import 'package:healthprime/features/achievements/presentation/pages/achievements_tab.dart';
import 'package:healthprime/features/friends/presentation/pages/friends_tab.dart';
import 'package:healthprime/features/tournaments/presentation/pages/tournaments_tab.dart';
import 'package:healthprime/features/alerts/presentation/pages/alerts_tab.dart';
import 'package:healthprime/features/account/presentation/pages/account_tab.dart';
import 'package:provider/provider.dart';
import 'package:healthprime/core/providers/alert_provider.dart';
import 'package:healthprime/features/home/presentation/pages/ai_insights_tab.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  Widget? _overlayPage;

  void _showAlertsPage() {
    setState(() {
      if (_overlayPage is AlertsPage) {
        _overlayPage = null;
        Provider.of<AlertProvider>(context, listen: false).markAllAsRead();
      } else {
        _overlayPage = AlertsPage(
          onNotificationTap: _showAlertsPage,
          onAccountTap: _showAccountPage,
        );
      }
    });
  }

  void _showAccountPage() {
    setState(() {
      if (_overlayPage is AlertsPage) {
        Provider.of<AlertProvider>(context, listen: false).markAllAsRead();
      }

      if (_overlayPage is AccountPage) {
        _overlayPage = null;
      } else {
        _overlayPage = AccountPage(
          onNotificationTap: _showAlertsPage,
          onAccountTap: _showAccountPage,
        );
      }
    });
  }

  void _showAiInsights() {
    setState(() {
      _selectedIndex = 6;
      _overlayPage = null;
    });
  }

  void _onItemTapped(int index) {
    if (_overlayPage is AlertsPage) {
      Provider.of<AlertProvider>(context, listen: false).markAllAsRead();
    }
    setState(() {
      _selectedIndex = index;
      _overlayPage = null;
    });
  }

  Future<bool> _onWillPop() async {
    if (_overlayPage != null) {
      if (_overlayPage is AlertsPage) {
        Provider.of<AlertProvider>(context, listen: false).markAllAsRead();
      }
      setState(() {
        _overlayPage = null;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        onNotificationTap: _showAlertsPage,
        onAccountTap: _showAccountPage,
        onAiTap: _showAiInsights,
      ),
      RecordsPage(
        onNotificationTap: _showAlertsPage,
        onAccountTap: _showAccountPage,
      ),
      StatisticsPage(
        onNotificationTap: _showAlertsPage,
        onAccountTap: _showAccountPage,
      ),
      AchievementsPage(
        onNotificationTap: _showAlertsPage,
        onAccountTap: _showAccountPage,
      ),
      FriendsPage(
        onNotificationTap: _showAlertsPage,
        onAccountTap: _showAccountPage,
      ),
      TournamentsPage(
        onNotificationTap: _showAlertsPage,
        onAccountTap: _showAccountPage,
      ),
      AiInsightsPage(
        onNotificationTap: _showAlertsPage,
        onAccountTap: _showAccountPage,
      ),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            // Main Content
            pages[_selectedIndex],

            // Overlay Content (Alerts, Account)
            if (_overlayPage != null)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: _overlayPage!,
                ),
              ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFfff9f2),
            border: Border(top: BorderSide(color: Color(0xFFffe8d6))),
          ),
          child: SafeArea(
            child: Row(
              children: [
                _buildNavItem(0, Icons.home, 'Home'),
                _buildNavItem(1, Icons.history, 'Records'),
                _buildNavItem(2, Icons.bar_chart, 'Stats'),
                _buildNavItem(3, Icons.emoji_events, 'Achieve'),
                _buildNavItem(4, Icons.people, 'Friends'),
                _buildNavItem(5, Icons.flag, 'Compete'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = (_overlayPage == null) && (_selectedIndex == index);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color:
                    isSelected ? const Color(0xFFff7e5f) : Colors.transparent,
                width: 3,
              ),
            ),
            color: isSelected ? Colors.white : const Color(0xFFfff9f2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFFff7e5f)
                    : const Color(0xFF666666),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFFff7e5f)
                      : const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
