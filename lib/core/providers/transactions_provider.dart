import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase/supabase_client.dart';
import '../../data/models/credit_transaction.dart';
import 'auth_provider.dart';

final transactionsProvider = StreamProvider<List<CreditTransaction>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  return supabase
      .from('credit_transactions')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((rows) => rows
          .where((r) => r['from_user_id'] == userId || r['to_user_id'] == userId)
          .map((r) => CreditTransaction.fromJson(r))
          .toList());
});
