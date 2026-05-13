import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';

class TournamentItem extends StatelessWidget {
  final String name;
  final String type;
  final String metric;
  final int participants;
  final bool joined;
  final String creatorId;
  final VoidCallback? onView;
  final VoidCallback? onProgress;
  final VoidCallback? onJoin;
  final VoidCallback? onEdit;

  const TournamentItem({
    super.key,
    required this.name,
    required this.type,
    required this.metric,
    required this.participants,
    required this.joined,
    required this.creatorId,
    this.onView,
    this.onProgress,
    this.onJoin,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).user?.uid;
    final isCreator = currentUserId == creatorId;

    Color typeColor = const Color(0xFF4caf50);
    if (type == 'friends') typeColor = const Color(0xFFff7e5f);
    if (type == 'private') typeColor = const Color(0xFF9c27b0);

    IconData metricIcon = FontAwesomeIcons.chartLine;
    switch (metric.toLowerCase()) {
      case 'steps':
        metricIcon = FontAwesomeIcons.shoePrints;
        break;
      case 'calories':
        metricIcon = FontAwesomeIcons.fire;
        break;
      case 'water':
        metricIcon = FontAwesomeIcons.droplet;
        break;
      case 'sleep':
        metricIcon = FontAwesomeIcons.bed;
        break;
      case 'workout':
        metricIcon = FontAwesomeIcons.dumbbell;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFffe8d6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 3)
        ],
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                    fontSize: 14)),
            Row(children: [
              if (isCreator)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFfff9f2),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.edit,
                        size: 14, color: Color(0xFFff7e5f)),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(type[0].toUpperCase() + type.substring(1),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: typeColor)),
              ),
            ])
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              FaIcon(metricIcon, size: 14, color: const Color(0xFF666666)),
              const SizedBox(width: 5),
              Text(metric[0].toUpperCase() + metric.substring(1),
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF666666)))
            ]),
            Row(children: [
              const Icon(Icons.people, size: 14, color: Color(0xFF666666)),
              const SizedBox(width: 5),
              Text('$participants',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF666666)))
            ]),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            if (joined)
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: onProgress,
                      style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF333333),
                          backgroundColor: const Color(0xFFfff9f2),
                          side: const BorderSide(color: Color(0xFFffe8d6)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      icon: const Icon(Icons.trending_up, size: 12),
                      label: const Text('Progress',
                          style: TextStyle(fontSize: 11)))),
            if (joined) const SizedBox(width: 8),
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: onView,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF333333),
                        backgroundColor: const Color(0xFFfff9f2),
                        side: const BorderSide(color: Color(0xFFffe8d6)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    icon: const Icon(Icons.remove_red_eye, size: 12),
                    label: const Text('View', style: TextStyle(fontSize: 11)))),
            if (!joined) const SizedBox(width: 8),
            if (!joined)
              Expanded(
                  child: OutlinedButton.icon(
                      onPressed: onJoin,
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFff7e5f),
                          side: const BorderSide(color: Color(0xFFff7e5f)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      icon: const Icon(Icons.login,
                          size: 12, color: Colors.white),
                      label: const Text('Join',
                          style:
                              TextStyle(fontSize: 11, color: Colors.white)))),
          ]),
        ],
      ),
    );
  }
}
