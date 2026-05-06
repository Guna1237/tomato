import 'package:flutter/material.dart';

class UserProfile {
  final String name;
  final String rollNumber;
  final String hostel;
  final String email;
  final int credits;
  final int streakDays;
  final double reliability;
  final int totalDeliveries;
  final int totalRequests;
  final bool isVerified;
  final bool isAdmin;
  final Color avatarColor;

  const UserProfile({
    required this.name,
    required this.rollNumber,
    required this.hostel,
    required this.email,
    required this.credits,
    required this.streakDays,
    required this.reliability,
    required this.totalDeliveries,
    required this.totalRequests,
    required this.isVerified,
    this.isAdmin = false,
    required this.avatarColor,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0].substring(0, 2).toUpperCase();
  }
}

const mockCurrentUser = UserProfile(
  name: 'Rahul Sharma',
  rollNumber: 'SE21UCSE001',
  hostel: 'H4 — North Wing',
  email: 'ra2211003010487@mahindrauniversity.edu.in',
  credits: 340,
  streakDays: 9,
  reliability: 0.98,
  totalDeliveries: 47,
  totalRequests: 23,
  isVerified: true,
  avatarColor: Color(0xFFA85A2C),
);
