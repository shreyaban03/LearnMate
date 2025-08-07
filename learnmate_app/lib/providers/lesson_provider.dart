import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/lesson_model.dart';

enum LessonStatus {
  idle,
  generating,
  generated,
  error,
}

class LessonProvider with ChangeNotifier {
  LessonStatus _status = LessonStatus.idle;
  LessonModel? _currentLesson;
  List<LessonModel> _lessonHistory = [];
  String? _errorMessage;

  // API Configuration
  static const String _baseUrl = 'YOUR_PYTHON_BACKEND_URL'; // Replace with your backend URL
  static const Duration _timeoutDuration = Duration(seconds: 30);

  // Getters
  LessonStatus get status => _status;
  LessonModel? get currentLesson => _currentLesson;
  List<LessonModel> get lessonHistory => List.unmodifiable(_lessonHistory);
  String? get errorMessage => _errorMessage;
  bool get isGenerating => _status == LessonStatus.generating;

  // Generate Lesson
  Future<bool> generateLesson(String topic, String? userId) async {
    try {
      _setStatus(LessonStatus.generating);
      _clearError();

      final response = await http
          .post(
            Uri.parse('$_baseUrl/generate_lesson'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $userId', // If you implement JWT
            },
            body: jsonEncode({
              'topic': topic.trim(),
              'user_id': userId,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentLesson = LessonModel.fromJson(data);
        _lessonHistory.insert(0, _currentLesson!);
        _setStatus(LessonStatus.generated);
        return true;
      } else {
        _handleApiError(response.statusCode, response.body);
        return false;
      }
    } catch (e) {
      _handleGenerationError(e);
      return false;
    }
  }

  // Generate Mock Lesson (for testing without backend)
  Future<bool> generateMockLesson(String topic) async {
    try {
      _setStatus(LessonStatus.generating);
      _clearError();

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 3));

      final mockLesson = LessonModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        topic: topic,
        description: 'AI-generated lesson about $topic',
        audioUrl: 'https://example.com/audio/${topic.toLowerCase().replaceAll(' ', '_')}.mp3',
        avatarName: _generateRandomAvatarName(),
        flashNotes: _generateMockFlashNotes(topic),
        createdAt: DateTime.now(),
        duration: const Duration(minutes: 2, seconds: 30),
      );

      _currentLesson = mockLesson;
      _lessonHistory.insert(0, mockLesson);
      _setStatus(LessonStatus.generated);
      return true;
    } catch (e) {
      _handleGenerationError(e);
      return false;
    }
  }

  // Save Lesson to Favorites
  Future<void> saveLessonToFavorites(LessonModel lesson) async {
    try {
      // Here you would typically save to Firebase or your backend
      // For now, we'll just add a flag or save locally
      
      // You can implement this based on your backend API
      debugPrint('Saving lesson to favorites: ${lesson.topic}');
      
      // Notify listeners if needed
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving lesson to favorites: $e');
    }
  }

  // Get Lesson History
  Future<void> loadLessonHistory(String userId) async {
    try {
      // Implement loading lesson history from backend
      // This is a placeholder implementation
      
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/lessons/$userId'),
      //   headers: {'Authorization': 'Bearer $userId'},
      // );
      
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = jsonDecode(response.body);
      //   _lessonHistory = data.map((json) => LessonModel.fromJson(json)).toList();
      //   notifyListeners();
      // }
      
    } catch (e) {
      debugPrint('Error loading lesson history: $e');
    }
  }

  // Helper Methods
  void _setStatus(LessonStatus status) {
    _status = status;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _handleApiError(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        _errorMessage = 'Invalid request. Please check your input.';
        break;
      case 401:
        _errorMessage = 'Authentication failed. Please sign in again.';
        break;
      case 429:
        _errorMessage = 'Too many requests. Please try again later.';
        break;
      case 500:
        _errorMessage = 'Server error. Please try again later.';
        break;
      default:
        _errorMessage = 'Failed to generate lesson. Please try again.';
    }
    _setStatus(LessonStatus.error);
  }

  void _handleGenerationError(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      _errorMessage = 'Request timed out. Please try again.';
    } else if (error.toString().contains('SocketException')) {
      _errorMessage = 'Network error. Please check your connection.';
    } else {
      _errorMessage = 'Failed to generate lesson. Please try again.';
    }
    _setStatus(LessonStatus.error);
  }

  String _generateRandomAvatarName() {
    final names = [
      'Prof. Nova', 'Dr. Sage', 'Prof. Luna', 'Dr. Cosmos',
      'Prof. Iris', 'Dr. Phoenix', 'Prof. Atlas', 'Dr. Vega',
      'Prof. Echo', 'Dr. Orion', 'Prof. Zara', 'Dr. Neo',
    ];
    names.shuffle();
    return names.first;
  }

  List<FlashNote> _generateMockFlashNotes(String topic) {
    return [
      FlashNote(
        question: 'What is $topic?',
        answer: 'This is a comprehensive explanation of $topic that covers the fundamental concepts and principles.',
      ),
      FlashNote(
        question: 'How does $topic work?',
        answer: 'The mechanism behind $topic involves several key processes and interactions that work together.',
      ),
      FlashNote(
        question: 'Where is $topic used?',
        answer: '$topic has applications in various fields and industries, making it highly relevant in today\'s world.',
      ),
      FlashNote(
        question: 'Why is $topic important?',
        answer: 'Understanding $topic is crucial because it impacts many aspects of our daily lives and future developments.',
      ),
      FlashNote(
        question: 'What are the key benefits of $topic?',
        answer: '$topic offers numerous advantages including improved efficiency, better understanding, and practical applications.',
      ),
    ];
  }

  // Clear current lesson
  void clearCurrentLesson() {
    _currentLesson = null;
    _setStatus(LessonStatus.idle);
  }

  // Retry generation
  Future<bool> retryGeneration(String topic, String? userId) async {
    return await generateLesson(topic, userId);
  }
}
```

