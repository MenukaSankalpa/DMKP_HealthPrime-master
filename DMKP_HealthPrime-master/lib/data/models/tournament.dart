import 'package:cloud_firestore/cloud_firestore.dart';

class Tournament {
  final String id;
  final String name;
  final String description;
  final String type; // 'public', 'friends', 'private'
  final String metric;
  final int minValue;
  final int duration;
  final DateTime startDate;
  final DateTime endDate;
  final String creatorId;
  final String creatorName;
  final List<String> participants;
  final String status; // 'active', 'upcoming', 'ended'
  final List<String>? invitedUsers;

  final bool isJoined;
  final int userProgress;
  final List<LeaderboardEntry> leaderboard;
  final List<Milestone> milestones;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.metric,
    required this.minValue,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.creatorId,
    required this.creatorName,
    required this.participants,
    required this.status,
    this.invitedUsers,
    this.isJoined = false,
    this.userProgress = 0,
    this.leaderboard = const [],
    this.milestones = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type,
      'metric': metric,
      'minValue': minValue,
      'duration': duration,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'creatorId': creatorId,
      'creatorName': creatorName,
      'participants': participants,
      'status': status,
      'invitedUsers': invitedUsers,
    };
  }

  factory Tournament.fromFirestore(DocumentSnapshot doc, String currentUserId) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<String> participantsList =
        List<String>.from(data['participants'] ?? []);
    bool joined = participantsList.contains(currentUserId);

    String status = data['status'] ?? 'upcoming';
    DateTime start = (data['startDate'] as Timestamp).toDate();
    DateTime end = (data['endDate'] as Timestamp).toDate();
    DateTime now = DateTime.now();

    if (now.isAfter(end))
      status = 'ended';
    else if (now.isAfter(start))
      status = 'active';
    else
      status = 'upcoming';

    return Tournament(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'public',
      metric: data['metric'] ?? 'steps',
      minValue: data['minValue'] ?? 0,
      duration: data['duration'] ?? 0,
      startDate: start,
      endDate: end,
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? 'Unknown',
      participants: participantsList,
      status: status,
      invitedUsers: data['invitedUsers'] != null
          ? List<String>.from(data['invitedUsers'])
          : null,
      isJoined: joined,
    );
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'metric': metric,
      'minValue': minValue,
      'duration': duration,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'creatorId': creatorId,
      'creatorName': creatorName,
      'participants': participants,
      'status': status,
      'invitedUsers': invitedUsers,
    };
  }

  factory Tournament.fromLocalMap(
      Map<String, dynamic> map, String currentUserId) {
    List<String> participantsList =
        List<String>.from(map['participants'] ?? []);
    bool joined = participantsList.contains(currentUserId);

    return Tournament(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'public',
      metric: map['metric'] ?? 'steps',
      minValue: map['minValue'] ?? 0,
      duration: map['duration'] ?? 0,
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      creatorId: map['creatorId'] ?? '',
      creatorName: map['creatorName'] ?? 'Unknown',
      participants: participantsList,
      status: map['status'] ?? 'upcoming',
      invitedUsers: map['invitedUsers'] != null
          ? List<String>.from(map['invitedUsers'])
          : null,
      isJoined: joined,
    );
  }
}

class LeaderboardEntry {
  final String name;
  final String avatar;
  final String? avatarId;
  final int value;
  final int rank;
  final bool isYou;

  LeaderboardEntry({
    required this.name,
    required this.avatar,
    this.avatarId,
    required this.value,
    required this.rank,
    required this.isYou,
  });
}

class Milestone {
  final String title;
  final int target;
  final bool completed;

  Milestone({
    required this.title,
    required this.target,
    required this.completed,
  });
}
