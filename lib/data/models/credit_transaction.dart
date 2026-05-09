enum TransactionType {
  earn,
  spend,
  bonus,
  refund,
  adminAdjustment,
  signup;

  static TransactionType fromString(String value) {
    switch (value) {
      case 'earn': return TransactionType.earn;
      case 'spend': return TransactionType.spend;
      case 'bonus': return TransactionType.bonus;
      case 'refund': return TransactionType.refund;
      case 'admin_adjustment': return TransactionType.adminAdjustment;
      case 'signup': return TransactionType.signup;
      default: return TransactionType.earn;
    }
  }

  bool get isCredit => this != TransactionType.spend;

  String get label {
    switch (this) {
      case TransactionType.earn: return 'Delivery completed';
      case TransactionType.spend: return 'Delivery posted';
      case TransactionType.bonus: return 'Streak bonus';
      case TransactionType.refund: return 'Delivery refund';
      case TransactionType.adminAdjustment: return 'Admin adjustment';
      case TransactionType.signup: return 'Welcome bonus';
    }
  }
}

class CreditTransaction {
  final String id;
  final String? fromUserId;
  final String toUserId;
  final int amount;
  final TransactionType type;
  final String? referenceId;
  final DateTime createdAt;

  const CreditTransaction({
    required this.id,
    this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.type,
    this.referenceId,
    required this.createdAt,
  });

  factory CreditTransaction.fromJson(Map<String, dynamic> json) {
    return CreditTransaction(
      id: json['id'] as String,
      fromUserId: json['from_user_id'] as String?,
      toUserId: json['to_user_id'] as String,
      amount: json['amount'] as int,
      type: TransactionType.fromString(json['type'] as String),
      referenceId: json['reference_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get displayLabel {
    switch (type) {
      case TransactionType.earn: return 'Delivery completed';
      case TransactionType.spend: return 'Delivery posted';
      case TransactionType.bonus: return 'Streak bonus';
      case TransactionType.refund: return 'Delivery refund';
      case TransactionType.adminAdjustment: return 'Admin adjustment';
      case TransactionType.signup: return 'Welcome bonus';
    }
  }

  bool get isIncoming => type != TransactionType.spend;

  String get displayAmount {
    final sign = isIncoming ? '+' : '-';
    return '${sign}T$amount';
  }
}
