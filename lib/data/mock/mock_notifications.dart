import 'package:flutter/material.dart';

enum NotificationTone { matched, enroute, delivered, emergency, credit, info }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final String day;
  final NotificationTone tone;
  final String avatarInitials;
  final Color avatarColor;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.day,
    required this.tone,
    required this.avatarInitials,
    required this.avatarColor,
    this.isRead = false,
  });
}

final mockNotifications = [
  const AppNotification(
    id: '1',
    title: 'Aryan picked up your parcel',
    body: 'He grabbed it from the main gate and is heading your way. About 6 minutes out.',
    time: '2:14 PM',
    day: 'Today',
    tone: NotificationTone.enroute,
    avatarInitials: 'AS',
    avatarColor: Color(0xFF2C5FA8),
  ),
  const AppNotification(
    id: '2',
    title: 'You earned 40 credits',
    body: 'Nice — Priya confirmed delivery. Your streak is now at 9 days.',
    time: '11:08 AM',
    day: 'Today',
    tone: NotificationTone.credit,
    avatarInitials: '₹',
    avatarColor: Color(0xFFEF233C),
  ),
  const AppNotification(
    id: '3',
    title: 'Someone needs urgent help',
    body: 'A parcel near the gate needs a runner in the next 8 minutes. Bonus: ₹60.',
    time: '9:42 AM',
    day: 'Today',
    tone: NotificationTone.emergency,
    avatarInitials: '!',
    avatarColor: Color(0xFFD90429),
    isRead: true,
  ),
  const AppNotification(
    id: '4',
    title: 'Delivery complete',
    body: 'Rahul confirmed your delivery. Credits have been transferred.',
    time: '4:30 PM',
    day: 'Yesterday',
    tone: NotificationTone.delivered,
    avatarInitials: 'RS',
    avatarColor: Color(0xFFA85A2C),
    isRead: true,
  ),
  const AppNotification(
    id: '5',
    title: 'Kiran is on the way',
    body: 'He matched your request and is heading to the gate now.',
    time: '1:15 PM',
    day: 'Yesterday',
    tone: NotificationTone.matched,
    avatarInitials: 'KR',
    avatarColor: Color(0xFF2CA868),
    isRead: true,
  ),
  const AppNotification(
    id: '6',
    title: 'Parcel arrived at H4',
    body: 'Your delivery from Monday reached your hostel. Thanks for using Tomato.',
    time: '6:50 PM',
    day: 'Monday',
    tone: NotificationTone.delivered,
    avatarInitials: 'TM',
    avatarColor: Color(0xFF8D99AE),
    isRead: true,
  ),
];
