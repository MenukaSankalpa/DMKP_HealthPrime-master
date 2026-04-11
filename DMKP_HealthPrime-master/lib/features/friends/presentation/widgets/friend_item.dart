import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../core/utils/avatar_utils.dart';

class FriendItem extends StatelessWidget {
  final String uid;
  final String name;
  final String avatar;
  final String? avatarId;
  final VoidCallback onCompare;
  final VoidCallback onRemove;

  const FriendItem({
    super.key,
    required this.uid,
    required this.name,
    required this.avatar,
    this.avatarId,
    required this.onCompare,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final statusRef =
        FirebaseDatabase.instance.ref().child('status/$uid/state');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFfff9f2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFffe8d6)),
      ),
      child: Row(
        children: [
          // Avatar Section
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

          // Name & Live Status Section
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

                StreamBuilder<DatabaseEvent>(
                  stream: statusRef.onValue,
                  builder: (context, snapshot) {
                    String displayStatus = 'Offline';
                    Color statusColor = Colors.grey;

                    if (snapshot.hasData &&
                        snapshot.data!.snapshot.value != null) {
                      final state = snapshot.data!.snapshot.value as String;
                      if (state == 'online') {
                        displayStatus = 'Online';
                        statusColor = const Color(0xFF4caf50);
                      }
                    }

                    return Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          displayStatus,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // --- Action Buttons ---
          Row(
            children: [
              GestureDetector(
                onTap: onCompare,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFfff9f2),
                    border: Border.all(color: const Color(0xFFffe8d6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_up,
                      color: Color(0xFFff7e5f), size: 16),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFfff9f2),
                    border: Border.all(color: const Color(0xFFffe8d6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_remove,
                      color: Color(0xFFff7e5f), size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
