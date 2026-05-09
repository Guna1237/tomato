import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://omewltjiqmfndkfdzcae.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9tZXdsdGppcW1mbmRrZmR6Y2FlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNjUzNjgsImV4cCI6MjA5Mzc0MTM2OH0.T68etTrylRIm57TFupfI8UqN7DyjARg5iJEKuPt1nEs',
  );

  runApp(const ProviderScope(child: TomatoApp()));
}
