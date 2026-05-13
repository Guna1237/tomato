import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase/supabase_client.dart';

class AdminStats {
  final int activeDeliveries;
  final int runnersOnline;
  final int pendingVerifications;
  final int openDisputes;

  const AdminStats({
    required this.activeDeliveries,
    required this.runnersOnline,
    required this.pendingVerifications,
    required this.openDisputes,
  });
}

class AdminQueueEntry {
  final String id;
  final String title;
  final String subtitle;
  final String status;
  final bool isUrgent;

  const AdminQueueEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isUrgent,
  });
}

final adminStatsProvider = StreamProvider<AdminStats>((ref) async* {
  Future<AdminStats> fetch() async {
    final results = await Future.wait([
      supabase
          .from('deliveries')
          .select('id')
          .inFilter('status', ['pending', 'matching', 'accepted', 'picked_up', 'en_route']),
      supabase
          .from('profiles')
          .select('id')
          .eq('runner_active', true),
      supabase
          .from('profiles')
          .select('id')
          .inFilter('face_status', ['pending', 'flagged']),
    ]);
    return AdminStats(
      activeDeliveries: (results[0] as List).length,
      runnersOnline: (results[1] as List).length,
      pendingVerifications: (results[2] as List).length,
      openDisputes: 0,
    );
  }

  yield await fetch();

  // Refresh every 15 seconds for live feel
  await for (final _ in Stream.periodic(const Duration(seconds: 15))) {
    yield await fetch();
  }
});

final adminQueueProvider = FutureProvider<List<AdminQueueEntry>>((ref) async {
  final queue = <AdminQueueEntry>[];

  final pendingProfiles = await supabase
      .from('profiles')
      .select('id, display_name, face_status, created_at')
      .inFilter('face_status', ['pending', 'flagged'])
      .order('created_at', ascending: false)
      .limit(3);

  for (final p in pendingProfiles) {
    final name = p['display_name'] as String;
    final faceStatus = p['face_status'] as String;
    queue.add(AdminQueueEntry(
      id: p['id'] as String,
      title: 'Identity review: $name',
      subtitle: faceStatus == 'flagged'
          ? 'Low confidence score - manual check needed'
          : 'New user photo awaiting approval',
      status: faceStatus == 'flagged' ? 'Urgent' : 'Review',
      isUrgent: faceStatus == 'flagged',
    ));
  }

  final staleMatching = await supabase
      .from('deliveries')
      .select('id, pickup_location, dropoff_location, created_at')
      .eq('status', 'matching')
      .lt('created_at',
          DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String())
      .limit(2);

  for (final d in staleMatching) {
    final pickup = d['pickup_location'] as String;
    final dropoff = d['dropoff_location'] as String;
    final created = DateTime.parse(d['created_at'] as String);
    final elapsed = DateTime.now().difference(created).inMinutes;
    queue.add(AdminQueueEntry(
      id: d['id'] as String,
      title: 'No runner: $pickup to $dropoff',
      subtitle: 'Matching for ${elapsed}m with no interest',
      status: 'Warn',
      isUrgent: true,
    ));
  }

  return queue;
});
