import 'package:flutter/material.dart';

enum DeliveryStatus {
  requested,
  matched,
  pickedUp,
  inTransit,
  arrived,
  delivered,
}

extension DeliveryStatusX on DeliveryStatus {
  String get label {
    switch (this) {
      case DeliveryStatus.requested: return 'Requested';
      case DeliveryStatus.matched:   return 'Matched';
      case DeliveryStatus.pickedUp:  return 'Picked Up';
      case DeliveryStatus.inTransit: return 'En Route';
      case DeliveryStatus.arrived:   return 'Arrived';
      case DeliveryStatus.delivered: return 'Delivered';
    }
  }
}

class Delivery {
  final String id;
  final String runnerName;
  final Color runnerColor;
  final String pickupLocation;
  final String dropoffLocation;
  final DeliveryStatus status;
  final int creditCost;
  final int etaMinutes;
  final double progressFraction;
  final DateTime createdAt;

  const Delivery({
    required this.id,
    required this.runnerName,
    required this.runnerColor,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.status,
    required this.creditCost,
    required this.etaMinutes,
    required this.progressFraction,
    required this.createdAt,
  });

  String get runnerInitials {
    final parts = runnerName.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return runnerName.substring(0, 2).toUpperCase();
  }
}

final mockActiveDelivery = Delivery(
  id: '#4471',
  runnerName: 'Aryan Singh',
  runnerColor: const Color(0xFF2C5FA8),
  pickupLocation: 'Main Gate',
  dropoffLocation: 'H4 North Wing',
  status: DeliveryStatus.inTransit,
  creditCost: 40,
  etaMinutes: 6,
  progressFraction: 0.62,
  createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
);

final mockDeliveryHistory = [
  Delivery(
    id: '#4470',
    runnerName: 'Priya Mehta',
    runnerColor: const Color(0xFF8C2CA8),
    pickupLocation: 'Main Gate',
    dropoffLocation: 'H3 East Block',
    status: DeliveryStatus.delivered,
    creditCost: 35,
    etaMinutes: 0,
    progressFraction: 1.0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Delivery(
    id: '#4468',
    runnerName: 'Kiran Reddy',
    runnerColor: const Color(0xFF2CA868),
    pickupLocation: 'Main Gate',
    dropoffLocation: 'H1 South Wing',
    status: DeliveryStatus.delivered,
    creditCost: 30,
    etaMinutes: 0,
    progressFraction: 1.0,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];
