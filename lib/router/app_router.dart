import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:house_pin/screens/sign_in_screen.dart';
import 'package:house_pin/screens/sign_up_screen.dart';
import 'package:house_pin/screens/splash_screen.dart';
import 'package:house_pin/widgets/scaffold_with_navbar.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // shell route for main navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavbar(location: state.uri.path, child: child);
        },
        routes: [
          // builder is empty container, because actual screens are already in ScaffoldWithNavbar
          GoRoute(path: '/home', builder: (context, state) => Container()),
          GoRoute(path: '/map', builder: (context, state) => Container()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text(
          'Error: ${state.error?.toString() ?? "Unknown error"}',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    ),
  );
}
