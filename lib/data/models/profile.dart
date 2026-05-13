class Profile {
  final String id;
  final String email;
  final String role; // student, faculty, admin
  final String displayName;
  final String? rollNumber;
  final String? employeeId;
  final String? phoneNumber;
  final String? photoUrl;
  final String? fcmToken;
  final String faceStatus; // pending, approved, rejected, flagged
  final double? faceConfidence;
  final int tomatoCredits;
  final int streakDays;
  final double reliability;
  final bool isRunner;
  final bool runnerActive;
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.email,
    required this.role,
    required this.displayName,
    this.rollNumber,
    this.employeeId,
    this.phoneNumber,
    this.photoUrl,
    this.fcmToken,
    required this.faceStatus,
    this.faceConfidence,
    required this.tomatoCredits,
    required this.streakDays,
    required this.reliability,
    required this.isRunner,
    required this.runnerActive,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      displayName: json['display_name'] as String,
      rollNumber: json['roll_number'] as String?,
      employeeId: json['employee_id'] as String?,
      phoneNumber: json['phone_number'] as String?,
      photoUrl: json['photo_url'] as String?,
      fcmToken: json['fcm_token'] as String?,
      faceStatus: json['face_status'] as String? ?? 'pending',
      faceConfidence: json['face_confidence'] != null
          ? (json['face_confidence'] as num).toDouble()
          : null,
      tomatoCredits: json['tomato_credits'] as int? ?? 50,
      streakDays: json['streak_days'] as int? ?? 0,
      reliability: (json['reliability'] as num?)?.toDouble() ?? 1.0,
      isRunner: json['is_runner'] as bool? ?? false,
      runnerActive: json['runner_active'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role,
    'display_name': displayName,
    if (rollNumber != null) 'roll_number': rollNumber,
    if (employeeId != null) 'employee_id': employeeId,
    if (phoneNumber != null) 'phone_number': phoneNumber,
    if (photoUrl != null) 'photo_url': photoUrl,
    if (fcmToken != null) 'fcm_token': fcmToken,
    'face_status': faceStatus,
    if (faceConfidence != null) 'face_confidence': faceConfidence,
    'tomato_credits': tomatoCredits,
    'streak_days': streakDays,
    'reliability': reliability,
    'is_runner': isRunner,
    'runner_active': runnerActive,
    'created_at': createdAt.toIso8601String(),
  };

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  bool get isFaceApproved => faceStatus == 'approved';
  bool get isFaceFlagged => faceStatus == 'flagged';
  bool get isFacePending => faceStatus == 'pending';

  Profile copyWith({
    String? photoUrl,
    String? phoneNumber,
    String? faceStatus,
    double? faceConfidence,
    int? tomatoCredits,
    int? streakDays,
    double? reliability,
    bool? isRunner,
    bool? runnerActive,
    String? fcmToken,
  }) {
    return Profile(
      id: id,
      email: email,
      role: role,
      displayName: displayName,
      rollNumber: rollNumber,
      employeeId: employeeId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      faceStatus: faceStatus ?? this.faceStatus,
      faceConfidence: faceConfidence ?? this.faceConfidence,
      tomatoCredits: tomatoCredits ?? this.tomatoCredits,
      streakDays: streakDays ?? this.streakDays,
      reliability: reliability ?? this.reliability,
      isRunner: isRunner ?? this.isRunner,
      runnerActive: runnerActive ?? this.runnerActive,
      createdAt: createdAt,
    );
  }
}
