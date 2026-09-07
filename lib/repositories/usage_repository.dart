/// Repository coordinating in-memory traffic accumulation and batched SQLite persistence.
library;

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:byteflow/core/utils/time_utils.dart';
import 'package:byteflow/database/app_database.dart';
import 'package:byteflow/database/daos/usage_dao.dart';
import 'package:byteflow/models/network_info.dart';

/// Repository managing network usage persistence with batched writes.
///
/// Instead of writing to disk on every 1 Hz speed tick, [UsageRepository] buffers
/// traffic deltas in-memory and flushes them to SQLite:
/// 1. Periodically every 15 minutes.
/// 2. On application pause, hide, or detach via [AppLifecycleListener].
/// 3. Upon explicit manual invocation of [flush].
class UsageRepository {
  /// Creates a [UsageRepository] backed by the provided [AppDatabase].
  UsageRepository(this._db, {bool enablePeriodicFlush = true}) {
    if (enablePeriodicFlush) {
      _initPeriodicFlush();
    }
  }

  final AppDatabase _db;

  int _pendingDownloadBytes = 0;
  int _pendingUploadBytes = 0;
  int _pendingWifiBytes = 0;
  int _pendingMobileBytes = 0;

  Timer? _flushTimer;
  AppLifecycleListener? _lifecycleListener;

  void _initPeriodicFlush() {
    // Periodic 15-minute flush interval
    _flushTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      flush();
    });

    // Lifecycle observer to flush when backgrounded or closed
    _lifecycleListener = AppLifecycleListener(
      onPause: () => flush(),
      onInactive: () => flush(),
      onHide: () => flush(),
      onDetach: () => flush(),
    );
  }

  /// Current buffered download bytes pending write to disk.
  int get pendingDownloadBytes => _pendingDownloadBytes;

  /// Current buffered upload bytes pending write to disk.
  int get pendingUploadBytes => _pendingUploadBytes;

  /// Current buffered Wi-Fi bytes pending write to disk.
  int get pendingWifiBytes => _pendingWifiBytes;

  /// Current buffered mobile cellular bytes pending write to disk.
  int get pendingMobileBytes => _pendingMobileBytes;

  /// Accumulates a discrete speed sample delta into the in-memory buffer.
  void recordDelta({
    required int rxDelta,
    required int txDelta,
    required NetworkType transport,
  }) {
    if (rxDelta <= 0 && txDelta <= 0) return;

    _pendingDownloadBytes += rxDelta;
    _pendingUploadBytes += txDelta;

    final totalDelta = rxDelta + txDelta;
    if (transport == NetworkType.wifi) {
      _pendingWifiBytes += totalDelta;
    } else if (transport == NetworkType.mobile) {
      _pendingMobileBytes += totalDelta;
    }
  }

  /// Flushes buffered usage deltas to the local SQLite database.
  Future<void> flush() async {
    final rx = _pendingDownloadBytes;
    final tx = _pendingUploadBytes;
    final wifi = _pendingWifiBytes;
    final mobile = _pendingMobileBytes;

    if (rx <= 0 && tx <= 0 && wifi <= 0 && mobile <= 0) {
      return;
    }

    // Reset pending counters before async database write to avoid race conditions
    _pendingDownloadBytes = 0;
    _pendingUploadBytes = 0;
    _pendingWifiBytes = 0;
    _pendingMobileBytes = 0;

    await _db.usageDao.insertSnapshot(
      UsageSnapshotsCompanion.insert(
        timestamp: DateTime.now(),
        downloadBytes: rx,
        uploadBytes: tx,
        wifiBytes: wifi,
        mobileBytes: mobile,
      ),
    );
  }

  /// Queries aggregated usage metrics within the range `[start, end]`.
  Future<UsageAggregate> getAggregateForRange(DateTime start, DateTime end) {
    return _db.usageDao.getAggregateBetween(start, end);
  }

  /// Queries all discrete snapshots within `[start, end]`, ordered chronologically.
  Future<List<UsageSnapshot>> getSnapshotsForRange(DateTime start, DateTime end) {
    return _db.usageDao.getSnapshotsBetween(start, end);
  }

  /// Streams snapshots within `[start, end]` in real time.
  Stream<List<UsageSnapshot>> watchSnapshotsForRange(
    DateTime start,
    DateTime end,
  ) {
    return _db.usageDao.watchSnapshotsBetween(start, end);
  }

  /// Returns aggregated totals for today's calendar day.
  Future<UsageAggregate> getTodayAggregate([DateTime? now]) {
    final (start, end) = TimeUtils.todayRange(now);
    return getAggregateForRange(start, end);
  }

  /// Returns aggregated totals for the current calendar month.
  Future<UsageAggregate> getCurrentMonthAggregate([DateTime? now]) {
    final (start, end) = TimeUtils.currentMonthRange(now);
    return getAggregateForRange(start, end);
  }

  /// Releases periodic timers and lifecycle listeners.
  void dispose() {
    _flushTimer?.cancel();
    _lifecycleListener?.dispose();
  }
}
