import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/providers/alert_provider.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showNotification;
  final bool showAccount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAccountTap;

  const AppHeader({
    super.key,
    required this.title,
    this.showNotification = false,
    this.showAccount = false,
    this.onNotificationTap,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFff7e5f), Color(0xFFfeb47b)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.heartPulse,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Notifications
              if (showNotification)
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: onNotificationTap,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Center(
                            child: Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          // Dynamic Badge Count
                          Consumer<AlertProvider>(
                              builder: (context, alertProvider, _) {
                                final count = alertProvider.unreadCount;
                                if (count == 0) return const SizedBox.shrink();

                                return Positioned(
                                  top: -5,
                                  right: -5,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFff3b30),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        count > 9 ? '9+' : count.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Account
              if (showAccount)
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onAccountTap,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}