/// Riverpod providers exposing the Drift database and repository instances.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/database/app_database.dart';
import 'package:byteflow/repositories/usage_repository.dart';

/// Provides the singleton [AppDatabase] instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
});

/// Provides the singleton [UsageRepository] managing batched persistence.
final usageRepositoryProvider = Provider<UsageRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final repo = UsageRepository(db);
  ref.onDispose(() {
    repo.dispose();
  });
  return repo;
});
