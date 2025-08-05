import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/video_screen.dart';
import 'screens/flash_notes.dart';
import 'theme/app_theme.dart'; // 👈 Import theme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LearnMateApp());
}

class LearnMateApp extends StatelessWidget {
  const LearnMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(), // 👈 Apply theme here
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
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
  }
}
