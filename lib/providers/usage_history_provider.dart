/// State management for historical network analytics, filtering, and chart representations.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/core/utils/time_utils.dart';
import 'package:byteflow/database/app_database.dart';
import 'package:byteflow/database/daos/usage_dao.dart';
import 'package:byteflow/providers/database_provider.dart';

/// Available time periods for historical queries.
enum HistoryPeriod {
  /// Today (hourly granularity).
  today('Today'),

  /// Yesterday (hourly granularity).
  yesterday('Yesterday'),

  /// Past 7 days (daily granularity).
  last7Days('7 Days'),

  /// Past 30 days (daily granularity).
  last30Days('30 Days'),

  /// Current calendar month (daily granularity).
  currentMonth('This Month'),

  /// Previous calendar month (daily granularity).
  previousMonth('Last Month'),

  /// User-specified custom date range.
  custom('Custom');

  const HistoryPeriod(this.label);

  /// User-visible label.
  final String label;
}

/// Metrics available for filtering and charting.
enum HistoryMetric {
  /// Combined download and upload traffic.
  total('Total'),

  /// Downloaded traffic only.
  download('Download'),

  /// Uploaded traffic only.
  upload('Upload'),

  /// Wi-Fi interface traffic only.
  wifi('Wi-Fi'),

  /// Mobile cellular traffic only.
  mobile('Mobile');

  const HistoryMetric(this.label);

  /// User-visible label.
  final String label;
}

/// Supported visualization types for history metrics.
enum ChartViewType {
  /// Vertical bar chart.
  bar,

  /// Continuous spline line chart.
  line,
}

/// Filter state defining time range and metrics for historical analysis.
@immutable
class HistoryFilterState {
  /// Creates an immutable [HistoryFilterState].
  const HistoryFilterState({
    this.period = HistoryPeriod.last7Days,
    this.metric = HistoryMetric.total,
    this.chartViewType = ChartViewType.bar,
    this.customRange,
  });

  /// Selected time period.
  final HistoryPeriod period;

  /// Selected metric category to display.
  final HistoryMetric metric;

  /// Active chart display type.
  final ChartViewType chartViewType;

  /// Custom date range when [period] is [HistoryPeriod.custom].
  final DateTimeRange? customRange;

  /// Resolves the actual start and end [DateTime] for the active filter.
  (DateTime start, DateTime end) resolveDateRange([DateTime? now]) {
    final current = now ?? DateTime.now();
    return switch (period) {
      HistoryPeriod.today => TimeUtils.todayRange(current),
      HistoryPeriod.yesterday => TimeUtils.yesterdayRange(current),
      HistoryPeriod.last7Days => TimeUtils.last7DaysRange(current),
      HistoryPeriod.last30Days => TimeUtils.last30DaysRange(current),
      HistoryPeriod.currentMonth => TimeUtils.currentMonthRange(current),
      HistoryPeriod.previousMonth => TimeUtils.previousMonthRange(current),
      HistoryPeriod.custom => (
          customRange?.start ?? TimeUtils.startOfDay(current),
          customRange?.end ?? TimeUtils.endOfDay(current),
        ),
    };
  }

  /// Creates a copy with optionally replaced fields.
  HistoryFilterState copyWith({
    HistoryPeriod? period,
    HistoryMetric? metric,
    ChartViewType? chartViewType,
    DateTimeRange? customRange,
  }) {
    return HistoryFilterState(
      period: period ?? this.period,
      metric: metric ?? this.metric,
      chartViewType: chartViewType ?? this.chartViewType,
      customRange: customRange ?? this.customRange,
    );
  }
}

/// Single bucketized data point for chart display.
@immutable
class HistoryDataPoint {
  /// Creates a [HistoryDataPoint] container.
  const HistoryDataPoint({
    required this.label,
    required this.timestamp,
    required this.value,
    required this.downloadBytes,
    required this.uploadBytes,
    required this.wifiBytes,
    required this.mobileBytes,
  });

  /// Readable axis label (e.g., "14:00" or "Sep 5").
  final String label;

  /// Represented start timestamp for this bucket.
  final DateTime timestamp;

  /// Filtered metric value (in bytes) to display on the chart.
  final int value;

  /// Downloaded bytes in this bucket.
  final int downloadBytes;

  /// Uploaded bytes in this bucket.
  final int uploadBytes;

  /// Wi-Fi bytes in this bucket.
  final int wifiBytes;

  /// Mobile cellular bytes in this bucket.
  final int mobileBytes;

  /// Combined total bytes (download + upload).
  int get totalBytes => downloadBytes + uploadBytes;
}

/// Comprehensive historical report grouping bucket points and analytical totals.
@immutable
class HistoryReport {
  /// Creates an immutable [HistoryReport].
  const HistoryReport({
    required this.dataPoints,
    required this.aggregate,
    required this.averageBytes,
    required this.peakPoint,
    required this.isHourly,
  });

  /// Empty report baseline.
  factory HistoryReport.empty({bool isHourly = false}) => HistoryReport(
        dataPoints: const [],
        aggregate: const UsageAggregate.zero(),
        averageBytes: 0,
        peakPoint: null,
        isHourly: isHourly,
      );

  /// Chronological sequence of bucketized points for chart rendering.
  final List<HistoryDataPoint> dataPoints;

  /// Aggregated totals across the entire queried period.
  final UsageAggregate aggregate;

  /// Average bytes per bucket (per hour or per day).
  final double averageBytes;

  /// Data point representing the highest usage within the period.
  final HistoryDataPoint? peakPoint;

  /// Whether the data points represent hourly buckets (single-day view).
  final bool isHourly;
}

/// Manages active historical filter parameters.
class HistoryFilterNotifier extends StateNotifier<HistoryFilterState> {
  /// Initializes with default filter settings.
  HistoryFilterNotifier() : super(const HistoryFilterState());

  /// Sets the active time period.
  void setPeriod(HistoryPeriod period, {DateTimeRange? customRange}) {
    state = state.copyWith(period: period, customRange: customRange);
  }

  /// Sets the active metric filter.
  void setMetric(HistoryMetric metric) {
    state = state.copyWith(metric: metric);
  }

  /// Switches between bar chart and line chart visualizer.
  void setChartViewType(ChartViewType chartViewType) {
    state = state.copyWith(chartViewType: chartViewType);
  }
}

/// Provides the active [HistoryFilterState].
final historyFilterProvider =
    StateNotifierProvider<HistoryFilterNotifier, HistoryFilterState>((ref) {
  return HistoryFilterNotifier();
});

/// Streams bucketized data and analytics corresponding to [historyFilterProvider].
final historyReportProvider = StreamProvider<HistoryReport>((ref) {
  final repository = ref.watch(usageRepositoryProvider);
  final filter = ref.watch(historyFilterProvider);
  final (start, end) = filter.resolveDateRange();

  return repository.watchSnapshotsForRange(start, end).map((snapshots) {
    final isHourly = (filter.period == HistoryPeriod.today ||
        filter.period == HistoryPeriod.yesterday ||
        (filter.period == HistoryPeriod.custom &&
            end.difference(start).inDays <= 1));

    if (isHourly) {
      return _buildHourlyReport(start, end, snapshots, filter.metric);
    } else {
      return _buildDailyReport(start, end, snapshots, filter.metric);
    }
  });
});

HistoryReport _buildHourlyReport(
  DateTime start,
  DateTime end,
  List<UsageSnapshot> snapshots,
  HistoryMetric metric,
) {
  final points = <HistoryDataPoint>[];
  int totalDownload = 0;
  int totalUpload = 0;
  int totalWifi = 0;
  int totalMobile = 0;

  for (int hour = 0; hour < 24; hour++) {
    final bucketTime = DateTime(start.year, start.month, start.day, hour);
    final hourSnapshots = snapshots.where((s) => s.timestamp.hour == hour);

    int dl = 0;
    int ul = 0;
    int wf = 0;
    int mb = 0;

    for (final s in hourSnapshots) {
      dl += s.downloadBytes;
      ul += s.uploadBytes;
      wf += s.wifiBytes;
      mb += s.mobileBytes;
    }

    totalDownload += dl;
    totalUpload += ul;
    totalWifi += wf;
    totalMobile += mb;

    final value = switch (metric) {
      HistoryMetric.total => dl + ul,
      HistoryMetric.download => dl,
      HistoryMetric.upload => ul,
      HistoryMetric.wifi => wf,
      HistoryMetric.mobile => mb,
    };

    points.add(
      HistoryDataPoint(
        label: '${hour.toString().padLeft(2, '0')}:00',
        timestamp: bucketTime,
        value: value,
        downloadBytes: dl,
        uploadBytes: ul,
        wifiBytes: wf,
        mobileBytes: mb,
      ),
    );
  }

  final aggregate = UsageAggregate(
    downloadBytes: totalDownload,
    uploadBytes: totalUpload,
    wifiBytes: totalWifi,
    mobileBytes: totalMobile,
  );

  HistoryDataPoint? peak;
  for (final p in points) {
    if (peak == null || p.value > peak.value) {
      if (p.value > 0) {
        peak = p;
      }
    }
  }

  final average = totalDownload + totalUpload > 0
      ? (totalDownload + totalUpload) / 24.0
      : 0.0;

  return HistoryReport(
    dataPoints: points,
    aggregate: aggregate,
    averageBytes: average,
    peakPoint: peak,
    isHourly: true,
  );
}

HistoryReport _buildDailyReport(
  DateTime start,
  DateTime end,
  List<UsageSnapshot> snapshots,
  HistoryMetric metric,
) {
  final points = <HistoryDataPoint>[];
  int totalDownload = 0;
  int totalUpload = 0;
  int totalWifi = 0;
  int totalMobile = 0;

  final totalDays = end.difference(start).inDays + 1;
  for (int dayOffset = 0; dayOffset < totalDays; dayOffset++) {
    final currentDay = start.add(Duration(days: dayOffset));
    final daySnapshots = snapshots.where((s) => TimeUtils.isSameDay(s.timestamp, currentDay));

    int dl = 0;
    int ul = 0;
    int wf = 0;
    int mb = 0;

    for (final s in daySnapshots) {
      dl += s.downloadBytes;
      ul += s.uploadBytes;
      wf += s.wifiBytes;
      mb += s.mobileBytes;
    }

    totalDownload += dl;
    totalUpload += ul;
    totalWifi += wf;
    totalMobile += mb;

    final value = switch (metric) {
      HistoryMetric.total => dl + ul,
      HistoryMetric.download => dl,
      HistoryMetric.upload => ul,
      HistoryMetric.wifi => wf,
      HistoryMetric.mobile => mb,
    };

    points.add(
      HistoryDataPoint(
        label: TimeUtils.formatShortDate(currentDay),
        timestamp: currentDay,
        value: value,
        downloadBytes: dl,
        uploadBytes: ul,
        wifiBytes: wf,
        mobileBytes: mb,
      ),
    );
  }

  final aggregate = UsageAggregate(
    downloadBytes: totalDownload,
    uploadBytes: totalUpload,
    wifiBytes: totalWifi,
    mobileBytes: totalMobile,
  );

  HistoryDataPoint? peak;
  for (final p in points) {
    if (peak == null || p.value > peak.value) {
      if (p.value > 0) {
        peak = p;
      }
    }
  }

  final average = totalDays > 0 && (totalDownload + totalUpload > 0)
      ? (totalDownload + totalUpload) / totalDays.toDouble()
      : 0.0;

  return HistoryReport(
    dataPoints: points,
    aggregate: aggregate,
    averageBytes: average,
    peakPoint: peak,
    isHourly: false,
  );
}
