import 'package:flutter/material.dart';

class AlertItem extends StatelessWidget {
  final String type;
  final String title;
  final String message;
  final String time;
  final bool unread;
  final bool showAccept;
  final bool showView;
  final VoidCallback? onAccept;
  final VoidCallback? onView;
  final VoidCallback? onDismiss;

  const AlertItem({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.unread,
    this.showAccept = false,
    this.showView = false,
    this.onAccept,
    this.onView,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    Color iconBgColor;

    switch (type) {
      case 'friend-request':
        icon = Icons.person_add;
        iconColor = const Color(0xFF4caf50);
        iconBgColor = const Color(0xFF4caf50).withOpacity(0.1);
        break;
      case 'tournament':
        icon = Icons.emoji_events;
        iconColor = const Color(0xFFff7e5f);
        iconBgColor = const Color(0xFFff7e5f).withOpacity(0.1);
        break;
      default:
        icon = Icons.notifications;
        iconColor = const Color(0xFF2196f3);
        iconBgColor = const Color(0xFF2196f3).withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: unread
            ? const Border(
                left: BorderSide(color: Color(0xFFff7e5f), width: 4),
              )
            : Border.all(
                color: const Color(0xFFffe8d6),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF999999),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (showAccept)
                      _buildActionButton(
                        label: 'Accept',
                        onTap: onAccept,
                        bgColor: const Color(0xFF4caf50).withOpacity(0.1),
                        textColor: const Color(0xFF4caf50),
                        borderColor: const Color(0xFF4caf50).withOpacity(0.3),
                      ),
                    if (showView)
                      _buildActionButton(
                        label: 'View',
                        onTap: onView,
                        bgColor: const Color(0xFFff7e5f).withOpacity(0.1),
                        textColor: const Color(0xFFff7e5f),
                        borderColor: const Color(0xFFff7e5f).withOpacity(0.3),
                      ),

                    _buildActionButton(
                      label: 'Dismiss',
                      onTap: onDismiss,
                      bgColor: const Color(0xFF9e9e9e).withOpacity(0.1),
                      textColor: const Color(0xFF666666),
                      borderColor: const Color(0xFF9e9e9e).withOpacity(0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onTap,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
