import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PresenceService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Configure User Presence
  void configureUserPresence() {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final String uid = user.uid;
    final DatabaseReference userStatusDatabaseRef =
    _db.ref().child('/status/$uid');

    final DatabaseReference connectedRef = _db.ref().child('.info/connected');

    connectedRef.onValue.listen((event) {
      final bool isConnected = event.snapshot.value as bool? ?? false;

      if (isConnected) {
        // When Disconnected Set To Offline
        userStatusDatabaseRef.onDisconnect().set({
          'state': 'offline',
          'last_changed': ServerValue.timestamp,
        }).then((_) {
          // While Connected Set To Online
          userStatusDatabaseRef.set({
            'state': 'online',
            'last_changed': ServerValue.timestamp,
          });
        });
      }
    });
  }

  // Set Offline
  Future<void> setOffline() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final DatabaseReference userStatusDatabaseRef =
    _db.ref().child('/status/${user.uid}');

    await userStatusDatabaseRef.set({
      'state': 'offline',
      'last_changed': ServerValue.timestamp,
    });
  }
}