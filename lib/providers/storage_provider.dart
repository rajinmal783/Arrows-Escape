import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';
import '../repositories/level_repository.dart';
import '../core/audio/audio_service.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService must be initialized in main()');
});

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final local = ref.watch(localStorageProvider);
  final supabase = ref.watch(supabaseServiceProvider);
  return SyncService(local, supabase);
});

final levelRepositoryProvider = Provider<LevelRepository>((ref) {
  return LevelRepository();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final storage = ref.watch(localStorageProvider);
  return AudioService(storage);
});
