import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/video_screen.dart';
import 'screens/flash_notes.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/audio_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LearnMateApp());
}

class LearnMateApp extends StatelessWidget {
  const LearnMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'LearnMate',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            home: _buildHomeScreen(authProvider),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/video': (context) => const VideoScreen(),
              '/flash_notes': (context) => const FlashNotesScreen(),
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: const Center(
                    child: Text('Page not found!'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHomeScreen(AuthProvider authProvider) {
    switch (authProvider.status) {
      case AuthStatus.uninitialized:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.loading:
        return const AuthScreen();
    }
  }
}
```
