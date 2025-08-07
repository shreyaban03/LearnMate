class LessonModel {
  final String id;
  final String topic;
  final String description;
  final String? audioUrl;
  final String avatarName;
  final List<FlashNote> flashNotes;
  final DateTime createdAt;
  final Duration? duration;

  LessonModel({
    required this.id,
    required this.topic,
    required this.description,
    this.audioUrl,
    required this.avatarName,
    required this.flashNotes,
    required this.createdAt,
    this.duration,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? '',
      topic: json['topic'] ?? '',
      description: json['description'] ?? '',
      audioUrl: json['audioUrl'],
      avatarName: json['avatarName'] ?? 'Prof. Nova',
      flashNotes: (json['flashNotes'] as List<dynamic>? ?? [])
          .map((note) => FlashNote.fromJson(note))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      duration: json['duration'] != null 
          ? Duration(seconds: json['duration']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'description': description,
      'audioUrl': audioUrl,
      'avatarName': avatarName,
      'flashNotes': flashNotes.map((note) => note.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'duration': duration?.inSeconds,
    };
  }
}

class FlashNote {
  final String question;
  final String answer;

  FlashNote({
    required this.question,
    required this.answer,
  });

  factory FlashNote.fromJson(Map<String, dynamic> json) {
    return FlashNote(
      question: json['q'] ?? json['question'] ?? '',
      answer: json['a'] ?? json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'q': question,
      'a': answer,
    };
  }

  // For backward compatibility
  Map<String, String> toMap() {
    return {
      'q': question,
      'a': answer,
    };
  }
}
```

