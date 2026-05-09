import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:supabase_flutter/supabase_flutter.dart' show Supabase, SupabaseClient, AuthState, AuthChangeEvent, OtpType;

SupabaseClient get supabase => Supabase.instance.client;
