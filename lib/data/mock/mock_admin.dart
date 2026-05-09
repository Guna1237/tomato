import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AdminKpi {
  final String label;
  final String value;
  final String trend;
  final bool isPositive;
  final Color color;

  const AdminKpi({
    required this.label,
    required this.value,
    required this.trend,
    required this.isPositive,
    required this.color,
  });
}

class AdminQueueItem {
  final String id;
  final String title;
  final String subtitle;
  final String status;
  final bool isUrgent;
  final Color statusColor;

  const AdminQueueItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isUrgent,
    required this.statusColor,
  });
}

final mockAdminKpis = [
  const AdminKpi(
    label: 'Active deliveries',
    value: '47',
    trend: '+8',
    isPositive: true,
    color: AppColors.punchRed,
  ),
  const AdminKpi(
    label: 'Avg handoff',
    value: '9.4m',
    trend: '−1.2m',
    isPositive: true,
    color: AppColors.leaf500,
  ),
  const AdminKpi(
    label: 'Helpers online',
    value: '162',
    trend: '+24',
    isPositive: true,
    color: AppColors.ember500,
  ),
  const AdminKpi(
    label: 'Disputes',
    value: '0',
    trend: '0',
    isPositive: true,
    color: AppColors.lavenderGrey,
  ),
];

final mockAdminQueue = [
  const AdminQueueItem(
    id: 'q1',
    title: 'Emergency reassignment · #4471',
    subtitle: 'Original helper unreachable · 12 min',
    status: 'Urgent',
    isUrgent: true,
    statusColor: AppColors.ember500,
  ),
  const AdminQueueItem(
    id: 'q2',
    title: 'Gate congestion alert',
    subtitle: 'South gate · avg wait 14 min · 3 helpers',
    status: 'Warn',
    isUrgent: true,
    statusColor: AppColors.ember500,
  ),
  const AdminQueueItem(
    id: 'q3',
    title: 'Dispute · parcel #4392',
    subtitle: 'Receiver flagged late delivery',
    status: 'Review',
    isUrgent: false,
    statusColor: AppColors.lavenderGrey,
  ),
];

const mockAiSummary =
    'Strong evening: 412 deliveries, 0 disputes, average handoff down 1.2 min. South gate spiked 6:30-7 PM. H4 was the busiest destination.';
