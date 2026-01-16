import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/models/health_record.dart';
import '../services/offline_service.dart';

class FriendsProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final OfflineService _offlineService = OfflineService();
  User? _user;

  List<Map<String, dynamic>> _firestoreFriends = [];
  List<Map<String, dynamic>> _firestoreRequests = [];
  List<Map<String, dynamic>> _firestoreSent = [];

  List<Map<String, dynamic>> _pendingAccepts = [];
  List<String> _pendingRejects = [];
  List<String> _pendingRemoves = [];
  List<String> _pendingInviteCancels = [];

  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _pendingSent = [];

  StreamSubscription? _friendsSub;
  StreamSubscription? _requestsSub;
  StreamSubscription? _sentSub;
  StreamSubscription? _connectivitySub;
  bool _isOnline = true;

  List<Map<String, dynamic>> get friends => _friends;
  List<Map<String, dynamic>> get requests => _requests;
  List<Map<String, dynamic>> get pendingSent => _pendingSent;
  bool get isOnline => _isOnline;

  FriendsProvider() {
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
    if (_user?.uid == user?.uid) return;
    _user = user;
    _cancelSubscriptions();

    if (_user != null) {
      _loadLocalData();
      _listenToCollections();
    } else {
      _firestoreFriends = [];
      _firestoreRequests = [];
      _firestoreSent = [];
      _pendingAccepts = [];
      _pendingRejects = [];
      _pendingRemoves = [];
      _pendingInviteCancels = [];
      _updateCombinedLists();
    }
  }

  // Load Local Data
  Future<void> _loadLocalData() async {
    if (_user == null) return;
    _pendingAccepts = await _offlineService.getPendingFriendAccepts();
    _pendingRejects = await _offlineService.getPendingFriendRejects();
    _pendingRemoves = await _offlineService.getPendingFriendRemoves();
    _pendingInviteCancels =
        await _offlineService.getPendingInviteCancels();
    _updateCombinedLists();
  }

  void _cancelSubscriptions() {
    _friendsSub?.cancel();
    _requestsSub?.cancel();
    _sentSub?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    _connectivitySub?.cancel();
    super.dispose();
  }

  void _listenToCollections() {
    if (_user == null) return;

    _friendsSub = _db
        .collection('users')
        .doc(_user!.uid)
        .collection('friends')
        .snapshots()
        .listen((snapshot) {
      _firestoreFriends = snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
      _updateCombinedLists();
    }, onError: (e) => print("Error fetching friends: $e"));

    _requestsSub = _db
        .collection('users')
        .doc(_user!.uid)
        .collection('friend_requests')
        .snapshots()
        .listen((snapshot) {
      _firestoreRequests = snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
      _updateCombinedLists();
    }, onError: (e) => print("Error fetching requests: $e"));

    _sentSub = _db
        .collection('users')
        .doc(_user!.uid)
        .collection('sent_requests')
        .snapshots()
        .listen((snapshot) {
      _firestoreSent = snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
      _updateCombinedLists();
    }, onError: (e) => print("Error fetching sent requests: $e"));
  }

  // Update Combined Lists
  void _updateCombinedLists() {
    Map<String, Map<String, dynamic>> friendsMap = {
      for (var f in _firestoreFriends) f['uid']: f
    };
    for (var uid in _pendingRemoves) friendsMap.remove(uid);
    for (var f in _pendingAccepts) friendsMap[f['uid']] = f;
    _friends = friendsMap.values.toList();

    Map<String, Map<String, dynamic>> requestsMap = {
      for (var r in _firestoreRequests) r['uid']: r
    };
    for (var f in _pendingAccepts) requestsMap.remove(f['uid']);
    for (var uid in _pendingRejects) requestsMap.remove(uid);
    _requests = requestsMap.values.toList();

    _pendingSent = _firestoreSent
        .where((req) => !_pendingInviteCancels.contains(req['uid']))
        .toList();

    notifyListeners();
  }

  // Send Friend Requests
  Future<void> sendFriendRequest(String emailInput) async {
    if (_user == null) return;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      throw "You are offline. Cannot send friend requests.";
    }

    final email = emailInput.trim().toLowerCase();
    final myEmail = _user!.email?.toLowerCase();

    if (email == myEmail) throw "You cannot add yourself as a friend.";

    final query =
        await _db.collection('users').where('email', isEqualTo: email).get();
    if (query.docs.isEmpty) throw "User not registered.";

    final targetUser = query.docs.first;
    final targetUid = targetUser['uid'];
    if (targetUid == _user!.uid) throw "You cannot add yourself.";

    final targetName = targetUser['name'];
    final targetAvatar = targetUser['avatarInitial'];
    final targetAvatarId = targetUser.data()['avatarId'];

    final friendCheck = await _db
        .collection('users')
        .doc(_user!.uid)
        .collection('friends')
        .doc(targetUid)
        .get();
    if (friendCheck.exists) throw "You are already friends with $targetName.";

    final sentCheck = await _db
        .collection('users')
        .doc(_user!.uid)
        .collection('sent_requests')
        .doc(targetUid)
        .get();
    if (sentCheck.exists) throw "Invite already sent to $targetName.";

    final receivedCheck = await _db
        .collection('users')
        .doc(_user!.uid)
        .collection('friend_requests')
        .doc(targetUid)
        .get();
    if (receivedCheck.exists)
      throw "This user has already sent you a request. Check 'Friend Requests'.";

    final myProfile = await _db.collection('users').doc(_user!.uid).get();
    final myName = myProfile.data()?['name'] ?? _user!.displayName ?? 'Unknown';
    final myAvatar = myProfile.data()?['avatarInitial'] ?? 'U';
    final myAvatarId = myProfile.data()?['avatarId'];

    final myData = {
      'uid': _user!.uid,
      'name': myName,
      'email': myEmail,
      'avatarInitial': myAvatar,
      'avatarId': myAvatarId,
      'date': DateTime.now().toIso8601String(),
    };

    final targetData = {
      'uid': targetUid,
      'name': targetName,
      'email': email,
      'avatarInitial': targetAvatar,
      'avatarId': targetAvatarId,
      'date': DateTime.now().toIso8601String(),
    };

    final batch = _db.batch();
    batch.set(
        _db
            .collection('users')
            .doc(_user!.uid)
            .collection('sent_requests')
            .doc(targetUid),
        targetData);
    batch.set(
        _db
            .collection('users')
            .doc(targetUid)
            .collection('friend_requests')
            .doc(_user!.uid),
        myData);
    await batch.commit();
  }

  // Accept Friend Requests
  Future<void> acceptFriendRequest(String friendUid, String friendName,
      String friendEmail, String friendAvatar,
      {String? friendAvatarId}) async {
    final now = DateTime.now().toIso8601String();

    final friendDataForMe = {
      'uid': friendUid,
      'name': friendName,
      'email': friendEmail,
      'avatarInitial': friendAvatar,
      'avatarId': friendAvatarId,
      'status': 'Active',
      'since': now,
    };

    final connectivity = await Connectivity().checkConnectivity();
    bool isConnected = connectivity.any((r) => r != ConnectivityResult.none);

    if (isConnected) {
      final batch = _db.batch();
      final myProfile = await _db.collection('users').doc(_user!.uid).get();
      final myName = myProfile.data()?['name'] ?? _user!.displayName ?? 'User';
      final myAvatar = myProfile.data()?['avatarInitial'] ?? 'U';
      final myAvatarId = myProfile.data()?['avatarId'];

      String? resolvedFriendAvatarId = friendAvatarId;
      if (resolvedFriendAvatarId == null) {
        final userDoc = await _db.collection('users').doc(friendUid).get();
        if (userDoc.exists)
          resolvedFriendAvatarId = userDoc.data()?['avatarId'];
      }
      friendDataForMe['avatarId'] = resolvedFriendAvatarId;

      final myDataForFriend = {
        'uid': _user!.uid,
        'name': myName,
        'email': _user!.email,
        'avatarInitial': myAvatar,
        'avatarId': myAvatarId,
        'status': 'Active',
        'since': now,
      };

      batch.set(
          _db
              .collection('users')
              .doc(_user!.uid)
              .collection('friends')
              .doc(friendUid),
          friendDataForMe);
      batch.set(
          _db
              .collection('users')
              .doc(friendUid)
              .collection('friends')
              .doc(_user!.uid),
          myDataForFriend);

      batch.delete(_db
          .collection('users')
          .doc(_user!.uid)
          .collection('friend_requests')
          .doc(friendUid));
      batch.delete(_db
          .collection('users')
          .doc(_user!.uid)
          .collection('sent_requests')
          .doc(friendUid));
      batch.delete(_db
          .collection('users')
          .doc(friendUid)
          .collection('sent_requests')
          .doc(_user!.uid));
      batch.delete(_db
          .collection('users')
          .doc(friendUid)
          .collection('friend_requests')
          .doc(_user!.uid));

      await batch.commit();
    } else {
      await _offlineService.savePendingFriendAccept(friendDataForMe);
      _pendingAccepts.removeWhere((f) => f['uid'] == friendUid);
      _pendingAccepts.add(friendDataForMe);
      _pendingRejects.remove(friendUid);
      _updateCombinedLists();
    }
  }

  // Reject Friend Request
  Future<void> rejectFriendRequest(String friendUid) async {
    final connectivity = await Connectivity().checkConnectivity();
    bool isConnected = connectivity.any((r) => r != ConnectivityResult.none);

    if (isConnected) {
      final batch = _db.batch();
      batch.delete(_db
          .collection('users')
          .doc(_user!.uid)
          .collection('friend_requests')
          .doc(friendUid));
      batch.delete(_db
          .collection('users')
          .doc(friendUid)
          .collection('sent_requests')
          .doc(_user!.uid));
      await batch.commit();
    } else {
      await _offlineService.savePendingFriendReject(friendUid);
      if (!_pendingRejects.contains(friendUid)) _pendingRejects.add(friendUid);
      _pendingAccepts.removeWhere((f) => f['uid'] == friendUid);
      _updateCombinedLists();
    }
  }

  // Remove Friend
  Future<void> removeFriend(String friendUid) async {
    final connectivity = await Connectivity().checkConnectivity();
    bool isConnected = connectivity.any((r) => r != ConnectivityResult.none);

    if (isConnected) {
      final batch = _db.batch();
      batch.delete(_db
          .collection('users')
          .doc(_user!.uid)
          .collection('friends')
          .doc(friendUid));
      batch.delete(_db
          .collection('users')
          .doc(friendUid)
          .collection('friends')
          .doc(_user!.uid));
      await batch.commit();
    } else {
      await _offlineService.savePendingFriendRemove(friendUid);
      if (!_pendingRemoves.contains(friendUid)) _pendingRemoves.add(friendUid);
      _updateCombinedLists();
    }
  }

  // Cancel Invite
  Future<void> cancelInvite(String targetUid) async {
    final connectivity = await Connectivity().checkConnectivity();
    bool isConnected = connectivity.any((r) => r != ConnectivityResult.none);

    if (isConnected) {
      final batch = _db.batch();
      batch.delete(_db
          .collection('users')
          .doc(_user!.uid)
          .collection('sent_requests')
          .doc(targetUid));
      batch.delete(_db
          .collection('users')
          .doc(targetUid)
          .collection('friend_requests')
          .doc(_user!.uid));
      await batch.commit();
    } else {
      await _offlineService.savePendingInviteCancel(targetUid);
      if (!_pendingInviteCancels.contains(targetUid)) {
        _pendingInviteCancels.add(targetUid);
      }
      _updateCombinedLists();
    }
  }

  // Get Friend Profile
  Future<Map<String, dynamic>?> getFriendProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  // Get Friend Stats
  Future<Map<String, dynamic>> getFriendStats(String friendUid) async {
    try {
      final query = await _db
          .collection('users')
          .doc(friendUid)
          .collection('records')
          .get();
      final records =
          query.docs.map((doc) => HealthRecord.fromFirestore(doc)).toList();

      if (records.isEmpty) return _emptyStats();

      double totalSteps = 0, totalCalories = 0, totalWater = 0, totalSleep = 0;
      double totalHeart = 0,
          totalWeight = 0,
          totalFruits = 0,
          totalWorkout = 0,
          totalMood = 0;

      for (var r in records) {
        totalSteps += r.steps;
        totalCalories += r.calories;
        totalWater += r.water;
        totalSleep += r.sleep;
        totalHeart += r.heartRate;
        totalWeight += r.weight ?? 0;
        totalFruits += r.fruits ?? 0;
        totalWorkout += r.workout ?? 0;
        totalMood += r.mood;
      }

      int count = records.length;
      return {
        'steps': (totalSteps / count).round(),
        'calories': (totalCalories / count).round(),
        'water': (totalWater / count).round(),
        'sleep': double.parse((totalSleep / count).toStringAsFixed(1)),
        'heartRate': (totalHeart / count).round(),
        'weight': double.parse((totalWeight / count).toStringAsFixed(1)),
        'fruits': (totalFruits / count).round(),
        'workout': (totalWorkout / count).round(),
        'mood': (totalMood / count).round(),
      };
    } catch (e) {
      return _emptyStats();
    }
  }

  // Empty Stats
  Map<String, dynamic> _emptyStats() {
    return {
      'steps': 0,
      'calories': 0,
      'water': 0,
      'sleep': 0.0,
      'heartRate': 0,
      'weight': 0.0,
      'fruits': 0,
      'workout': 0,
      'mood': 0
    };
  }

  // Sync Pending Data
  Future<void> _syncPendingData() async {
    if (_user == null) return;
    print("Syncing Friends...");

    for (var f in List<Map<String, dynamic>>.from(_pendingAccepts)) {
      try {
        await acceptFriendRequest(
            f['uid'], f['name'], f['email'], f['avatarInitial'],
            friendAvatarId: f['avatarId']);
        await _offlineService.clearPendingFriendAccept(f['uid']);
        _pendingAccepts.removeWhere((item) => item['uid'] == f['uid']);
      } catch (e) {
        print("Sync accept failed: $e");
      }
    }

    for (var uid in List<String>.from(_pendingRejects)) {
      try {
        await rejectFriendRequest(uid);
        await _offlineService.clearPendingFriendReject(uid);
        _pendingRejects.remove(uid);
      } catch (e) {
        print("Sync reject failed: $e");
      }
    }

    for (var uid in List<String>.from(_pendingRemoves)) {
      try {
        await removeFriend(uid);
        await _offlineService.clearPendingFriendRemove(uid);
        _pendingRemoves.remove(uid);
      } catch (e) {
        print("Sync remove failed: $e");
      }
    }

    for (var uid in List<String>.from(_pendingInviteCancels)) {
      try {
        final batch = _db.batch();
        batch.delete(_db
            .collection('users')
            .doc(_user!.uid)
            .collection('sent_requests')
            .doc(uid));
        batch.delete(_db
            .collection('users')
            .doc(uid)
            .collection('friend_requests')
            .doc(_user!.uid));
        await batch.commit();

        await _offlineService.clearPendingInviteCancel(uid);
        _pendingInviteCancels.remove(uid);
      } catch (e) {
        print("Sync cancel invite failed: $e");
      }
    }

    _updateCombinedLists();
  }
}
