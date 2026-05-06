import 'package:flutter/material.dart';

class Runner {
  final String name;
  final Color color;
  final double reliability;
  final int deliveries;
  final int etaMinutes;
  final double distanceKm;
  final bool isNearGate;
  final bool isVerified;
  final int rewardCredits;

  const Runner({
    required this.name,
    required this.color,
    required this.reliability,
    required this.deliveries,
    required this.etaMinutes,
    required this.distanceKm,
    required this.isNearGate,
    required this.isVerified,
    required this.rewardCredits,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.substring(0, 2).toUpperCase();
  }
}

final mockRunners = [
  const Runner(
    name: 'Priya Mehta',
    color: Color(0xFF8C2CA8),
    reliability: 0.97,
    deliveries: 62,
    etaMinutes: 4,
    distanceKm: 0.3,
    isNearGate: true,
    isVerified: true,
    rewardCredits: 45,
  ),
  const Runner(
    name: 'Aryan Singh',
    color: Color(0xFF2C5FA8),
    reliability: 0.94,
    deliveries: 38,
    etaMinutes: 7,
    distanceKm: 0.6,
    isNearGate: false,
    isVerified: true,
    rewardCredits: 40,
  ),
  const Runner(
    name: 'Kiran Reddy',
    color: Color(0xFF2CA868),
    reliability: 0.99,
    deliveries: 84,
    etaMinutes: 10,
    distanceKm: 0.9,
    isNearGate: false,
    isVerified: true,
    rewardCredits: 35,
  ),
  const Runner(
    name: 'Sneha Patel',
    color: Color(0xFFA86A2C),
    reliability: 0.91,
    deliveries: 21,
    etaMinutes: 13,
    distanceKm: 1.2,
    isNearGate: false,
    isVerified: true,
    rewardCredits: 30,
  ),
];

Runner get mockSelectedRunner => mockRunners.first;
