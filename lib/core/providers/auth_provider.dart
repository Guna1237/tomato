import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../supabase/supabase_client.dart';
import '../../data/models/profile.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (state) => state.session != null,
    orElse: () => supabase.auth.currentSession != null,
  );
});

final currentUserProvider = FutureProvider<Profile?>((ref) async {
  ref.watch(authStateProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  final data = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  if (data == null) return null;
  return Profile.fromJson(data);
});

final currentUserIdProvider = Provider<String?>((ref) {
  return supabase.auth.currentUser?.id;
});
