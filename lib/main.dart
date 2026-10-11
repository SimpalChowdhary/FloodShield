import 'package:flutter/material.dart';

import 'routes/app_routes.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

import 'screens/role/citizen_home_screen.dart' as citizen;
import 'screens/role/authority_home_screen.dart' as authority;
import 'screens/role/field_team_home_screen.dart' as field_team;

import 'screens/emergency/report_flood_screen.dart';
import 'screens/emergency/report_history_screen.dart';

import 'screens/map/map_screen.dart';
import 'screens/shelter/shelter_screen.dart';
import 'screens/resources/resource_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FloodShieldApp());
}

class FloodShieldApp extends StatelessWidget {
  const FloodShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FloodShield',

      // Always start with the splash screen.
      // SplashScreen should check authentication and navigate
      // to LoginScreen when the user is not logged in.
      initialRoute: AppRoutes.splash,

      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),

        // Authentication
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.signup: (context) => const SignupScreen(),

        // Role-based dashboards
        AppRoutes.citizenHome: (context) =>
            const citizen.CitizenHomeScreen(),

        AppRoutes.authorityHome: (context) =>
            const authority.AuthorityHomeScreen(),

        AppRoutes.fieldTeamHome: (context) =>
            const field_team.FieldTeamHomeScreen(),

        // Generic home should open Login, not a dashboard directly.
        AppRoutes.home: (context) => const LoginScreen(),

        // Other screens
        AppRoutes.reportFlood: (context) => const ReportFloodScreen(),
        AppRoutes.reportHistory: (context) => const ReportHistoryScreen(),
        AppRoutes.map: (context) => const MapScreen(),
        AppRoutes.shelters: (context) => const ShelterScreen(),
        AppRoutes.resources: (context) => const ResourceScreen(),
      },
    );
  }
}