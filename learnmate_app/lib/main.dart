import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/video_screen.dart';
import 'screens/flash_notes.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B9D),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFFFF6B9D), // Playful Pink
          secondary: const Color(0xFF4ECDC4), // Mint Green
          tertiary: const Color(0xFFFFD93D), // Sunny Yellow
          surface: const Color(0xFFFFF8F0), // Cream
          background: const Color(0xFFF0F8FF), // Alice Blue
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF2D3748),
        ),
        textTheme: GoogleFonts.balooBhai2TextTheme().copyWith(
          headlineLarge: GoogleFonts.balooBhai2(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
          headlineMedium: GoogleFonts.balooBhai2(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
          headlineSmall: GoogleFonts.balooBhai2(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
          bodyLarge: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF4A5568),
          ),
          bodyMedium: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF718096),
          ),
          labelLarge: GoogleFonts.comicNeue(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 6,
            shadowColor: Colors.black.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            textStyle: GoogleFonts.comicNeue(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFFF6B9D), width: 3),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          labelStyle: GoogleFonts.nunito(
            fontSize: 16,
            color: const Color(0xFF718096),
          ),
          hintStyle: GoogleFonts.nunito(
            fontSize: 16,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.balooBhai2(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF2D3748),
          ),
        ),
      ),
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
