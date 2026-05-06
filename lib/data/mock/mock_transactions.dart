import 'package:flutter/material.dart';

enum TransactionType { earned, spent }

class Transaction {
  final String id;
  final String title;
  final String subtitle;
  final int amount;
  final TransactionType type;
  final String date;
  final bool isStreakBonus;
  final Color iconColor;

  const Transaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.date,
    this.isStreakBonus = false,
    required this.iconColor,
  });

  bool get isEarning => type == TransactionType.earned;
  String get displayAmount => isEarning ? '+₹$amount' : '-₹$amount';
}

final mockTransactions = [
  const Transaction(
    id: 't1',
    title: 'Delivery for Rahul',
    subtitle: 'H4 North Wing · 6 min',
    amount: 40,
    type: TransactionType.earned,
    date: 'Today, 2:14 PM',
    iconColor: Color(0xFF3FA85B),
  ),
  const Transaction(
    id: 't2',
    title: '9-day streak bonus',
    subtitle: 'Consistency reward',
    amount: 20,
    type: TransactionType.earned,
    date: 'Today, 11:00 AM',
    isStreakBonus: true,
    iconColor: Color(0xFFFF6A55),
  ),
  const Transaction(
    id: 't3',
    title: 'Parcel from Gate',
    subtitle: 'Requested · H3 East Block',
    amount: 35,
    type: TransactionType.spent,
    date: 'Yesterday, 4:30 PM',
    iconColor: Color(0xFF8D99AE),
  ),
  const Transaction(
    id: 't4',
    title: 'Emergency pickup',
    subtitle: 'Urgent · +bonus credits',
    amount: 60,
    type: TransactionType.earned,
    date: 'Mon, 9:42 AM',
    iconColor: Color(0xFFEF233C),
  ),
  const Transaction(
    id: 't5',
    title: 'Parcel from Gate',
    subtitle: 'Requested · H1 South Wing',
    amount: 30,
    type: TransactionType.spent,
    date: 'Mon, 1:15 PM',
    iconColor: Color(0xFF8D99AE),
  ),
];
