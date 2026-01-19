import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/models/tournament.dart';
import '../../data/models/health_record.dart';
import '../services/offline_service.dart';

class TournamentProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final OfflineService _offlineService = OfflineService();
  User? _user;

  List<Tournament> _firestoreTournaments = [];
  List<Tournament> _pendingTournaments = [];
  List<String> _pendingDeletes = [];

  List<String> _pendingJoins = [];
  List<String> _pendingWithdraws = [];

  List<Tournament> _activeTournaments = [];
  List<Tournament> _availableTournaments = [];
  List<Tournament> _pastTournaments = [];

  List<Tournament> get activeTournaments => _activeTournaments;
  List<Tournament> get availableTournaments => _availableTournaments;
  List<Tournament> get pastTournaments => _pastTournaments;

  StreamSubscription? _firestoreSub;
  StreamSubscription? _connectivitySub;
  bool _isOnline = true;

  TournamentProvider() {
    _initConnectivity();
  }

  void _initConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      bool isConnected = results.any((r) => r != ConnectivityResult.none);
      if (isConnected && !_isOnline) {
        _isOnline = true;
        _syncPendingData();
      } else if (!isConnected) {
        _isOnline = false;
      }
      notifyListeners();
    });
  }

  void updateUser(User? user) {
    _user = user;
    if (_user != null) {
      _loadLocalData();
      _listenToTournaments();
    } else {
      _cleanup();
    }
  }

  // Cleanup
  void _cleanup() {
    _firestoreTournaments = [];
    _pendingTournaments = [];
    _pendingDeletes = [];
    _pendingJoins = [];
    _pendingWithdraws = [];
    _updateCombinedLists();
    notifyListeners();
  }

  // Load Local Data
  Future<void> _loadLocalData() async {
    if (_user == null) return;
    _pendingTournaments =
        await _offlineService.getPendingTournaments(_user!.uid);
    _pendingDeletes = await _offlineService.getPendingTournamentDeletes();
    _pendingJoins = await _offlineService.getPendingTournamentJoins();
    _pendingWithdraws = await _offlineService.getPendingTournamentWithdraws();
    _updateCombinedLists();
  }

  void _listenToTournaments() {
    _firestoreSub =
        _db.collection('tournaments').snapshots().listen((snapshot) {
      _firestoreTournaments = snapshot.docs
          .map((doc) => Tournament.fromFirestore(doc, _user!.uid))
          .toList();
      _updateCombinedLists();
    });
  }

  // Update Combined List
  void _updateCombinedLists() {
    if (_user == null) return;

    Map<String, Tournament> combinedMap = {
      for (var t in _firestoreTournaments) t.id: t
    };

    for (var id in _pendingDeletes) {
      combinedMap.remove(id);
    }

    for (var t in _pendingTournaments) {
      combinedMap[t.id] = t;
    }

    for (var id in _pendingJoins) {
      if (combinedMap.containsKey(id)) {
        var t = combinedMap[id]!;
        List<String> newParticipants = List.from(t.participants);
        if (!newParticipants.contains(_user!.uid)) {
          newParticipants.add(_user!.uid);
        }

        combinedMap[id] = Tournament(
          id: t.id,
          name: t.name,
          description: t.description,
          type: t.type,
          metric: t.metric,
          minValue: t.minValue,
          duration: t.duration,
          startDate: t.startDate,
          endDate: t.endDate,
          creatorId: t.creatorId,
          creatorName: t.creatorName,
          participants: newParticipants,
          status: t.status,
          invitedUsers: t.invitedUsers,
          isJoined: true,
          userProgress: t.userProgress,
          leaderboard: t.leaderboard,
          milestones: t.milestones,
        );
      }
    }

    for (var id in _pendingWithdraws) {
      if (combinedMap.containsKey(id)) {
        var t = combinedMap[id]!;
        List<String> newParticipants = List.from(t.participants);
        newParticipants.remove(_user!.uid);

        combinedMap[id] = Tournament(
          id: t.id,
          name: t.name,
          description: t.description,
          type: t.type,
          metric: t.metric,
          minValue: t.minValue,
          duration: t.duration,
          startDate: t.startDate,
          endDate: t.endDate,
          creatorId: t.creatorId,
          creatorName: t.creatorName,
          participants: newParticipants,
          status: t.status,
          invitedUsers: t.invitedUsers,
          isJoined: false,
          userProgress: t.userProgress,
          leaderboard: t.leaderboard,
          milestones: t.milestones,
        );
      }
    }

    _activeTournaments = [];
    _availableTournaments = [];
    _pastTournaments = [];

    final allTournaments = combinedMap.values.toList();

    for (var t in allTournaments) {
      if (t.status == 'ended') {
        if (t.isJoined || t.creatorId == _user!.uid) _pastTournaments.add(t);
      } else if (t.isJoined) {
        _activeTournaments.add(t);
      } else {
        if (t.type == 'public') {
          _availableTournaments.add(t);
        } else if (t.type == 'friends') {
          _availableTournaments.add(t);
        } else if (t.type == 'private') {
          if (t.invitedUsers != null && t.invitedUsers!.contains(_user!.uid)) {
            _availableTournaments.add(t);
          }
        }
      }
    }
    notifyListeners();
  }

  // Create Tournament
  Future<void> createTournament({
    required String name,
    required String description,
    required String type,
    required String metric,
    required int minValue,
    required int duration,
    required DateTime startDate,
    required List<String> invitedUserIds,
  }) async {
    if (_user == null) return;

    DateTime endDate = startDate.add(Duration(days: duration));
    String status = DateTime.now().isAfter(startDate) ? 'active' : 'upcoming';
    List<String> participants = [_user!.uid];

    final tData = {
      'name': name,
      'description': description,
      'type': type,
      'metric': metric,
      'minValue': minValue,
      'duration': duration,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'creatorId': _user!.uid,
      'creatorName': _user!.displayName ?? 'Unknown',
      'participants': participants,
      'status': status,
      'invitedUsers': type == 'private' ? invitedUserIds : [],
    };

    final connectivity = await Connectivity().checkConnectivity();
    bool isConnected = connectivity.any((r) => r != ConnectivityResult.none);

    if (isConnected) {
      await _db.collection('tournaments').add(tData);
    } else {
      String tempId = 'temp_tourney_${DateTime.now().millisecondsSinceEpoch}';

      final newT = Tournament(
        id: tempId,
        name: name,
        description: description,
        type: type,
        metric: metric,
        minValue: minValue,
        duration: duration,
        startDate: startDate,
        endDate: endDate,
        creatorId: _user!.uid,
        creatorName: _user!.displayName ?? 'Unknown',
        participants: participants,
        status: status,
        invitedUsers: type == 'private' ? invitedUserIds : [],
        isJoined: true,
      );

      await _offlineService.savePendingTournament(newT);
      _pendingTournaments.add(newT);
      _updateCombinedLists();
    }
  }

  // Update Tournament
  Future<void> updateTournament({
    required String tournamentId,
    required String name,
    required String description,
    required String type,
    required String metric,
    required int minValue,
    required int duration,
    required DateTime startDate,
    required List<String> invitedUserIds,
  }) async {
    if (_user == null) return;

    Tournament current = _activeTournaments.firstWhere(
        (t) => t.id == tournamentId,
        orElse: () => _availableTournaments.firstWhere(
            (t) => t.id == tournamentId,
            orElse: () =>
                _pastTournaments.firstWhere((t) => t.id == tournamentId)));

    if (current.creatorId != _user!.uid)
      throw "Only the creator can edit this tournament";

    List<String> currentParticipants = List.from(current.participants);
    List<String> updatedParticipants = List.from(currentParticipants);
    List<String> finalInvitedUsers = type == 'private' ? invitedUserIds : [];

    final connectivity = await Connectivity().checkConnectivity();
    bool isConnected = connectivity.any((r) => r != ConnectivityResult.none);

    if (isConnected && type == 'friends') {
      var friendsSnap = await _db
          .collection('users')
          .doc(_user!.uid)
          .collection('friends')
          .get();
      List<String> friendIds = friendsSnap.docs.map((d) => d.id).toList();
      updatedParticipants
          .removeWhere((uid) => uid != _user!.uid && !friendIds.contains(uid));
    } else if (type == 'private') {
      updatedParticipants.removeWhere(
          (uid) => uid != _user!.uid && !invitedUserIds.contains(uid));
    }

    DateTime endDate = startDate.add(Duration(days: duration));
    String status = DateTime.now().isAfter(startDate) ? 'active' : 'upcoming';

    final updateData = {
      'name': name,
      'description': description,
      'type': type,
      'metric': metric,
      'minValue': minValue,
      'duration': duration,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'participants': updatedParticipants,
      'status': status,
      'invitedUsers': finalInvitedUsers,
    };

    if (isConnected) {
      if (tournamentId.startsWith('temp_')) {
        await _offlineService.savePendingTournament(current);
      } else {
        await _db
            .collection('tournaments')
            .doc(tournamentId)
            .update(updateData);
      }
    } else {
      final updatedT = Tournament(
        id: tournamentId,
        name: name,
        description: description,
        type: type,
        metric: metric,
        minValue: minValue,
        duration: duration,
        startDate: startDate,
        endDate: endDate,
        creatorId: current.creatorId,
        creatorName: current.creatorName,
        participants: updatedParticipants,
        status: status,
        invitedUsers: finalInvitedUsers,
        isJoined: current.isJoined,
      );

      await _offlineService.savePendingTournament(updatedT);
      _pendingTournaments.removeWhere((t) => t.id == tournamentId);
      _pendingTournaments.add(updatedT);
      _updateCombinedLists();
    }
  }

  // Delete Tournament
  Future<void> deleteTournament(String tournamentId) async {
    if (_user == null) return;

    final connectivity = await Connectivity().checkConnectivity();
    bool isConnected = connectivity.any((r) => r != ConnectivityResult.none);

    if (isConnected) {
      if (tournamentId.startsWith('temp_')) {
        await _offlineService.clearPendingTournament(tournamentId);
        _pendingTournaments.removeWhere((t) => t.id == tournamentId);
      } else {
        await _db.collection('tournaments').doc(tournamentId).delete();
      }
    } else {
      if (tournamentId.startsWith('temp_')) {
        await _offlineService.clearPendingTournament(tournamentId);
        _pendingTournaments.removeWhere((t) => t.id == tournamentId);
      } else {
        await _offlineService.savePendingTournamentDelete(tournamentId);
        _pendingDeletes.add(tournamentId);
      }
      _updateCombinedLists();
    }
  }

  // Join Tournament
  Future<void> joinTournament(String tournamentId) async {
    if (_user == null) return;

    final connectivity = await Connectivity().checkConnectivity();
    bool isConnected = connectivity.any((r) => r != ConnectivityResult.none);

    if (isConnected) {
      await _db.collection('tournaments').doc(tournamentId).update({
        'participants': FieldValue.arrayUnion([_user!.uid])
      });
    } else {
      await _offlineService.savePendingTournamentJoin(tournamentId);
      _pendingWithdraws.remove(tournamentId);
      if (!_pendingJoins.contains(tournamentId)) {
        _pendingJoins.add(tournamentId);
      }
      _updateCombinedLists();
    }
  }

  // Withdraw From Tournament
  Future<void> withdrawTournament(String tournamentId) async {
    if (_user == null) return;

    final connectivity = await Connectivity().checkConnectivity();
    bool isConnected = connectivity.any((r) => r != ConnectivityResult.none);

    if (isConnected) {
      await _db.collection('tournaments').doc(tournamentId).update({
        'participants': FieldValue.arrayRemove([_user!.uid])
      });
    } else {
      await _offlineService.savePendingTournamentWithdraw(tournamentId);
      _pendingJoins.remove(tournamentId);
      if (!_pendingWithdraws.contains(tournamentId)) {
        _pendingWithdraws.add(tournamentId);
      }
      _updateCombinedLists();
    }
  }

  // Sync Pending Data
  Future<void> _syncPendingData() async {
    if (_user == null) return;
    print("Syncing Tournaments...");

    for (String id in List.from(_pendingDeletes)) {
      try {
        await _db.collection('tournaments').doc(id).delete();
        await _offlineService.clearPendingTournamentDelete(id);
        _pendingDeletes.remove(id);
      } catch (e) {
        print("Sync delete tourney failed: $e");
      }
    }

    for (Tournament t in List.from(_pendingTournaments)) {
      try {
        final data = t.toMap();
        if (t.id.startsWith('temp_')) {
          await _db.collection('tournaments').add(data);
        } else {
          await _db.collection('tournaments').doc(t.id).update(data);
        }
        await _offlineService.clearPendingTournament(t.id);
        _pendingTournaments.remove(t);
      } catch (e) {
        print("Sync tourney update failed: $e");
      }
    }

    for (String id in List.from(_pendingJoins)) {
      try {
        await _db.collection('tournaments').doc(id).update({
          'participants': FieldValue.arrayUnion([_user!.uid])
        });
        await _offlineService.clearPendingTournamentJoin(id);
        _pendingJoins.remove(id);
      } catch (e) {
        print("Sync join failed: $e");
      }
    }

    for (String id in List.from(_pendingWithdraws)) {
      try {
        await _db.collection('tournaments').doc(id).update({
          'participants': FieldValue.arrayRemove([_user!.uid])
        });
        await _offlineService.clearPendingTournamentWithdraw(id);
        _pendingWithdraws.remove(id);
      } catch (e) {
        print("Sync withdraw failed: $e");
      }
    }

    _updateCombinedLists();
  }

  // Get Tournament Details
  Future<Map<String, dynamic>> getTournamentDetails(Tournament t) async {
    List<LeaderboardEntry> leaderboard = [];
    int myProgress = 0;

    for (String uid in t.participants.take(20)) {
      try {
        var userDoc = await _db.collection('users').doc(uid).get();
        if (!userDoc.exists) continue;

        var userData = userDoc.data();
        String name = userData?['name'] ?? 'Unknown';
        String avatar = userData?['avatarInitial'] ?? 'U';
        String? avatarId = userData?['avatarId'];

        int score =
            await _calculateUserScore(uid, t.metric, t.startDate, t.endDate);
        if (uid == _user!.uid) myProgress = score;

        leaderboard.add(LeaderboardEntry(
          name: uid == _user!.uid ? "You" : name,
          avatar: avatar,
          avatarId: avatarId,
          value: score,
          rank: 0,
          isYou: uid == _user!.uid,
        ));
      } catch (e) {
        continue;
      }
    }

    leaderboard.sort((a, b) => b.value.compareTo(a.value));
    for (int i = 0; i < leaderboard.length; i++) {
      var old = leaderboard[i];
      leaderboard[i] = LeaderboardEntry(
          name: old.name,
          avatar: old.avatar,
          avatarId: old.avatarId,
          value: old.value,
          rank: i + 1,
          isYou: old.isYou);
    }

    List<Milestone> milestones = [
      Milestone(
          title: '25% Goal',
          target: (t.minValue * 0.25).round(),
          completed: myProgress >= t.minValue * 0.25),
      Milestone(
          title: '50% Goal',
          target: (t.minValue * 0.5).round(),
          completed: myProgress >= t.minValue * 0.5),
      Milestone(
          title: '75% Goal',
          target: (t.minValue * 0.75).round(),
          completed: myProgress >= t.minValue * 0.75),
      Milestone(
          title: 'Goal Reached',
          target: t.minValue,
          completed: myProgress >= t.minValue),
    ];

    int userRank = 0;
    try {
      userRank = leaderboard.firstWhere((e) => e.isYou).rank;
    } catch (e) {
      userRank = 0;
    }

    return {
      'leaderboard': leaderboard,
      'milestones': milestones,
      'userProgress': myProgress,
      'userRank': userRank,
    };
  }

  // Calculate User Score
  Future<int> _calculateUserScore(
      String uid, String metric, DateTime start, DateTime end) async {
    var query = await _db
        .collection('users')
        .doc(uid)
        .collection('records')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .get();

    double total = 0;
    for (var doc in query.docs) {
      var record = HealthRecord.fromFirestore(doc);
      switch (metric.toLowerCase()) {
        case 'steps':
          total += record.steps;
          break;
        case 'calories':
          total += record.calories;
          break;
        case 'water':
          total += record.water;
          break;
        case 'sleep':
          total += record.sleep;
          break;
        case 'workout':
          total += record.workout ?? 0;
          break;
      }
    }
    return total.round();
  }

  Future<int> getPastTournamentRank(String tournamentId) async {
    if (_user == null) return 0;

    try {
      final t = _pastTournaments.firstWhere((element) => element.id == tournamentId);

      final details = await getTournamentDetails(t);
      return details['userRank'] ?? 0;
    } catch (e) {
      debugPrint("Error fetching rank for past tournament: $e");
      return 0;
    }
  }

  @override
  void dispose() {
    _firestoreSub?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}
