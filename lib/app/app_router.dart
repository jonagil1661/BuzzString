import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_providers.dart';
import '../google_login_page.dart';
import '../home_page.dart';
import '../next_pickup_dropoff_page.dart';
import '../plan_next_arrival_page.dart';
import '../request_page.dart';
import '../statistics_page.dart';
import '../stringer_dashboard.dart';
import '../stringer_home_page.dart';
import '../tracking_page.dart';
import '../update_string_types.dart';

class AppPaths {
  static const login = '/login';
  static const customerHome = '/customer';
  static const customerRequest = '/customer/request';
  static const customerTracking = '/customer/tracking';
  static const customerPickupDropoff = '/customer/next-pickup-dropoff';
  static const stringerHome = '/stringer';
  static const stringerDashboard = '/stringer/dashboard';
  static const stringerUpdateStrings = '/stringer/update-strings';
  static const stringerPlanArrival = '/stringer/plan-arrival';
  static const stringerStatistics = '/stringer/statistics';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: AppPaths.login,
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges),
    redirect: (context, state) {
      final user = authService.currentUser;
      final location = state.matchedLocation;
      final isLoggingIn = location == AppPaths.login;
      final isCustomerRoute = location.startsWith('/customer');
      final isStringerRoute = location.startsWith('/stringer');

      if (user == null) {
        return isLoggingIn ? null : AppPaths.login;
      }

      final role = roleForEmail(user.email);

      if (isLoggingIn || location == '/') {
        return role == AppUserRole.stringer
            ? AppPaths.stringerHome
            : AppPaths.customerHome;
      }

      if (role == AppUserRole.stringer && isCustomerRoute) {
        return AppPaths.stringerHome;
      }

      if (role == AppUserRole.customer && isStringerRoute) {
        return AppPaths.customerHome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppPaths.login,
        builder: (context, state) => const GoogleLoginPage(),
      ),
      GoRoute(
        path: AppPaths.customerHome,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'request',
            builder: (context, state) => const StringingRequestPage(),
          ),
          GoRoute(
            path: 'tracking',
            builder: (context, state) => const TrackingPage(),
          ),
          GoRoute(
            path: 'next-pickup-dropoff',
            builder: (context, state) => const NextPickupDropoffPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppPaths.stringerHome,
        builder: (context, state) => const StringerHomePage(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const StringerDashboard(),
          ),
          GoRoute(
            path: 'update-strings',
            builder: (context, state) => const UpdateStringTypes(),
          ),
          GoRoute(
            path: 'plan-arrival',
            builder: (context, state) => const PlanNextArrivalPage(),
          ),
          GoRoute(
            path: 'statistics',
            builder: (context, state) => const StatisticsPage(),
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((dynamic _) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
