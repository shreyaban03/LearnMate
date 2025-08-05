import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnmate_app/main.dart';

void main() {
  group('LearnMate App Tests', () {
    testWidgets('App starts with authentication screen', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const LearnMateApp());

      // Verify that the authentication screen is displayed
      expect(find.text('LearnMate'), findsOneWidget);
      expect(find.text('Welcome back to learning!'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Email validation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const LearnMateApp());

      // Find the email field and enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      
      // Find and tap the Sign In button
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      // Verify validation error appears
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Password validation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const LearnMateApp());

      // Find the password field and enter short password
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, '123');
      
      // Find and tap the Sign In button
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();

      // Verify validation error appears
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('Toggle between Sign In and Sign Up', (WidgetTester tester) async {
      await tester.pumpWidget(const LearnMateApp());

      // Initially should show Sign In
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Welcome back to learning!'), findsOneWidget);

      // Tap the toggle button
      final toggleButton = find.text('Don\'t have an account? Sign Up');
      await tester.tap(toggleButton);
      await tester.pump();

      // Should now show Sign Up
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Create your learning account'), findsOneWidget);
      expect(find.text('Already have an account? Sign In'), findsOneWidget);
    });

    testWidgets('Password visibility toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(const LearnMateApp());

      // Find the password field
      final passwordField = find.byType(TextFormField).last;
      
      // Initially password should be obscured
      final TextFormField passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, isTrue);

      // Find and tap the visibility toggle button
      final visibilityToggle = find.byIcon(Icons.visibility_outlined);
      await tester.tap(visibilityToggle);
      await tester.pump();

      // Password should now be visible
      final TextFormField updatedPasswordWidget = tester.widget(passwordField);
      expect(updatedPasswordWidget.obscureText, isFalse);
    });
  });

  group('Widget Tests', () {
    testWidgets('PromptInput widget displays correctly', (WidgetTester tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(), // PromptInput widget would be tested here
          ),
        ),
      );

      // Add specific widget tests as needed
    });
  });
}
