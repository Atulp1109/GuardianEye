// splash_screen.dart

import 'package:flutter/material.dart';
import 'package:guardians_eye/admin_page.dart';
import 'package:guardians_eye/authentication/views/login_page.dart';
import 'package:guardians_eye/registered_cases_screen.dart';
import 'package:nb_utils/nb_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    await initialize(); // nb_utils init (important)

    // Simulate splash delay (optional)
    await 2.seconds.delay;

    final userRole = getStringAsync('user_role');

    if (userRole.isNotEmpty) {
      if (userRole == 'admin') {
        // Navigate to admin dashboard
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AdminPage()));
      } else if (userRole == 'staff') {
        // Navigate to staff dashboard
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => RegisteredCasesScreen()));
      }
    } else {
      // Default case, navigate to login
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Guardians Eye',
          style: boldTextStyle(size: 24),
        ),
      ),
    );
  }
}
