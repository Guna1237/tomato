import 'supabase_client.dart';

/// Returns a short-lived signed URL for a private storage path.
/// Accepts either a bare path ("uuid/profile.jpg") or an already-resolved
/// https URL (legacy data) — returns it unchanged in that case.
Future<String?> signedPhotoUrl(String? pathOrUrl,
    {int expiresIn = 3600}) async {
  if (pathOrUrl == null || pathOrUrl.isEmpty) return null;
  if (pathOrUrl.startsWith('http')) return pathOrUrl;
  final res = await supabase.storage
      .from('profile-photos')
      .createSignedUrl(pathOrUrl, expiresIn);
  return res;
}
