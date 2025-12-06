import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants.dart';
import 'models/game_state.dart';
import 'models/artifact.dart';
import 'models/tutorial_state.dart';
import 'providers/game_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(GameStateAdapter());
  Hive.registerAdapter(OwnedArtifactAdapter());
  Hive.registerAdapter(TutorialStateDataAdapter());
  
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
