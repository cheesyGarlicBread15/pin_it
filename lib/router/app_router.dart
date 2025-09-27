import 'package:firebase_auth/firebase_auth.dart';
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
          GoRoute(path: '/profile', builder: (context, state) => Container()),
        ],
        redirect: (context, state) {
          final currentPath = state.uri.path;

          // Allow splash screen for everyone
          if (currentPath == '/') {
            return null;
          }

          final isSignedIn = FirebaseAuth.instance.currentUser != null;
          final isAuthRoute =
              currentPath == '/signin' || currentPath == '/signup';

          // if not signed in and the path is not auth route (like home, gallery and profile)
          if (!isSignedIn && !isAuthRoute) {
            return '/signin';
          }

          // if is signed in and path is sign up, return null since user will sign up another account
          // sign in is detected after sign up due to supabase active session
          if (isSignedIn && currentPath == 'signup') {
            return null;
          }

          if (isSignedIn && currentPath == '/signin') {
            return '/home';
          }

          return null;
        },
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
