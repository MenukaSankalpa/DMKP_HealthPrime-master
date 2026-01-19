import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/health_record.dart';
import '../../data/models/tournament.dart';

class OfflineService {
  static const String _keyPendingRecords = 'pending_records';
  static const String _keyPendingDeletes = 'pending_deletes';

  static const String _keyPendingTournaments = 'pending_tournaments';
  static const String _keyPendingTournamentDeletes =
      'pending_tournament_deletes';
  static const String _keyPendingTournamentJoins = 'pending_tournament_joins';
  static const String _keyPendingTournamentWithdraws =
      'pending_tournament_withdraws';

  static const String _keyPendingUserUpdates = 'pending_user_updates';

  static const String _keyPendingFriendAccepts = 'pending_friend_accepts';
  static const String _keyPendingFriendRejects = 'pending_friend_rejects';
  static const String _keyPendingFriendRemoves = 'pending_friend_removes';
  static const String _keyPendingInviteCancels = 'pending_invite_cancels';

  // Save Pending Records
  Future<void> savePendingRecord(HealthRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> pendingList = prefs.getStringList(_keyPendingRecords) ?? [];

    Map<String, dynamic> map = record.toMap();
    map['id'] = record.id;

    int index = -1;
    for (int i = 0; i < pendingList.length; i++) {
      final item = HealthRecord.fromMap(jsonDecode(pendingList[i]));
      if (item.id == record.id) {
        index = i;
        break;
      }
    }

    String jsonStr = jsonEncode(map);
    if (index != -1) {
      pendingList[index] = jsonStr;
    } else {
      pendingList.add(jsonStr);
    }

    await prefs.setStringList(_keyPendingRecords, pendingList);
  }

  // Save Pending Record Delete
  Future<void> savePendingDelete(String id) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> pendingRecords = prefs.getStringList(_keyPendingRecords) ?? [];
    pendingRecords.removeWhere((str) {
      final item = HealthRecord.fromMap(jsonDecode(str));
      return item.id == id;
    });
    await prefs.setStringList(_keyPendingRecords, pendingRecords);

    List<String> pendingDeletes = prefs.getStringList(_keyPendingDeletes) ?? [];
    if (!pendingDeletes.contains(id)) {
      pendingDeletes.add(id);
      await prefs.setStringList(_keyPendingDeletes, pendingDeletes);
    }
  }

  // Get Pending Records
  Future<List<HealthRecord>> getPendingRecords() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingRecords) ?? [];
    return list.map((str) => HealthRecord.fromMap(jsonDecode(str))).toList();
  }

  // Get Pending Deletes
  Future<List<String>> getPendingDeletes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPendingDeletes) ?? [];
  }

  // Clear Pending Record
  Future<void> clearPendingRecord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingRecords) ?? [];
    list.removeWhere((str) {
      final item = HealthRecord.fromMap(jsonDecode(str));
      return item.id == id;
    });
    await prefs.setStringList(_keyPendingRecords, list);
  }

  // Clear Pending Delete
  Future<void> clearPendingDelete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingDeletes) ?? [];
    list.remove(id);
    await prefs.setStringList(_keyPendingDeletes, list);
  }

  // Save Pending Tournament
  Future<void> savePendingTournament(Tournament tournament) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingTournaments) ?? [];

    Map<String, dynamic> map = tournament.toLocalMap();

    int index = -1;
    for (int i = 0; i < list.length; i++) {
      final item =
          Tournament.fromLocalMap(jsonDecode(list[i]), tournament.creatorId);
      if (item.id == tournament.id) {
        index = i;
        break;
      }
    }

    String jsonStr = jsonEncode(map);
    if (index != -1) {
      list[index] = jsonStr;
    } else {
      list.add(jsonStr);
    }

    await prefs.setStringList(_keyPendingTournaments, list);
  }

  // Save Pending Tournament Delete
  Future<void> savePendingTournamentDelete(String id) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> pending = prefs.getStringList(_keyPendingTournaments) ?? [];
    pending.removeWhere((str) {
      final map = jsonDecode(str);
      return map['id'] == id;
    });
    await prefs.setStringList(_keyPendingTournaments, pending);

    List<String> deletes =
        prefs.getStringList(_keyPendingTournamentDeletes) ?? [];
    if (!deletes.contains(id)) {
      deletes.add(id);
      await prefs.setStringList(_keyPendingTournamentDeletes, deletes);
    }
  }

  // Get Pending Tournaments
  Future<List<Tournament>> getPendingTournaments(String currentUserId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingTournaments) ?? [];
    return list
        .map((str) => Tournament.fromLocalMap(jsonDecode(str), currentUserId))
        .toList();
  }

  // Get Pending Tournament Deletes
  Future<List<String>> getPendingTournamentDeletes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPendingTournamentDeletes) ?? [];
  }

  // Clear Pending Tournament
  Future<void> clearPendingTournament(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingTournaments) ?? [];
    list.removeWhere((str) {
      final map = jsonDecode(str);
      return map['id'] == id;
    });
    await prefs.setStringList(_keyPendingTournaments, list);
  }

  // Clear Pending Tournament Delete
  Future<void> clearPendingTournamentDelete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingTournamentDeletes) ?? [];
    list.remove(id);
    await prefs.setStringList(_keyPendingTournamentDeletes, list);
  }

  // Save Pending Tournament Join
  Future<void> savePendingTournamentJoin(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> withdraws =
        prefs.getStringList(_keyPendingTournamentWithdraws) ?? [];
    withdraws.remove(id);
    await prefs.setStringList(_keyPendingTournamentWithdraws, withdraws);

    List<String> joins = prefs.getStringList(_keyPendingTournamentJoins) ?? [];
    if (!joins.contains(id)) {
      joins.add(id);
      await prefs.setStringList(_keyPendingTournamentJoins, joins);
    }
  }

  // Save Pending Tournament Withdraw
  Future<void> savePendingTournamentWithdraw(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> joins = prefs.getStringList(_keyPendingTournamentJoins) ?? [];
    joins.remove(id);
    await prefs.setStringList(_keyPendingTournamentJoins, joins);

    List<String> withdraws =
        prefs.getStringList(_keyPendingTournamentWithdraws) ?? [];
    if (!withdraws.contains(id)) {
      withdraws.add(id);
      await prefs.setStringList(_keyPendingTournamentWithdraws, withdraws);
    }
  }

  // Get Pending Tournament Joins
  Future<List<String>> getPendingTournamentJoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPendingTournamentJoins) ?? [];
  }

  // Get Pending Tournament Withdraws
  Future<List<String>> getPendingTournamentWithdraws() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPendingTournamentWithdraws) ?? [];
  }

  // Clear Pending Tournament Join
  Future<void> clearPendingTournamentJoin(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingTournamentJoins) ?? [];
    list.remove(id);
    await prefs.setStringList(_keyPendingTournamentJoins, list);
  }

  // Clear Pending Tournament Withdraw
  Future<void> clearPendingTournamentWithdraw(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list =
        prefs.getStringList(_keyPendingTournamentWithdraws) ?? [];
    list.remove(id);
    await prefs.setStringList(_keyPendingTournamentWithdraws, list);
  }

  // Save Pending User Update
  Future<void> savePendingUserUpdate(Map<String, dynamic> newUpdates) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString(_keyPendingUserUpdates);

    Map<String, dynamic> currentUpdates = {};
    if (jsonStr != null) {
      currentUpdates = jsonDecode(jsonStr);
    }
    currentUpdates.addAll(newUpdates);
    await prefs.setString(_keyPendingUserUpdates, jsonEncode(currentUpdates));
  }

  // Get Pending User Updates
  Future<Map<String, dynamic>> getPendingUserUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString(_keyPendingUserUpdates);
    if (jsonStr == null) return {};
    return jsonDecode(jsonStr);
  }

  // Clear Pending User Updates
  Future<void> clearPendingUserUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPendingUserUpdates);
  }

  // Save Pending Friend Accept
  Future<void> savePendingFriendAccept(Map<String, dynamic> friendData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingFriendAccepts) ?? [];

    list.removeWhere((str) {
      final map = jsonDecode(str);
      return map['uid'] == friendData['uid'];
    });

    list.add(jsonEncode(friendData));
    await prefs.setStringList(_keyPendingFriendAccepts, list);
  }

  // Save Pending Friend Reject
  Future<void> savePendingFriendReject(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingFriendRejects) ?? [];
    if (!list.contains(uid)) {
      list.add(uid);
      await prefs.setStringList(_keyPendingFriendRejects, list);
    }
  }

  // Save Pending Friend Remove
  Future<void> savePendingFriendRemove(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingFriendRemoves) ?? [];
    if (!list.contains(uid)) {
      list.add(uid);
      await prefs.setStringList(_keyPendingFriendRemoves, list);
    }
  }

  // Save Pending Invite Cancel
  Future<void> savePendingInviteCancel(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingInviteCancels) ?? [];
    if (!list.contains(uid)) {
      list.add(uid);
      await prefs.setStringList(_keyPendingInviteCancels, list);
    }
  }

  // Get Pending Friend Accepts
  Future<List<Map<String, dynamic>>> getPendingFriendAccepts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingFriendAccepts) ?? [];
    return list.map((str) => jsonDecode(str) as Map<String, dynamic>).toList();
  }

  // Get Pending Friend Rejects
  Future<List<String>> getPendingFriendRejects() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPendingFriendRejects) ?? [];
  }

  // Get Pending Friend Removes
  Future<List<String>> getPendingFriendRemoves() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPendingFriendRemoves) ?? [];
  }

  // Get Pending Invite Caancels
  Future<List<String>> getPendingInviteCancels() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPendingInviteCancels) ?? [];
  }

  // Clear Pending Friend Accept
  Future<void> clearPendingFriendAccept(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingFriendAccepts) ?? [];
    list.removeWhere(
        (str) => (jsonDecode(str) as Map<String, dynamic>)['uid'] == uid);
    await prefs.setStringList(_keyPendingFriendAccepts, list);
  }

  // Clear Pending Friend Reject
  Future<void> clearPendingFriendReject(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingFriendRejects) ?? [];
    list.remove(uid);
    await prefs.setStringList(_keyPendingFriendRejects, list);
  }

  // Clear Pending Friend Remove
  Future<void> clearPendingFriendRemove(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingFriendRemoves) ?? [];
    list.remove(uid);
    await prefs.setStringList(_keyPendingFriendRemoves, list);
  }

  // Clear Pending Invite Cancel
  Future<void> clearPendingInviteCancel(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_keyPendingInviteCancels) ?? [];
    list.remove(uid);
    await prefs.setStringList(_keyPendingInviteCancels, list);
  }
}
