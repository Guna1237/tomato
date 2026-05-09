import '../../core/supabase/supabase_client.dart';

class ProfileRepository {
  static Future<void> setRunnerMode(String userId, {required bool active}) async {
    await supabase.from('profiles').update({
      'is_runner': true,
      'runner_active': active,
    }).eq('id', userId);
  }

  static Future<void> setRunnerInactive(String userId) async {
    await supabase.from('profiles').update({
      'runner_active': false,
    }).eq('id', userId);
  }
}
