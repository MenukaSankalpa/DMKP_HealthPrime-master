import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/offline_service.dart';
import '../services/presence_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final OfflineService _offlineService = OfflineService();
  final PresenceService _presenceService = PresenceService();

  User? _user;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _healthGoals;
  Map<String, dynamic>? _notificationSettings;
  bool _isSigningUp = false;

  StreamSubscription? _connectivitySub;
  bool _isOnline = true;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  Map<String, dynamic>? get healthGoals => _healthGoals;

  Map<String, bool> get notificationSettings {
    if (_notificationSettings == null) {
      return {
        'friendRequests': true,
        'tournamentUpdates': true,
        'publicTournaments': true,
        'tournamentReminders': true,
      };
    }
    return Map<String, bool>.from(_notificationSettings!);
  }

  bool get isAuth => _user != null && !_isSigningUp;

  AuthProvider() {
    _initConnectivity();
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _listenToUserData();
        _presenceService.configureUserPresence();
      } else {
        _userData = null;
        _healthGoals = null;
        _notificationSettings = null;
      }
      notifyListeners();
    });
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

  // Check Network Connectivity
  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _isOnline = results.any((r) => r != ConnectivityResult.none);
  }

  void _listenToUserData() {
    if (_user == null) return;

    _loadLocalPendingData();

    _db.collection('users').doc(_user!.uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        _mergeWithPendingData(data);
      }
    });
  }

  // Load Local Data
  Future<void> _loadLocalPendingData() async {
    final pending = await _offlineService.getPendingUserUpdates();
    if (_userData != null && pending.isNotEmpty) {
      final merged = Map<String, dynamic>.from(_userData!);
      merged.addAll(pending);
      _updateLocalState(merged);
    }
  }

  // Merge Local Data with Firestore Data
  Future<void> _mergeWithPendingData(Map<String, dynamic> firestoreData) async {
    final pending = await _offlineService.getPendingUserUpdates();

    Map<String, dynamic> merged = Map<String, dynamic>.from(firestoreData);
    if (pending.isNotEmpty) {
      merged.addAll(pending);
    }

    _updateLocalState(merged);
  }

  // Update Local State
  void _updateLocalState(Map<String, dynamic> data) {
    _userData = data;
    _healthGoals = _userData?['goals'];
    _notificationSettings = _userData?['notificationSettings'];
    notifyListeners();
  }

  // Sync Pending Data
  Future<void> _syncPendingData() async {
    if (_user == null) return;

    final pending = await _offlineService.getPendingUserUpdates();
    if (pending.isNotEmpty) {
      try {
        await _db.collection('users').doc(_user!.uid).update(pending);
        await _offlineService.clearPendingUserUpdates();
        print("User profile synced successfully");
      } catch (e) {
        print("Failed to sync profile: $e");
      }
    }
  }

  // User Login
  Future<void> login(String email, String password) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    if (!cred.user!.emailVerified) {
      await _auth.signOut();
      throw 'Email not verified. Please check your inbox.';
    }

    _presenceService.configureUserPresence();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // User Registration
  Future<void> register(String email, String password, String name) async {
    _isSigningUp = true;
    notifyListeners();
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (cred.user != null) {
        await cred.user!.updateDisplayName(name);
        await cred.user!.reload();

        Map<String, dynamic> defaultGoals = {
          'steps': 10000,
          'calories': 500,
          'water': 2000,
          'sleep': 8.0,
          'heartRate': 70,
          'weight': 70.0,
          'fruits': 5,
          'workout': 60,
          'mood': 10,
        };
        Map<String, bool> defaultNotifications = {
          'friendRequests': true,
          'tournamentUpdates': true,
          'publicTournaments': true,
          'tournamentReminders': true,
        };

        await _db.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'name': name,
          'email': email,
          'avatarInitial': name.isNotEmpty ? name[0].toUpperCase() : 'U',
          'avatarId': null,
          'createdAt': FieldValue.serverTimestamp(),
          'goals': defaultGoals,
          'notificationSettings': defaultNotifications,
        });

        await cred.user!.sendEmailVerification();
        final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        await _auth.signOut();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isSigningUp = false;
      notifyListeners();
    }
  }

  // Google Login
  Future<void> googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      UserCredential cred = await _auth.signInWithCredential(credential);

      _presenceService.configureUserPresence();

      if (cred.additionalUserInfo?.isNewUser ?? false) {
        Map<String, dynamic> defaultGoals = {
          'steps': 10000,
          'calories': 500,
          'water': 2000,
          'sleep': 8.0,
          'heartRate': 70,
          'weight': 70.0,
          'fruits': 5,
          'workout': 60,
          'mood': 10,
        };
        Map<String, bool> defaultNotifications = {
          'friendRequests': true,
          'tournamentUpdates': true,
          'publicTournaments': true,
          'tournamentReminders': true,
        };

        await _db.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'name': googleUser.displayName ?? 'User',
          'email': googleUser.email,
          'avatarInitial': (googleUser.displayName ?? 'U')[0].toUpperCase(),
          'avatarId': null,
          'createdAt': FieldValue.serverTimestamp(),
          'goals': defaultGoals,
          'notificationSettings': defaultNotifications,
        });
      }
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      throw 'Google Sign-In failed: $e';
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Logout
  Future<void> logout() async {
    await _presenceService.setOffline();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Update Avatar
  Future<void> updateAvatar(String avatarId) async {
    if (_user == null) return;

    final updates = {'avatarId': avatarId};
    await _handleUpdate(updates);
  }

  // Update Profile
  Future<void> updateProfile({
    required String name,
    required int? age,
    required String gender,
    required double? height,
  }) async {
    if (_user == null) return;

    final updates = {
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'avatarInitial': name.isNotEmpty ? name[0].toUpperCase() : 'U',
    };

    await _handleUpdate(updates);

    if (_isOnline) {
      try {
        await _user!.updateDisplayName(name);
        await _user!.reload();
        _user = _auth.currentUser;
      } catch (e) {
        // Ignore
      }
    }
  }

  // Update Health Goals
  Future<void> updateHealthGoals(Map<String, dynamic> newGoals) async {
    if (_user == null) return;
    final updates = {'goals': newGoals};
    await _handleUpdate(updates);
  }

  // Update Notification Settings
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    if (_user == null) return;
    final updates = {'notificationSettings': settings};
    await _handleUpdate(updates);
  }

  // Update
  Future<void> _handleUpdate(Map<String, dynamic> updates) async {
    await _checkConnectivity();

    if (_userData != null) {
      final currentData = Map<String, dynamic>.from(_userData!);
      currentData.addAll(updates);
      _updateLocalState(currentData);
    }

    if (_isOnline) {
      try {
        await _db.collection('users').doc(_user!.uid).update(updates);
      } catch (e) {
        await _offlineService.savePendingUserUpdate(updates);
      }
    } else {
      await _offlineService.savePendingUserUpdate(updates);
    }
  }

  // Change Password
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    if (_user == null) return;
    await _checkConnectivity();

    if (!_isOnline) {
      throw "You are offline. Password change requires an internet connection.";
    }

    AuthCredential credential = EmailAuthProvider.credential(
        email: _user!.email!, password: currentPassword);
    await _user!.reauthenticateWithCredential(credential);
    await _user!.updatePassword(newPassword);
  }

  // Delete Account
  Future<void> deleteAccount() async {
    if (_user == null) return;
    await _checkConnectivity();

    if (!_isOnline) {
      throw "You are offline. Account deletion requires an internet connection.";
    }

    try {
      await _db.collection('users').doc(_user!.uid).delete();
      await _user!.delete();
    } catch (e) {
      throw 'Failed to delete account. Please re-login and try again.';
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
