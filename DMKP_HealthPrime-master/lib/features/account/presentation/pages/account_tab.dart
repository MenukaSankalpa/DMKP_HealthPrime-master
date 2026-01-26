import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/records_provider.dart';
import '../../../../core/providers/friends_provider.dart';
import '../../../../core/providers/tournament_provider.dart';
import '../../../../shared/widgets/app_header.dart';
import '../widgets/account_overlays.dart';
import '../widgets/profile_stat.dart';
import '../widgets/account_menu_item.dart';
import '../widgets/avatar_selector_overlay.dart';
import '../../../../core/utils/avatar_utils.dart';

class AccountPage extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAccountTap;

  const AccountPage({
    super.key,
    this.onNotificationTap,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final recordsProvider = Provider.of<RecordsProvider>(context);
    final friendsProvider = Provider.of<FriendsProvider>(context);
    final tournamentProvider = Provider.of<TournamentProvider>(context);

    final userData = auth.userData;
    final name = userData?['name'] ?? 'User';
    final email = auth.user?.email ?? 'user@example.com';
    final initial = userData?['avatarInitial'] ?? 'U';
    final String? avatarId = userData?['avatarId'];

    return Scaffold(
      backgroundColor: const Color(0xFFfef9f5),
      body: Column(
        children: [
          AppHeader(
            title: 'Account',
            showNotification: true,
            showAccount: true,
            onNotificationTap: onNotificationTap,
            onAccountTap: onAccountTap,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  // Profile Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFffe8d6)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFff7e5f).withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: avatarId != null ? Colors.white : const Color(0xFFff7e5f),
                                border: Border.all(color: const Color(0xFFff7e5f), width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: avatarId != null
                                  ? Icon(
                                AvatarUtils.getIcon(avatarId),
                                size: 60,
                                color: const Color(0xFFff7e5f),
                              )
                                  : Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => const AvatarSelectorOverlay(),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                      )
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Color(0xFFff7e5f),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(name,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF333333))),
                        const SizedBox(height: 5),
                        Text(email,
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF666666))),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ProfileStat(
                              value: recordsProvider.currentStreak,
                              label: 'Current Streak',
                            ),
                            ProfileStat(
                              value: friendsProvider.friends.length.toString(),
                              label: 'Friends',
                            ),
                            ProfileStat(
                              value: tournamentProvider.activeTournaments.length
                                  .toString(),
                              label: 'Active Tournaments',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Account Settings Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFffe8d6)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFff7e5f).withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.settings,
                                color: Color(0xFFff7e5f), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Account Settings',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        AccountMenuItem(
                          icon: Icons.edit,
                          title: 'Edit Profile',
                          description: 'Update your personal information',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => const EditProfileOverlay(),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        AccountMenuItem(
                          icon: Icons.lock,
                          title: 'Change Password',
                          description: 'Update your login password',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const ChangePasswordOverlay(),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        AccountMenuItem(
                          icon: Icons.notifications,
                          title: 'Notification Settings',
                          description: 'Manage your notification preferences',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const NotificationSettingsOverlay(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Health Goals Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFffe8d6)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFff7e5f).withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flag,
                                color: Color(0xFFff7e5f), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Health Goals',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        AccountMenuItem(
                          icon: Icons.flag,
                          title: 'Set Health Goals',
                          description: 'Customize your daily targets',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => const HealthGoalsOverlay(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Danger Zone Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFf44336).withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFff7e5f).withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning,
                                color: Color(0xFFf44336), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Danger Zone',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        AccountMenuItem(
                          icon: Icons.delete,
                          title: 'Delete Account',
                          description: 'Permanently delete your account',
                          danger: true,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const DeleteAccountOverlay(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Provider.of<AuthProvider>(context, listen: false)
                            .logout();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF333333),
                        backgroundColor: const Color(0xFFfff9f2),
                        side: const BorderSide(color: Color(0xFFffe8d6)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Logout'),
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
