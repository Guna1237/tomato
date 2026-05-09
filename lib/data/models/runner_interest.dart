enum InterestStatus {
  waiting,
  selected,
  dismissed;

  static InterestStatus fromString(String value) {
    switch (value) {
      case 'selected': return InterestStatus.selected;
      case 'dismissed': return InterestStatus.dismissed;
      default: return InterestStatus.waiting;
    }
  }
}

class RunnerInterest {
  final String id;
  final String deliveryId;
  final String runnerId;
  final DateTime expressedAt;
  final InterestStatus status;
  final RunnerProfile? runnerProfile;

  const RunnerInterest({
    required this.id,
    required this.deliveryId,
    required this.runnerId,
    required this.expressedAt,
    required this.status,
    this.runnerProfile,
  });

  factory RunnerInterest.fromJson(Map<String, dynamic> json) {
    return RunnerInterest(
      id: json['id'] as String,
      deliveryId: json['delivery_id'] as String,
      runnerId: json['runner_id'] as String,
      expressedAt: DateTime.parse(json['expressed_at'] as String),
      status: InterestStatus.fromString(json['status'] as String),
      runnerProfile: json['profiles'] != null
          ? RunnerProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RunnerProfile {
  final String id;
  final String displayName;
  final String? photoUrl;
  final double reliability;
  final int streakDays;
  final String faceStatus;

  const RunnerProfile({
    required this.id,
    required this.displayName,
    this.photoUrl,
    required this.reliability,
    required this.streakDays,
    required this.faceStatus,
  });

  factory RunnerProfile.fromJson(Map<String, dynamic> json) {
    return RunnerProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      photoUrl: json['photo_url'] as String?,
      reliability: (json['reliability'] as num?)?.toDouble() ?? 1.0,
      streakDays: json['streak_days'] as int? ?? 0,
      faceStatus: json['face_status'] as String? ?? 'pending',
    );
  }

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }
}
