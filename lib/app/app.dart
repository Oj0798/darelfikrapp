import 'package:flutter/material.dart';
import 'theme.dart';
import 'router.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/library/library_home_screen.dart';
import '../features/library/screens/subscription_screen.dart';


class DarElFikrApp extends StatelessWidget {
  const DarElFikrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dar El Fikr',
      theme: AppTheme.light(),
      initialRoute: AppRoutes.welcome,
      routes: {
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.libraryHome: (_) => const LibraryHomeScreen(),
        AppRoutes.subscription: (_) => const SubscriptionScreen(),

      },
    );
  }
}
