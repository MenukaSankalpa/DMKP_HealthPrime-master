import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:healthprime/core/providers/friends_provider.dart';
import 'package:healthprime/features/friends/presentation/widgets/add_friend_overlay.dart';
import 'package:healthprime/features/friends/presentation/widgets/comparison_overlay.dart';
import 'package:healthprime/features/friends/presentation/widgets/friend_item.dart';
import 'package:healthprime/features/friends/presentation/widgets/friend_request_item.dart';
import 'package:healthprime/features/friends/presentation/widgets/pending_invite_item.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../core/utils/helpers.dart';

class FriendsPage extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAccountTap;

  const FriendsPage({super.key, this.onNotificationTap, this.onAccountTap});

  // Check Connection Status
  Future<void> _checkConnectivityAndRun(
      BuildContext context, VoidCallback action, String errorMessage) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      Helpers.showSnackBar(context, errorMessage, isError: true);
    } else {
      action();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfef9f5),
      body: Column(
        children: [
          AppHeader(
              title: 'Friends',
              showNotification: true,
              showAccount: true,
              onNotificationTap: onNotificationTap,
              onAccountTap: onAccountTap),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Consumer<FriendsProvider>(
                builder: (context, provider, _) {
                  return Column(
                    children: [
                      // Requests Section
                      if (provider.requests.isNotEmpty)
                        _buildSectionContainer(
                          title: 'Friend Requests',
                          icon: Icons.person_add,
                          child: Column(
                            children: provider.requests
                                .map((req) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: FriendRequestItem(
                                        name: req['name'] ?? 'Unknown',
                                        avatar: req['avatarInitial'] ?? 'U',
                                        avatarId: req['avatarId'],
                                        date: _formatDate(req['date']),
                                        onAccept: () =>
                                            provider.acceptFriendRequest(
                                                req['uid'],
                                                req['name'],
                                                req['email'],
                                                req['avatarInitial'],
                                                friendAvatarId:
                                                    req['avatarId']),
                                        onReject: () => provider
                                            .rejectFriendRequest(req['uid']),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      if (provider.requests.isNotEmpty)
                        const SizedBox(height: 20),

                      // Friend List
                      _buildSectionContainer(
                        title: 'Your Friends',
                        icon: Icons.people,
                        headerAction: ElevatedButton.icon(
                          onPressed: () => _checkConnectivityAndRun(
                            context,
                            () => showDialog(
                                context: context,
                                builder: (context) => const AddFriendOverlay()),
                            "You are offline. Cannot add friends.",
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFff7e5f),
                              foregroundColor: Colors.white),
                          icon: const Icon(Icons.person_add, size: 14),
                          label: const Text('Add Friend',
                              style: TextStyle(fontSize: 12)),
                        ),
                        child: provider.friends.isEmpty
                            ? _buildEmptyState('No friends yet',
                                'Add friends to compare stats')
                            : Column(
                                children: provider.friends
                                    .map((friend) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: FriendItem(
                                            uid: friend['uid'],
                                            name: friend['name'] ?? 'Unknown',
                                            avatar:
                                                friend['avatarInitial'] ?? 'U',
                                            avatarId: friend['avatarId'],
                                            onCompare: () =>
                                                _checkConnectivityAndRun(
                                              context,
                                              () => showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    ComparisonOverlay(
                                                  friendUid: friend['uid'],
                                                  friendName: friend['name'],
                                                  friendAvatar:
                                                      friend['avatarInitial'],
                                                  friendAvatarId:
                                                      friend['avatarId'],
                                                ),
                                              ),
                                              "You are offline. Cannot compare stats.",
                                            ),
                                            onRemove: () => provider
                                                .removeFriend(friend['uid']),
                                          ),
                                        ))
                                    .toList(),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Pending Sent Requests
                      _buildSectionContainer(
                        title: 'Pending Invites',
                        icon: Icons.send,
                        child: provider.pendingSent.isEmpty
                            ? _buildEmptyState('No pending invites',
                                'Invites you send appear here')
                            : Column(
                                children: provider.pendingSent
                                    .map((invite) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: PendingInviteItem(
                                            name: invite['name'] ?? 'Unknown',
                                            avatar:
                                                invite['avatarInitial'] ?? 'U',
                                            avatarId:
                                                invite['avatarId'],
                                            date: _formatDate(invite['date']),
                                            onCancel: () => provider
                                                .cancelInvite(invite['uid']),
                                          ),
                                        ))
                                    .toList(),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Format Date
  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Unknown';
    try {
      final date = DateTime.parse(isoDate);
      return Helpers.formatRecordDate(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildSectionContainer(
      {required String title,
      required IconData icon,
      required Widget child,
      Widget? headerAction}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFffe8d6))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(icon, color: const Color(0xFFff7e5f), size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333))),
              ]),
              if (headerAction != null) headerAction,
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const Icon(Icons.group_off, size: 40, color: Color(0xFFffe8d6)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Color(0xFF666666))),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
          ],
        ),
      ),
    );
  }
}
