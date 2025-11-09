import 'package:flutter/material.dart';
import 'package:travelbuddy/views/auth/login_screen.dart';
import 'package:travelbuddy/views/auth/register_screen.dart';
import 'package:travelbuddy/views/home/favourite_screen.dart';
import 'package:travelbuddy/views/home/onboarding/onboarding.dart';
import 'package:travelbuddy/views/home/profile_screen.dart';
import 'package:travelbuddy/views/splash_screen.dart';
import 'package:travelbuddy/views/auth/welcome_screen.dart';
import 'package:travelbuddy/views/home/home_screen.dart';

/// Centralized routes for the app
class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String favourites = '/favourites';
  static const String signup = '/signup';
  static const String profile = '/profile';



  /// Route generator
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    welcome: (context) => const WelcomeScreen(),
    home: (context) => const HomeScreen(),
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginScreen(),
    favourites: (context) => const FavouriteScreen(),
    signup: (context) => const RegisterScreen(),
    profile: (context) => const ProfileScreen(),
  };
}
