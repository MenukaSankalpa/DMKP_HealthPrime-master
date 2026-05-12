import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PastTournamentItem extends StatelessWidget {
  final String name;
  final String type;
  final String metric;
  final int participants;
  final int rank;
  final VoidCallback onView;

  const PastTournamentItem({
    super.key,
    required this.name,
    required this.type,
    required this.metric,
    required this.participants,
    required this.rank,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    Color typeColor = const Color(0xFF4caf50);
    if (type == 'Friends') {
      typeColor = const Color(0xFFff7e5f);
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
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333).withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFff7e5f), Color(0xFFfeb47b)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Rank: $rank',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: typeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events, size: 14, color: Color(0xFF666666)),
                  const SizedBox(width: 5),
                  Text(
                    metric,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.people, size: 14, color: Color(0xFF666666)),
                  const SizedBox(width: 5),
                  Text(
                    participants.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onView,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF333333),
                backgroundColor: const Color(0xFFfff9f2),
                side: const BorderSide(color: Color(0xFFffe8d6)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const FaIcon(FontAwesomeIcons.eye, size: 14),
              label: const Text('View Results', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}