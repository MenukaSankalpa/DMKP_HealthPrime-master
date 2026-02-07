import 'package:flutter/material.dart';

class MedalItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isUnlocked;

  const MedalItem({
    super.key,
    required this.icon,
    required this.text,
    this.isUnlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    // If Unlocked Use Original Colors and If Locked Use Grey
    final gradientColors = isUnlocked
        ? [const Color(0xFFff7e5f), const Color(0xFFfeb47b)]
        : [Colors.grey.shade400, Colors.grey.shade300];

    final iconColor = isUnlocked ? Colors.white : Colors.grey.shade600;
    final textColor = isUnlocked ? const Color(0xFF666666) : Colors.grey.shade500;

    return Column(
      children: [
        Container(
          width: 60,
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            shape: BoxShape.circle,
            boxShadow: isUnlocked
                ? [BoxShadow(color: const Color(0xFFff7e5f).withOpacity(0.3), blurRadius: 8, spreadRadius: 2)]
                : [],
          ),
          child: ClipPath(
            clipper: HexagonClipper(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Create Hexagon Shape
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 1.0, size.height * 0.25)
      ..lineTo(size.width * 1.0, size.height * 0.75)
      ..lineTo(size.width * 0.5, size.height * 1.0)
      ..lineTo(size.width * 0.0, size.height * 0.75)
      ..lineTo(size.width * 0.0, size.height * 0.25)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}