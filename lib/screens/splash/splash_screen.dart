
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final role = prefs.getString('role')?.toUpperCase().trim();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (!isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    switch (role) {
      case 'CITIZEN':
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.citizenHome,
        );
        break;

      case 'AUTHORITY':
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.authorityHome,
        );
        break;

      case 'FIELD_TEAM':
      case 'FIELD TEAM':
      case 'FIELD-TEAM':
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.fieldTeamHome,
        );
        break;

      default:
        Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                size: 65,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'FloodShield',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF12345A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Flood Emergency Coordination',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 35),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF1565C0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}