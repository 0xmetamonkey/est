// Shot model - represents a task/activity as a "shot" in your life movie
class Shot {
  final String id;
  final String title;
  final ShotType type;
  final bool captureFrame;
  final DateTime createdAt;
  ShotStatus status;
  DateTime? startedAt;
  int totalDurationSeconds;
  int capturedFrames;
  List<ShotSession> sessions;
  List<String> videoPaths;  // Paths to recorded videos
  List<String> imagePaths;  // Paths to captured images

  Shot({
    required this.id,
    required this.title,
    required this.type,
    this.captureFrame = false,
    required this.createdAt,
    this.status = ShotStatus.pending,
    this.startedAt,
    this.totalDurationSeconds = 0,
    this.capturedFrames = 0,
    List<ShotSession>? sessions,
    List<String>? videoPaths,
    List<String>? imagePaths,
  }) : sessions = sessions ?? [],
       videoPaths = videoPaths ?? [],
       imagePaths = imagePaths ?? [];

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'captureFrame': captureFrame,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'startedAt': startedAt?.toIso8601String(),
      'totalDurationSeconds': totalDurationSeconds,
      'capturedFrames': capturedFrames,
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'videoPaths': videoPaths,
      'imagePaths': imagePaths,
    };
  }

  // Create from JSON
  factory Shot.fromJson(Map<String, dynamic> json) {
    return Shot(
      id: json['id'],
      title: json['title'],
      type: ShotType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ShotType.action,
      ),
      captureFrame: json['captureFrame'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      status: ShotStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ShotStatus.pending,
      ),
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt']) 
          : null,
      totalDurationSeconds: json['totalDurationSeconds'] ?? 0,
      capturedFrames: json['capturedFrames'] ?? 0,
      sessions: (json['sessions'] as List?)
          ?.map((s) => ShotSession.fromJson(s))
          .toList() ?? [],
      videoPaths: (json['videoPaths'] as List?)?.cast<String>() ?? [],
      imagePaths: (json['imagePaths'] as List?)?.cast<String>() ?? [],
    );
  }

  // Create from legacy activity string
  factory Shot.fromLegacyActivity(String activity) {
    return Shot(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: activity,
      type: _inferShotType(activity),
      captureFrame: _shouldCaptureFrame(activity),
      createdAt: DateTime.now(),
    );
  }

  static ShotType _inferShotType(String activity) {
    final lower = activity.toLowerCase();
    
    if (lower.contains('code') || lower.contains('write')) {
      return ShotType.action;
    } else if (lower.contains('yoga') || lower.contains('abs') || 
               lower.contains('resistance') || lower.contains('crunches')) {
      return ShotType.physical;
    } else if (lower.contains('shoot') || lower.contains('tape') || 
               lower.contains('audition')) {
      return ShotType.content;
    } else if (lower.contains('read') || lower.contains('loop')) {
      return ShotType.learning;
    } else if (lower.contains('sketch') || lower.contains('paint') || 
               lower.contains('piano')) {
      return ShotType.creative;
    }
    
    return ShotType.action;
  }

  static bool _shouldCaptureFrame(String activity) {
    final lower = activity.toLowerCase();
    return lower.contains('shoot') || 
           lower.contains('tape') || 
           lower.contains('sketch') || 
           lower.contains('paint');
  }
}

// Shot session - each time you work on a shot
class ShotSession {
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;

  ShotSession({
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  factory ShotSession.fromJson(Map<String, dynamic> json) {
    return ShotSession(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      durationSeconds: json['durationSeconds'],
    );
  }
}

enum ShotType {
  action,      // 🎬 Deep work (coding, writing)
  creative,    // 🎨 Creative work (art, music)
  physical,    // 💪 Physical activities (yoga, workout)
  content,     // 📹 Content creation (shooting, taping)
  learning,    // 📚 Learning (reading, courses)
}

enum ShotStatus {
  pending,
  active,
  completed,
}

// Extension for shot type metadata
extension ShotTypeExtension on ShotType {
  String get emoji {
    switch (this) {
      case ShotType.action:
        return '🎬';
      case ShotType.creative:
        return '🎨';
      case ShotType.physical:
        return '💪';
      case ShotType.content:
        return '📹';
      case ShotType.learning:
        return '📚';
    }
  }

  String get displayName {
    switch (this) {
      case ShotType.action:
        return 'Action';
      case ShotType.creative:
        return 'Creative';
      case ShotType.physical:
        return 'Physical';
      case ShotType.content:
        return 'Content';
      case ShotType.learning:
        return 'Learning';
    }
  }

  String get description {
    switch (this) {
      case ShotType.action:
        return 'Deep work & focus';
      case ShotType.creative:
        return 'Art & expression';
      case ShotType.physical:
        return 'Movement & fitness';
      case ShotType.content:
        return 'Creating content';
      case ShotType.learning:
        return 'Growth & knowledge';
    }
  }
}
