import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:healthprime/firebase_options.dart';
import 'package:healthprime/core/theme/app_theme.dart';
import 'package:healthprime/core/providers/auth_provider.dart';
import 'package:healthprime/core/providers/records_provider.dart';
import 'package:healthprime/core/providers/friends_provider.dart';
import 'package:healthprime/core/providers/tournament_provider.dart';
import 'package:healthprime/core/providers/alert_provider.dart';
import 'package:healthprime/core/services/background_service.dart';
import 'package:healthprime/features/auth/presentation/pages/login_screen.dart';
import 'package:healthprime/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase initialization check: $e");
  }

  await BackgroundService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProxyProvider<AuthProvider, RecordsProvider>(
          create: (_) => RecordsProvider(),
          update: (_, auth, records) => records!..updateUser(auth.user),
        ),

        ChangeNotifierProxyProvider<AuthProvider, FriendsProvider>(
          create: (_) => FriendsProvider(),
          update: (_, auth, friends) => friends!..updateUser(auth.user),
        ),

        ChangeNotifierProxyProvider<AuthProvider, TournamentProvider>(
          create: (_) => TournamentProvider(),
          update: (_, auth, tournament) => tournament!..updateUser(auth.user),
        ),

        ChangeNotifierProxyProvider3<AuthProvider, FriendsProvider, TournamentProvider, AlertProvider>(
          create: (_) => AlertProvider(),
          update: (_, auth, friends, tournaments, alerts) =>
          alerts!..update(auth, friends, tournaments),
        ),
      ],
      child: MaterialApp(
        title: 'HealthPrime',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isAuth) {
      return const MainNavigation();
    } else {
      return const LoginPage();
    }
  }
}