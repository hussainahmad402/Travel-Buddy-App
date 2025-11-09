import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:travelbuddy/controllers/chat_controller.dart';
import 'package:travelbuddy/firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/trip_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/document_controller.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔹 Set global system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const TravelBuddyApp());
}

class TravelBuddyApp extends StatelessWidget {
  const TravelBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => TripController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => DocumentController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
      ],
      child: SafeArea(
        top: false,
        child: MaterialApp(
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
