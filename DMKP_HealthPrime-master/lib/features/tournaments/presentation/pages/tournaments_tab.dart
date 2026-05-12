import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/tournament_provider.dart';
import '../widgets/tournament_overlays.dart';
import '../widgets/tournament_item.dart';
import '../widgets/past_tournament_item.dart';
import '../widgets/section_header.dart';
import '../../../../shared/widgets/app_header.dart';

class TournamentsPage extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAccountTap;

  const TournamentsPage({
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
            title: 'Tournaments',
            showNotification: true,
            showAccount: true,
            onNotificationTap: onNotificationTap,
            onAccountTap: onAccountTap,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Consumer<TournamentProvider>(
                builder: (context, provider, _) {
                  return Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.emoji_events, color: Color(0xFFff7e5f)),
                              SizedBox(width: 8),
                              Text(
                                'Tournaments',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (c) => const AddEditTournamentOverlay(),
                            ),
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('Create'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFff7e5f),
                              foregroundColor: Colors.white,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Active Tournaments
                      if (provider.activeTournaments.isNotEmpty) ...[
                        const SectionHeader(
                          icon: Icons.directions_walk,
                          title: 'Active Tournaments',
                        ),
                        const SizedBox(height: 15),
                        ...provider.activeTournaments.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TournamentItem(
                            name: t.name,
                            type: t.type,
                            metric: t.metric,
                            participants: t.participants.length,
                            joined: true,
                            creatorId: t.creatorId,
                            // Open View Overlay
                            onView: () => showDialog(
                              context: context,
                              builder: (c) => ViewTournamentOverlay(
                                tournamentId: t.id,
                                tournament: t,
                              ),
                            ),
                            // Open Progress Overlay
                            onProgress: () => showDialog(
                              context: context,
                              builder: (c) => TournamentProgressOverlay(
                                tournamentId: t.id,
                                tournament: t,
                              ),
                            ),
                            onEdit: () => showDialog(
                              context: context,
                              builder: (c) => AddEditTournamentOverlay(
                                tournament: t,
                              ),
                            ),
                          ),
                        )),
                      ],

                      // Available Tournaments
                      const SizedBox(height: 20),
                      const SectionHeader(
                        icon: Icons.campaign,
                        title: 'Available Tournaments',
                      ),
                      const SizedBox(height: 15),
                      if (provider.availableTournaments.isEmpty)
                        const Text(
                          "No tournaments available to join.",
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ...provider.availableTournaments.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TournamentItem(
                            name: t.name,
                            type: t.type,
                            metric: t.metric,
                            participants: t.participants.length,
                            joined: false,
                            creatorId: t.creatorId,
                            onView: () => showDialog(
                              context: context,
                              builder: (c) => ViewTournamentOverlay(
                                tournamentId: t.id,
                                tournament: t,
                              ),
                            ),
                            onJoin: () => provider.joinTournament(t.id),
                            onEdit: () => showDialog(
                              context: context,
                              builder: (c) => AddEditTournamentOverlay(
                                tournament: t,
                              ),
                            ),
                          ),
                        )),

                      // Past Tournaments
                      if (provider.pastTournaments.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const SectionHeader(
                          icon: Icons.history,
                          title: 'Past Tournaments',
                        ),
                        const SizedBox(height: 15),
                        ...provider.pastTournaments.map((t) {
                          return FutureBuilder<int>(
                            future: provider.getPastTournamentRank(t.id),
                            builder: (context, snapshot) {
                              final rank = snapshot.data ?? 0;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: PastTournamentItem(
                                  name: t.name,
                                  type: t.type,
                                  metric: t.metric,
                                  participants: t.participants.length,
                                  rank: rank,
                                  onView: () => showDialog(
                                    context: context,
                                    builder: (c) => ViewTournamentOverlay(
                                      tournamentId: t.id,
                                      tournament: t,
                                      isEnded: true,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ]
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
}