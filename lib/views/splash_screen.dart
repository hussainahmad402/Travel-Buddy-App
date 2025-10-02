import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelbuddy/routes/app_routes.dart';
import 'package:travelbuddy/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late Animation<double> _subtitleFade;

  final String _title = "Travel Buddy";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Fade animations for each letter
    _fadeAnimations = List.generate(
      _title.length,
      (index) {
        final start = index / (_title.length + 2);
        final end = (index + 1) / (_title.length + 2);
        return Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeIn),
          ),
        );
      },
    );

    // Subtitle fade after letters finish
    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (!mounted) return;

    await Future.delayed(const Duration(seconds: 1)); // wait for animation

    if (isFirstTime) {
      // ✅ Use centralized route
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    } else {
      final authController = Provider.of<AuthController>(context, listen: false);
      await authController.loadStoredAuth();

      if (!mounted) return;

      if (authController.isLoggedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with letters fading one by one
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _title.length,
                (index) {
                  return FadeTransition(
                    opacity: _fadeAnimations[index],
                    child: Text(
                      _title[index],
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle fades in smoothly
            FadeTransition(
              opacity: _subtitleFade,
              child: const Text(
                "Your Perfect Partner In Every Trip",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
