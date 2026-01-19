import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationLogic {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> performScan(String uid) async {
    // Get User Settings
    final userDoc = await _db.collection('users').doc(uid).get();
    final settings =
        Map<String, bool>.from(userDoc.data()?['notificationSettings'] ?? {});

    List<String> friendUids = [];
    if (settings['tournamentUpdates'] == true) {
      try {
        final friendsSnap = await _db
            .collection('users')
            .doc(uid)
            .collection('friends')
            .get();
        friendUids = friendsSnap.docs.map((doc) => doc.id).toList();
      } catch (e) {
        print("Error fetching friends for notifications: $e");
      }
    }

    // Friend Requests
    if (settings['friendRequests'] == true) {
      final reqs = await _db
          .collection('users')
          .doc(uid)
          .collection('friend_requests')
          .get();
      for (var doc in reqs.docs) {
        await _createAlert(
          uid: uid,
          id: 'req_${doc.id}',
          type: 'friend-request',
          title: 'New Friend Request',
          body: '${doc['name']} sent you a request',
          data: {'friendUid': doc.id},
        );
      }
    }

    // Public Tournaments
    if (settings['publicTournaments'] == true) {
      final publicTournaments = await _db
          .collection('tournaments')
          .where('type', isEqualTo: 'public')
          .where('status', isEqualTo: 'upcoming')
          .get();

      for (var doc in publicTournaments.docs) {
        final data = doc.data();
        final String creatorId = data['creatorId'] ?? '';

        if (creatorId == uid) continue;

        await _createAlert(
          uid: uid,
          id: 'public_${doc.id}',
          type: 'system',
          title: 'New Public Tournament',
          body: '${data['name']} is open for joining!',
          data: {'tournamentId': doc.id},
        );
      }
    }

    // Tournament Updates and Reminders
    if (settings['tournamentUpdates'] == true ||
        settings['tournamentReminders'] == true) {
      final myTournaments = await _db
          .collection('tournaments')
          .where('participants', arrayContains: uid)
          .get();

      final now = DateTime.now();

      for (var doc in myTournaments.docs) {
        final data = doc.data();
        final String creatorId = data['creatorId'] ?? '';
        final String type = data['type'] ?? 'private';
        final String name = data['name'] ?? 'Tournament';
        final String status = data['status'] ?? 'upcoming';

        final Timestamp? startTs = data['startDate'];
        final Timestamp? endTs = data['endDate'];

        // Tournament Updates
        if (settings['tournamentUpdates'] == true) {
          // Invites
          final invites = await _db
              .collection('tournaments')
              .where('invitedUsers', arrayContains: uid)
              .get();

          for (var doc in invites.docs) {
            if (doc['status'] != 'ended') {
              await _createAlert(
                uid: uid,
                id: 'invite_${doc.id}',
                type: 'tournament',
                title: 'Tournament Invitation',
                body: 'You have been invited to ${doc['name']}',
                data: {'tournamentId': doc.id},
              );
            }
          }

          // Added
          final added = await _db
              .collection('tournaments')
              .where('participants', arrayContains: uid)
              .get();

          for (var doc in added.docs) {
            final data = doc.data();
            String creatorId = data['creatorId'] ?? '';

            if (creatorId != uid) {
              if (data['status'] != 'ended') {
                await _createAlert(
                  uid: uid,
                  id: 'added_${doc.id}',
                  type: 'tournament',
                  title: 'Tournament Update',
                  body: 'You were added to ${data['name']}',
                  data: {'tournamentId': doc.id},
                );
              }
            }
          }

          // Friends' Tournaments
          if (friendUids.isNotEmpty) {
            final friendTournaments = await _db
                .collection('tournaments')
                .where('type', isEqualTo: 'friends')
                .get();

            for (var doc in friendTournaments.docs) {
              final data = doc.data();
              if (data['status'] == 'ended') continue;

              String creatorId = data['creatorId'] ?? '';
              String creatorName = data['creatorName'] ?? 'A friend';
              List<dynamic> participants = data['participants'] ?? [];

              if (creatorId != uid && friendUids.contains(creatorId) && !participants.contains(uid)) {
                await _createAlert(
                  uid: uid,
                  id: 'friend_tourney_${doc.id}',
                  type: 'tournament',
                  title: 'New Friend Tournament',
                  body: '$creatorName created "${data['name']}"',
                  data: {'tournamentId': doc.id},
                );
              }
            }
          }
        }

        // Tournament Reminders
        if (settings['tournamentReminders'] == true &&
            startTs != null &&
            endTs != null) {
          final startDate = startTs.toDate();
          final endDate = endTs.toDate();

          // Starting Soon (0-3 days)
          if (status == 'upcoming') {
            final diff = startDate.difference(now).inDays;
            if (diff >= 0 && diff <= 3) {
              await _createAlert(
                uid: uid,
                id: 'start_soon_${doc.id}',
                type: 'tournament',
                title: 'Tournament Starting Soon',
                body:
                    '$name starts in ${diff == 0 ? "less than 24h" : "$diff days"}!',
                data: {'tournamentId': doc.id},
              );
            }
          }

          // Ending Soon (0-2 days)
          if (status == 'active') {
            final diff = endDate.difference(now).inDays;
            if (diff >= 0 && diff <= 2) {
              await _createAlert(
                uid: uid,
                id: 'end_soon_${doc.id}',
                type: 'tournament',
                title: 'Tournament Ending Soon',
                body:
                    '$name ends in ${diff == 0 ? "less than 24h" : "$diff days"}!',
                data: {'tournamentId': doc.id},
              );
            }
          }
        }
      }
    }
  }

  // Create Alert
  static Future<void> _createAlert({
    required String uid,
    required String id,
    required String type,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    final ref =
        _db.collection('users').doc(uid).collection('notifications').doc(id);

    final doc = await ref.get();

    // Prevent Duplicates
    if (doc.exists) return;

    await ref.set({
      'id': id,
      'type': type,
      'title': title,
      'message': body,
      'date': DateTime.now().toIso8601String(),
      'read': false,
      'dismissed': false,
      'data': data
    });

    await _showNotification(title, body);
  }

  // Show Notification
  static Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'hp_channel',
      'Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: android);

    await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000, title, body, details);
  }
}
