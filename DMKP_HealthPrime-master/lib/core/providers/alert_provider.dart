import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_logic.dart';
import 'auth_provider.dart';
import 'friends_provider.dart';
import 'tournament_provider.dart';

class AlertProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  User? _user;
  AuthProvider? _authProvider;
  FriendsProvider? _friendsProvider;
  TournamentProvider? _tournamentProvider;

  List<Map<String, dynamic>> _alerts = [];
  List<Map<String, dynamic>> get alerts => _alerts;
  int get unreadCount => _alerts.where((a) => a['read'] == false).length;

  bool _notificationsInitialized = false;
  StreamSubscription? _alertsSubscription;

  void update(AuthProvider auth, FriendsProvider friends,
      TournamentProvider tournaments) {
    _authProvider = auth;
    _friendsProvider = friends;
    _tournamentProvider = tournaments;

    if (_user?.uid != auth.user?.uid) {
      _user = auth.user;
      _alertsSubscription?.cancel();

      if (_user != null) {
        _saveUidForBackground(_user!.uid);
        _initNotifications();
        _listenToAlerts();
      } else {
        _alerts = [];
        notifyListeners();
      }
    }

    if (_user != null) {
      _scanForeground();
    }
  }

  // Save User ID for Background Notification Checks
  Future<void> _saveUidForBackground(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_uid', uid);
  }

  Future<void> _initNotifications() async {
    if (_notificationsInitialized) return;

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: android);

    await _notificationsPlugin.initialize(settings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'hp_channel',
      'Alerts',
      description: 'Health Prime Notifications',
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _notificationsInitialized = true;
  }

  // Listen to Alerts
  void _listenToAlerts() {
    if (_user == null) return;

    // Listen to notifications collection
    _alertsSubscription = _db
        .collection('users')
        .doc(_user!.uid)
        .collection('notifications')
        .snapshots()
        .listen((snapshot) {
      var loaded = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        if (!data.containsKey('dismissed')) data['dismissed'] = false;
        return data;
      }).toList();

      // Filter Dismissed Items
      loaded = loaded.where((a) => a['dismissed'] == false).toList();

      // Sort by Date
      loaded.sort((a, b) {
        final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
        final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      _alerts = loaded;
      notifyListeners();
    });
  }

  // Scan Foreground
  Future<void> _scanForeground() async {
    if (_user != null) {
      await NotificationLogic.performScan(_user!.uid);
    }
  }

  // Mark All Alerts as Read
  Future<void> markAllAsRead() async {
    if (_user == null) return;
    final batch = _db.batch();
    final unread = _alerts.where((a) => a['read'] == false);

    if (unread.isEmpty) return;

    for (var item in unread) {
      final ref = _db
          .collection('users')
          .doc(_user!.uid)
          .collection('notifications')
          .doc(item['id']);
      batch.update(ref, {'read': true});
    }
    await batch.commit();
  }

  // Dismiss Alert
  Future<void> dismissAlert(String id) async {
    if (_user == null) return;

    await _db
        .collection('users')
        .doc(_user!.uid)
        .collection('notifications')
        .doc(id)
        .update({'dismissed': true});
  }

  @override
  void dispose() {
    _alertsSubscription?.cancel();
    super.dispose();
  }
}
