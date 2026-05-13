import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase/supabase_client.dart';
import '../../data/models/delivery_message.dart';

final messagesProvider = StreamProvider.family<List<DeliveryMessage>, String>(
  (ref, deliveryId) {
    final stream = supabase
        .from('delivery_messages')
        .stream(primaryKey: ['id'])
        .eq('delivery_id', deliveryId)
        .order('created_at', ascending: true);

    return stream.map((rows) =>
        rows.map((r) => DeliveryMessage.fromJson(r)).toList());
  },
);
