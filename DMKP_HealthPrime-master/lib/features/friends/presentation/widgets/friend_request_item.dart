import 'package:flutter/material.dart';
import '../../../../core/utils/avatar_utils.dart';

class FriendRequestItem extends StatelessWidget {
  final String name;
  final String avatar;
  final String? avatarId;
  final String date;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const FriendRequestItem({
    super.key,
    required this.name,
    required this.avatar,
    this.avatarId,
    required this.date,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFfff9f2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFffe8d6)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: avatarId != null ? Colors.white : null,
              gradient: avatarId != null
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFff7e5f), Color(0xFFfeb47b)],
                    ),
              shape: BoxShape.circle,
              border: avatarId != null
                  ? Border.all(color: const Color(0xFFff7e5f), width: 1.5)
                  : null,
            ),
            child: Center(
              child: avatarId != null
                  ? Icon(
                      AvatarUtils.getIcon(avatarId),
                      color: const Color(0xFFff7e5f),
                      size: 24,
                    )
                  : Text(
                      avatar,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sent $date',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onAccept,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4caf50).withOpacity(0.1),
                    border: Border.all(
                        color: const Color(0xFF4caf50).withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check,
                      color: Color(0xFF4caf50), size: 18),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onReject,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFf44336).withOpacity(0.1),
                    border: Border.all(
                        color: const Color(0xFFf44336).withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close,
                      color: Color(0xFFf44336), size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
