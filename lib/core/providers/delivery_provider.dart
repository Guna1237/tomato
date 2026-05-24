import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase/supabase_client.dart';
import '../../data/models/delivery.dart';
import '../../data/models/runner_interest.dart';
import 'auth_provider.dart';

// SupabaseStreamFilterBuilder only supports .eq() on a single column,
// so we merge two streams (requester side + runner side) via a StreamController.
final activeDeliveryProvider = StreamProvider<Delivery?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(null);

  Delivery? pickActive(List<Map<String, dynamic>> rows) {
    final active = rows.where((r) {
      final status = r['status'] as String;
      return status != 'delivered' && status != 'cancelled';
    });
    return active.isEmpty ? null : Delivery.fromJson(active.first);
  }

  final controller = StreamController<Delivery?>.broadcast();
  Delivery? latestRequester;
  Delivery? latestRunner;
  bool requesterReady = false;
  bool runnerReady = false;

  void emit() {
    // Don't emit null flash — wait until both streams have responded at least once
    if (!requesterReady || !runnerReady) return;
    if (!controller.isClosed) {
      controller.add(latestRequester ?? latestRunner);
    }
  }

  final subRequester = supabase
      .from('deliveries')
      .stream(primaryKey: ['id'])
      .eq('requester_id', userId)
      .listen((rows) {
        latestRequester = pickActive(rows);
        requesterReady = true;
        emit();
      }, onError: controller.addError);

  final subRunner = supabase
      .from('deliveries')
      .stream(primaryKey: ['id'])
      .eq('runner_id', userId)
      .listen((rows) {
        latestRunner = pickActive(rows);
        runnerReady = true;
        emit();
      }, onError: controller.addError);

  ref.onDispose(() {
    subRequester.cancel();
    subRunner.cancel();
    controller.close();
  });

  return controller.stream;
});

final deliveryByIdProvider = StreamProvider.family<Delivery?, String>((ref, deliveryId) {
  return supabase
      .from('deliveries')
      .stream(primaryKey: ['id'])
      .eq('id', deliveryId)
      .map((rows) => rows.isEmpty ? null : Delivery.fromJson(rows.first));
});

final openDeliveriesProvider = StreamProvider<List<Delivery>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  return supabase
      .from('deliveries')
      .stream(primaryKey: ['id'])
      .eq('status', 'matching')
      .map((rows) => rows
          .where((r) => r['requester_id'] != userId)
          .map((r) => Delivery.fromJson(r))
          .toList());
});

final runnerInterestsProvider = StreamProvider.family<List<RunnerInterest>, String>((ref, deliveryId) {
  return supabase
      .from('runner_interests')
      .stream(primaryKey: ['id'])
      .eq('delivery_id', deliveryId)
      .map((rows) => rows
          .where((r) => r['status'] == 'waiting')
          .map((r) => RunnerInterest.fromJson(r))
          .toList());
});

class DeliveryRepository {
  static Future<Delivery> createDelivery({
    required String requesterId,
    required String pickupLocation,
    required String dropoffLocation,
    required String itemSize,
    required double urgency,
    String? notes,
  }) async {
    final creditCost = Delivery.computeCost(itemSize, urgency);
    final pin = (1000 + Random().nextInt(9000)).toString();

    final data = await supabase.from('deliveries').insert({
      'requester_id': requesterId,
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'item_size': itemSize,
      'urgency': urgency,
      'credit_cost': creditCost,
      'status': 'pending',
      'delivery_pin': pin,
    }).select().single();

    // Deduct credits from requester
    final profile = await supabase
        .from('profiles')
        .select('tomato_credits')
        .eq('id', requesterId)
        .single();

    final currentCredits = profile['tomato_credits'] as int;
    await supabase
        .from('profiles')
        .update({'tomato_credits': currentCredits - creditCost})
        .eq('id', requesterId);

    // Record spend transaction
    await supabase.from('credit_transactions').insert({
      'from_user_id': requesterId,
      'to_user_id': requesterId,
      'amount': creditCost,
      'type': 'spend',
      'reference_id': data['id'],
    });

    return Delivery.fromJson(data);
  }

  static Future<void> expressInterest({
    required String deliveryId,
    required String runnerId,
  }) async {
    await supabase.from('runner_interests').insert({
      'delivery_id': deliveryId,
      'runner_id': runnerId,
    });
  }

  static Future<void> selectRunner({
    required String deliveryId,
    required String runnerId,
    required String interestId,
  }) async {
    await supabase.from('deliveries').update({
      'runner_id': runnerId,
      'status': 'accepted',
      'accepted_at': DateTime.now().toIso8601String(),
    }).eq('id', deliveryId);

    await supabase.from('runner_interests').update({'status': 'selected'}).eq('id', interestId);
    await supabase.from('runner_interests').update({'status': 'dismissed'})
        .eq('delivery_id', deliveryId)
        .neq('id', interestId);
  }

  static Future<void> updateStatus({
    required String deliveryId,
    required DeliveryStatus newStatus,
  }) async {
    final update = <String, dynamic>{'status': newStatus.toApiString()};
    switch (newStatus) {
      case DeliveryStatus.pickedUp:
        update['picked_up_at'] = DateTime.now().toIso8601String();
        break;
      case DeliveryStatus.enRoute:
        break;
      case DeliveryStatus.delivered:
        update['delivered_at'] = DateTime.now().toIso8601String();
        break;
      default:
        break;
    }
    await supabase.from('deliveries').update(update).eq('id', deliveryId);
  }

  static Future<void> acceptDelivery(String deliveryId) async {
    final runnerId = supabase.auth.currentUser!.id;
    await supabase.rpc('accept_delivery', params: {
      'p_delivery_id': deliveryId,
      'p_runner_id': runnerId,
    });
  }
}
