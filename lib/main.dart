import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'services/local_storage_service.dart';
import 'services/supabase_service.dart';
import 'providers/storage_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local persistence
  final localStorage = await LocalStorageService.init();

  // Initialize Supabase client
  await SupabaseService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(localStorage),
      ],
      child: const ArrowEscapeApp(),
    ),
  );
}
