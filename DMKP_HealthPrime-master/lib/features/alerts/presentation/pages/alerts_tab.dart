import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthprime/core/providers/alert_provider.dart';
import 'package:healthprime/core/providers/friends_provider.dart';
import 'package:healthprime/core/providers/tournament_provider.dart';
import 'package:healthprime/features/tournaments/presentation/widgets/tournament_overlays.dart';
import 'package:healthprime/features/alerts/presentation/widgets/alert_item.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../core/utils/helpers.dart';

class AlertsPage extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAccountTap;

  const AlertsPage({
    super.key,
    this.onNotificationTap,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfef9f5),
      body: Column(
        children: [
          AppHeader(
            title: 'Notifications',
            showNotification: true,
            showAccount: true,
            onNotificationTap: onNotificationTap,
            onAccountTap: onAccountTap,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notifications,
                          color: Color(0xFFff7e5f), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Consumer3<AlertProvider, FriendsProvider,
                        TournamentProvider>(
                      builder: (context, alertsProvider, friendsProvider,
                          tournamentProvider, _) {
                        final alerts = alertsProvider.alerts;

                        if (alerts.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_off_outlined,
                                    size: 50, color: Colors.grey),
                                SizedBox(height: 10),
                                Text("No notifications",
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];

                            final date = DateTime.parse(alert['date']);
                            final diff = DateTime.now().difference(date);
                            String timeAgo = '';
                            if (diff.inMinutes < 60)
                              timeAgo = '${diff.inMinutes} min ago';
                            else if (diff.inHours < 24)
                              timeAgo = '${diff.inHours} hours ago';
                            else
                              timeAgo = '${diff.inDays} days ago';
                            if (diff.inMinutes < 1) timeAgo = 'Just now';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AlertItem(
                                type: alert['type'],
                                title: alert['title'],
                                message: alert['message'],
                                time: timeAgo,
                                unread: alert['read'] == false,

                                // Dismiss Alert
                                onDismiss: () async {
                                  await alertsProvider.dismissAlert(alert['id']);
                                },

                                // Accept Friend Request
                                showAccept: alert['type'] == 'friend-request' &&
                                    alert['read'] == false,
                                onAccept: () async {
                                  try {
                                    final friendUid =
                                    alert['data']['friendUid'];
                                    final request = friendsProvider.requests
                                        .firstWhere(
                                            (r) => r['uid'] == friendUid,
                                        orElse: () => {});

                                    if (request.isNotEmpty) {
                                      await friendsProvider.acceptFriendRequest(
                                          request['uid'],
                                          request['name'],
                                          request['email'],
                                          request['avatarInitial']);

                                      await alertsProvider.dismissAlert(alert['id']);

                                      if (context.mounted) {
                                        Helpers.showSnackBar(context, "Friend request accepted", isError: false);
                                      }
                                    } else {
                                      await alertsProvider.dismissAlert(alert['id']);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      Helpers.showSnackBar(context, "Error: $e", isError: true);
                                    }
                                  }
                                },

                                // View Tournament
                                showView: alert['type'] == 'tournament' ||
                                    alert['type'] == 'system',
                                onView: () {
                                  final tId = alert['data']['tournamentId'];
                                  try {
                                    final t = tournamentProvider
                                        .availableTournaments
                                        .firstWhere((x) => x.id == tId,
                                        orElse: () => tournamentProvider
                                            .activeTournaments
                                            .firstWhere((x) => x.id == tId,
                                            orElse: () => tournamentProvider
                                                .pastTournaments
                                                .firstWhere(
                                                    (x) => x.id == tId,
                                                orElse: () => throw "Tournament not found")));

                                    if (t.status == 'active' && t.isJoined) {
                                      showDialog(
                                          context: context,
                                          builder: (_) =>
                                              TournamentProgressOverlay(
                                                  tournamentId: tId,
                                                  tournament: t));
                                    } else if (t.status == 'ended') {
                                      showDialog(
                                          context: context,
                                          builder: (_) => ViewTournamentOverlay(
                                              tournamentId: tId,
                                              tournament: t,
                                              isEnded: true));
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (_) => ViewTournamentOverlay(
                                              tournamentId: tId, tournament: t));
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      Helpers.showSnackBar(context, "Tournament not found", isError: true);
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}