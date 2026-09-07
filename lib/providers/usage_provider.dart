/// Providers and state models representing aggregated data usage summaries.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/models/network_info.dart';
import 'package:byteflow/providers/database_provider.dart';
import 'package:byteflow/providers/network_info_provider.dart';
import 'package:byteflow/providers/speed_provider.dart';
import 'package:byteflow/services/widget_sync_service.dart';

/// Immutable representation of cumulative data transfer volumes.
@immutable
class DataUsage {
  /// Creates an immutable [DataUsage] container.
  const DataUsage({
    required this.rxBytes,
    required this.txBytes,
    this.wifiBytes = 0,
    this.mobileBytes = 0,
  });

  /// Creates a zero usage baseline.
  factory DataUsage.zero() => const DataUsage(
        rxBytes: 0,
        txBytes: 0,
        wifiBytes: 0,
        mobileBytes: 0,
      );

  /// Received / downloaded volume in bytes.
  final int rxBytes;

  /// Transmitted / uploaded volume in bytes.
  final int txBytes;

  /// Wi-Fi volume in bytes.
  final int wifiBytes;

  /// Mobile cellular volume in bytes.
  final int mobileBytes;

  /// Combined aggregate volume in bytes.
  int get totalBytes => rxBytes + txBytes;

  /// Adds delta bytes to produce an updated [DataUsage] instance.
  DataUsage copyWithDelta({
    int rxDelta = 0,
    int txDelta = 0,
    int wifiDelta = 0,
    int mobileDelta = 0,
  }) {
    return DataUsage(
      rxBytes: rxBytes + rxDelta,
      txBytes: txBytes + txDelta,
      wifiBytes: wifiBytes + wifiDelta,
      mobileBytes: mobileBytes + mobileDelta,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataUsage &&
          runtimeType == other.runtimeType &&
          rxBytes == other.rxBytes &&
          txBytes == other.txBytes &&
          wifiBytes == other.wifiBytes &&
          mobileBytes == other.mobileBytes;

  @override
  int get hashCode => Object.hash(rxBytes, txBytes, wifiBytes, mobileBytes);
}

/// Aggregated usage state grouping session/today and monthly data.
@immutable
class UsageSummary {
  /// Creates a [UsageSummary] instance.
  const UsageSummary({
    required this.today,
    required this.currentMonth,
  });

  /// Default baseline with zero usage.
  factory UsageSummary.zero() => UsageSummary(
        today: DataUsage.zero(),
        currentMonth: DataUsage.zero(),
      );

  /// Data consumed during the current calendar day.
  final DataUsage today;

  /// Data consumed during the current calendar month.
  final DataUsage currentMonth;
}

/// State notifier managing session and daily usage counters with database backing.
class UsageNotifier extends StateNotifier<UsageSummary> {
  /// Initializes the notifier with baseline metrics.
  UsageNotifier(this.ref) : super(UsageSummary.zero()) {
    _init();
  }

  /// Provider reference used to listen to speed updates.
  final Ref ref;
  DateTime _lastWidgetSync = DateTime.fromMillisecondsSinceEpoch(0);

  void _init() {
    // 1. Restore historical baseline totals from Drift SQLite database
    final repository = ref.read(usageRepositoryProvider);
    Future.wait([
      repository.getTodayAggregate(),
      repository.getCurrentMonthAggregate(),
    ]).then((results) {
      final todayAgg = results[0];
      final monthAgg = results[1];

      state = UsageSummary(
        today: DataUsage(
          rxBytes: todayAgg.downloadBytes,
          txBytes: todayAgg.uploadBytes,
          wifiBytes: todayAgg.wifiBytes,
          mobileBytes: todayAgg.mobileBytes,
        ),
        currentMonth: DataUsage(
          rxBytes: monthAgg.downloadBytes,
          txBytes: monthAgg.uploadBytes,
          wifiBytes: monthAgg.wifiBytes,
          mobileBytes: monthAgg.mobileBytes,
        ),
      );

      // Sync baseline today usage to home-screen widget
      ref.read(widgetSyncServiceProvider).syncTodayUsageWidget(state);
    }).catchError((_) {
      // Keep baseline if database query fails
    });

    // 2. Incrementally accrue active speed samples into today's and month's counters,
    // and record into UsageRepository in-memory buffer for batched persistence
    ref.listen(speedStreamProvider, (previous, next) {
      final speed = next.value;
      if (speed != null &&
          (speed.rxBytesPerSecond > 0 || speed.txBytesPerSecond > 0)) {
        final rx = speed.rxBytesPerSecond;
        final tx = speed.txBytesPerSecond;
        final deltaTotal = rx + tx;

        final currentNetwork = ref.read(currentNetworkInfoProvider);
        final transport = currentNetwork.type;
        final wifiDelta = transport == NetworkType.wifi ? deltaTotal : 0;
        final mobileDelta = transport == NetworkType.mobile ? deltaTotal : 0;

        state = UsageSummary(
          today: state.today.copyWithDelta(
            rxDelta: rx,
            txDelta: tx,
            wifiDelta: wifiDelta,
            mobileDelta: mobileDelta,
          ),
          currentMonth: state.currentMonth.copyWithDelta(
            rxDelta: rx,
            txDelta: tx,
            wifiDelta: wifiDelta,
            mobileDelta: mobileDelta,
          ),
        );

        // Buffer in repository for periodic/lifecycle batched writes
        ref.read(usageRepositoryProvider).recordDelta(
              rxDelta: rx,
              txDelta: tx,
              transport: transport,
            );

        // Periodically sync today widget (throttled to 30s)
        final now = DateTime.now();
        if (now.difference(_lastWidgetSync).inSeconds >= 30) {
          _lastWidgetSync = now;
          ref.read(widgetSyncServiceProvider).syncTodayUsageWidget(state);
        }
      }
    });
  }
}

/// Provides the active [UsageSummary] containing today's and monthly usage.
final usageSummaryProvider =
    StateNotifierProvider<UsageNotifier, UsageSummary>((ref) {
  return UsageNotifier(ref);
});
