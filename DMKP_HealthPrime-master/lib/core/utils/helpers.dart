import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  static String formatDisplayDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  static String formatRecordDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  static String formatNumber(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toInt().toString();
  }

  static Color getProgressColor(double progress) {
    if (progress >= 100) return AppConstants.successColor;
    if (progress >= 75) return const Color(0xFF4caf50);
    if (progress >= 50) return const Color(0xFFff9800);
    return const Color(0xFFf44336);
  }

  static String getInitials(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;

    final isOffline = message.toLowerCase().contains('offline');

    final Color backgroundColor = isOffline
        ? const Color(0xFF757575)
        : (isError ? const Color(0xFFEF5350) : const Color(0xFF66BB6A));

    final IconData icon = isOffline
        ? Icons.wifi_off_rounded
        : (isError ? Icons.error_outline : Icons.check_circle_outline);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message.replaceAll('Exception: ', ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}