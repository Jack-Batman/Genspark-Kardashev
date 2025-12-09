import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/constants.dart';
import 'models/game_state.dart';
import 'models/artifact.dart';
import 'models/tutorial_state.dart';
import 'providers/game_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/game_screen.dart';
import 'services/audio_service.dart';
import 'services/crash_service.dart';
import 'services/analytics_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (with error handling for missing config)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase services
    await CrashService.initialize();
    await AnalyticsService.initialize();
    
    // Log session start
    await AnalyticsService.logSessionStart();
    
    if (kDebugMode) {
      debugPrint('Firebase initialized successfully');
    }
  } catch (e) {
    // Firebase not configured - continue without it
    if (kDebugMode) {
      debugPrint('Firebase not configured: $e');
      debugPrint('App will run without Firebase services');
    }
  }
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(GameStateAdapter());
  Hive.registerAdapter(OwnedArtifactAdapter());
  Hive.registerAdapter(TutorialStateDataAdapter());
  
  // Initialize audio service
  await AudioService.initialize();
  
  runApp(const KardashevApp());
}

class KardashevApp extends StatelessWidget {
  const KardashevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider()..initialize(),
      child: MaterialApp(
        title: 'Kardashev Ascension',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.backgroundDark,
          colorScheme: ColorScheme.dark(
            primary: AppColors.eraIEnergy,
            secondary: AppColors.goldAccent,
            surface: AppColors.surfaceDark,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onComplete: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }
    return const GameScreen();
  }
}
