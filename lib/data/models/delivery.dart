enum DeliveryStatus {
  pending,
  matching,
  accepted,
  pickedUp,
  enRoute,
  delivered,
  cancelled;

  static DeliveryStatus fromString(String value) {
    switch (value) {
      case 'pending': return DeliveryStatus.pending;
      case 'matching': return DeliveryStatus.matching;
      case 'accepted': return DeliveryStatus.accepted;
      case 'picked_up': return DeliveryStatus.pickedUp;
      case 'en_route': return DeliveryStatus.enRoute;
      case 'delivered': return DeliveryStatus.delivered;
      case 'cancelled': return DeliveryStatus.cancelled;
      default: return DeliveryStatus.pending;
    }
  }

  String toApiString() {
    switch (this) {
      case DeliveryStatus.pending: return 'pending';
      case DeliveryStatus.matching: return 'matching';
      case DeliveryStatus.accepted: return 'accepted';
      case DeliveryStatus.pickedUp: return 'picked_up';
      case DeliveryStatus.enRoute: return 'en_route';
      case DeliveryStatus.delivered: return 'delivered';
      case DeliveryStatus.cancelled: return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case DeliveryStatus.pending: return 'Pending';
      case DeliveryStatus.matching: return 'Finding runner';
      case DeliveryStatus.accepted: return 'Runner assigned';
      case DeliveryStatus.pickedUp: return 'Picked up';
      case DeliveryStatus.enRoute: return 'En route';
      case DeliveryStatus.delivered: return 'Delivered';
      case DeliveryStatus.cancelled: return 'Cancelled';
    }
  }
}

class Delivery {
  final String id;
  final String requesterId;
  final String? runnerId;
  final String pickupLocation;
  final String dropoffLocation;
  final String itemSize; // S, M, L
  final double urgency;
  final int creditCost;
  final DeliveryStatus status;
  final int matchAttempt;
  final String? notes;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? confirmedAt;
  final String? deliveryPin;
  final double? runnerLat;
  final double? runnerLng;

  const Delivery({
    required this.id,
    required this.requesterId,
    this.runnerId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.itemSize,
    required this.urgency,
    required this.creditCost,
    required this.status,
    required this.matchAttempt,
    this.notes,
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.confirmedAt,
    this.deliveryPin,
    this.runnerLat,
    this.runnerLng,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      runnerId: json['runner_id'] as String?,
      pickupLocation: json['pickup_location'] as String,
      dropoffLocation: json['dropoff_location'] as String,
      itemSize: json['item_size'] as String,
      urgency: (json['urgency'] as num?)?.toDouble() ?? 1.0,
      creditCost: json['credit_cost'] as int,
      status: DeliveryStatus.fromString(json['status'] as String),
      matchAttempt: json['match_attempt'] as int? ?? 0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      pickedUpAt: json['picked_up_at'] != null
          ? DateTime.parse(json['picked_up_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      deliveryPin: json['delivery_pin'] as String?,
      runnerLat: (json['runner_lat'] as num?)?.toDouble(),
      runnerLng: (json['runner_lng'] as num?)?.toDouble(),
    );
  }

  int get creditBase {
    switch (itemSize) {
      case 'S': return 10;
      case 'M': return 18;
      case 'L': return 28;
      default: return 10;
    }
  }

  double get progressFraction {
    switch (status) {
      case DeliveryStatus.pending:   return 0.05;
      case DeliveryStatus.matching:  return 0.1;
      case DeliveryStatus.accepted:  return 0.25;
      case DeliveryStatus.pickedUp:  return 0.5;
      case DeliveryStatus.enRoute:   return 0.75;
      case DeliveryStatus.delivered: return 1.0;
      case DeliveryStatus.cancelled: return 0.0;
    }
  }

  int get etaMinutes {
    switch (status) {
      case DeliveryStatus.accepted:  return 10;
      case DeliveryStatus.pickedUp:  return 7;
      case DeliveryStatus.enRoute:   return 4;
      case DeliveryStatus.delivered: return 0;
      default:                       return 12;
    }
  }

  static int computeCost(String size, double urgency) {
    final base = size == 'S' ? 10 : size == 'M' ? 18 : 28;
    return (base * urgency).round();
  }
}
