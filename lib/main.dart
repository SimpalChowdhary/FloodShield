import 'package:flutter/material.dart';

import 'routes/app_routes.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';

import 'screens/role/citizen_home_screen.dart';
import 'screens/role/authority_home_screen.dart';
import 'screens/role/field_team_home_screen.dart';

import 'screens/emergency/report_flood_screen.dart';
import 'screens/emergency/report_history_screen.dart';

import 'screens/map/map_screen.dart';
import 'screens/shelter/shelter_screen.dart';
import 'screens/resources/resource_screen.dart';

void main() {
  runApp(const FloodShieldApp());
}

class FloodShieldApp extends StatelessWidget {
  const FloodShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FloodShield',
      initialRoute: AppRoutes.splash,

      routes: {
        AppRoutes.splash: (context) =>
            const SplashScreen(),

        AppRoutes.login: (context) =>
            const LoginScreen(),

        AppRoutes.signup: (context) =>
            const SignupScreen(),

        AppRoutes.home: (context) =>
            const HomeScreen(),

        AppRoutes.citizenHome: (context) =>
            const CitizenHomeScreen(),

        AppRoutes.authorityHome: (context) =>
            const AuthorityHomeScreen(),

        AppRoutes.fieldTeamHome: (context) =>
            const FieldTeamHomeScreen(),

        AppRoutes.reportFlood: (context) =>
            const ReportFloodScreen(),

        AppRoutes.reportHistory: (context) =>
            const ReportHistoryScreen(),

        AppRoutes.map: (context) =>
            const MapScreen(),

        AppRoutes.shelters: (context) =>
            const ShelterScreen(),

        AppRoutes.resources: (context) =>
            const ResourceScreen(),
      },
    );
  }
}