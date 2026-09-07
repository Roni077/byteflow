/// Service synchronizing Flutter data states with native Android AppWidgets.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:byteflow/core/constants/app_constants.dart';
import 'package:byteflow/core/utils/formatters.dart';
import 'package:byteflow/models/data_plan_usage_info.dart';
import 'package:byteflow/models/network_speed.dart';
import 'package:byteflow/providers/usage_provider.dart';

/// Bridges Flutter state updates into Android Home Screen AppWidgets via [HomeWidget].
class WidgetSyncService {
  /// Creates a [WidgetSyncService] instance.
  const WidgetSyncService();

  /// Updates the home screen Speed Widget with latest real-time network throughput.
  Future<bool> syncSpeedWidget({
    required NetworkSpeed speed,
    String networkName = 'Connected',
  }) async {
    try {
      final rxFormatted = '↓ ${Formatters.formatSpeed(speed.rxBytesPerSecond)}';
      final txFormatted = '↑ ${Formatters.formatSpeed(speed.txBytesPerSecond)}';
      final totalFormatted = Formatters.formatSpeed(speed.totalBytesPerSecond);

      await HomeWidget.saveWidgetData<String>(
        AppConstants.widgetSpeedRxKey,
        rxFormatted,
      );
      await HomeWidget.saveWidgetData<String>(
        AppConstants.widgetSpeedTxKey,
        txFormatted,
      );
      await HomeWidget.saveWidgetData<String>(
        AppConstants.widgetSpeedTotalKey,
        totalFormatted,
      );
      await HomeWidget.saveWidgetData<String>(
        AppConstants.widgetSpeedNetworkKey,
        networkName,
      );

      final updated = await HomeWidget.updateWidget(
        name: AppConstants.speedWidgetName,
        androidName: AppConstants.speedWidgetName,
        qualifiedAndroidName: AppConstants.speedWidgetQualifiedName,
      );
      return updated ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Updates the Today's Usage Widget with current daily cumulative metrics.
  Future<bool> syncTodayUsageWidget(UsageSummary summary) async {
    try {
      final totalFormatted = Formatters.formatBytes(summary.today.totalBytes);
      final rxFormatted = '↓ ${Formatters.formatBytes(summary.today.rxBytes)}';
      final txFormatted = '↑ ${Formatters.formatBytes(summary.today.txBytes)}';

      await HomeWidget.saveWidgetData<String>(
        AppConstants.widgetTodayTotalKey,
        totalFormatted,
      );
      await HomeWidget.saveWidgetData<String>(
        AppConstants.widgetTodayRxKey,
        rxFormatted,
      );
      await HomeWidget.saveWidgetData<String>(
        AppConstants.widgetTodayTxKey,
        txFormatted,
      );

      final updated = await HomeWidget.updateWidget(
        name: AppConstants.todayUsageWidgetName,
        androidName: AppConstants.todayUsageWidgetName,
        qualifiedAndroidName: AppConstants.todayUsageWidgetQualifiedName,
      );
      return updated ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Updates the Data Plan Widget with the primary or first active plan allowance.
  Future<bool> syncDataPlanWidget(List<DataPlanUsageInfo> plans) async {
    try {
      if (plans.isEmpty) {
        await HomeWidget.saveWidgetData<String>(
          AppConstants.widgetPlanNameKey,
          'No Active Plan',
        );
        await HomeWidget.saveWidgetData<String>(
          AppConstants.widgetPlanRemainingKey,
          '-- remaining',
        );
        await HomeWidget.saveWidgetData<int>(
          AppConstants.widgetPlanPercentKey,
          0,
        );
        await HomeWidget.saveWidgetData<String>(
          AppConstants.widgetPlanDaysLeftKey,
          '-- days left',
        );
      } else {
        // Prioritize active plan, or pick the first available
        final activePlan = plans.firstWhere(
          (p) => p.plan.isActive,
          orElse: () => plans.first,
        );

        final name = activePlan.plan.name;
        final remaining =
            '${Formatters.formatBytes(activePlan.remainingBytes)} left';
        final percent = activePlan.percentUsed.clamp(0.0, 100.0).round();
        final daysLeft = '${activePlan.daysRemaining}d left';

        await HomeWidget.saveWidgetData<String>(
          AppConstants.widgetPlanNameKey,
          name,
        );
        await HomeWidget.saveWidgetData<String>(
          AppConstants.widgetPlanRemainingKey,
          remaining,
        );
        await HomeWidget.saveWidgetData<int>(
          AppConstants.widgetPlanPercentKey,
          percent,
        );
        await HomeWidget.saveWidgetData<String>(
          AppConstants.widgetPlanDaysLeftKey,
          daysLeft,
        );
      }

      final updated = await HomeWidget.updateWidget(
        name: AppConstants.dataPlanWidgetName,
        androidName: AppConstants.dataPlanWidgetName,
        qualifiedAndroidName: AppConstants.dataPlanWidgetQualifiedName,
      );
      return updated ?? false;
    } catch (_) {
      return false;
    }
  }
}

/// Provides the singleton [WidgetSyncService] instance.
final widgetSyncServiceProvider = Provider<WidgetSyncService>((ref) {
  return const WidgetSyncService();
});
