/// Core constant values and platform channel identifiers for ByteFlow.
library;

/// Constants defining method and event channel names for platform bridge communication.
abstract final class AppConstants {
  /// The MethodChannel identifier for invoke-based queries.
  static const String methodChannelName = 'com.byteflow.network/methods';

  /// The EventChannel identifier for real-time speed monitoring ticks.
  static const String speedEventChannelName = 'com.byteflow.network/speed';

  /// The EventChannel identifier for network status and connectivity changes.
  static const String networkEventChannelName = 'com.byteflow.network/network';

  /// Method call action name to query current network information.
  static const String methodGetNetworkInfo = 'getNetworkInfo';

  /// Method call action name to query cumulative traffic stats.
  static const String methodGetTrafficStats = 'getTrafficStats';

  /// The MethodChannel identifier for per-app network usage queries.
  static const String appUsageMethodChannelName = 'com.byteflow.network/app_usage';

  /// Method call action name to check package usage stats permission.
  static const String methodHasUsagePermission = 'hasUsagePermission';

  /// Method call action name to open Android usage access settings.
  static const String methodOpenUsageSettings = 'openUsageSettings';

  /// Method call action name to query per-app usage list.
  static const String methodGetAppUsage = 'getAppUsage';

  /// Method call action name to fetch an application icon PNG byte array.
  static const String methodGetAppIcon = 'getAppIcon';

  /// The MethodChannel identifier for multi-SIM queries.
  static const String simMethodChannelName = 'com.byteflow.network/sim';

  /// Method call action name to query active SIM subscriptions.
  static const String methodGetSimCards = 'getSimCards';

  /// Method call action name to check READ_PHONE_STATE permission.
  static const String methodHasPhonePermission = 'hasPhonePermission';

  /// Method call action name to query default data subscription ID.
  static const String methodGetDefaultDataSubId = 'getDefaultDataSubId';

  /// Method call action name to start foreground network monitoring service.
  static const String methodStartForegroundService = 'startForegroundService';

  /// Method call action name to stop foreground network monitoring service.
  static const String methodStopForegroundService = 'stopForegroundService';

  /// Method call action name to check if foreground service is running.
  static const String methodIsForegroundServiceRunning = 'isForegroundServiceRunning';

  /// Method call action name to update foreground service preferences.
  static const String methodUpdateServiceConfig = 'updateServiceConfig';

  /// Method call action name to retrieve foreground service preferences.
  static const String methodGetServiceConfig = 'getServiceConfig';

  /// Method call action name to configure the real-time speed polling interval.
  static const String methodSetPollingInterval = 'setPollingInterval';

  /// The MethodChannel identifier for Shizuku IPC privileged queries.
  static const String shizukuMethodChannelName = 'com.byteflow.network/shizuku';

  /// Method call action name to retrieve Shizuku IPC connection status.
  static const String methodGetShizukuStatus = 'getShizukuStatus';

  /// Method call action name to request Shizuku permission.
  static const String methodRequestShizukuPermission = 'requestShizukuPermission';

  /// Method call action name to get subscriber IDs for active SIMs.
  static const String methodGetSimSubscriberIds = 'getSimSubscriberIds';

  /// Method call action name to query per-SIM usage data.
  static const String methodQuerySimUsage = 'querySimUsage';

  // AppWidget Identifiers
  static const String speedWidgetName = 'SpeedWidgetProvider';
  static const String speedWidgetQualifiedName =
      'com.byteflow.network.widgets.SpeedWidgetProvider';

  static const String todayUsageWidgetName = 'TodayUsageWidgetProvider';
  static const String todayUsageWidgetQualifiedName =
      'com.byteflow.network.widgets.TodayUsageWidgetProvider';

  static const String dataPlanWidgetName = 'DataPlanWidgetProvider';
  static const String dataPlanWidgetQualifiedName =
      'com.byteflow.network.widgets.DataPlanWidgetProvider';

  // AppWidget Preference Keys
  static const String widgetSpeedRxKey = 'widget_speed_rx';
  static const String widgetSpeedTxKey = 'widget_speed_tx';
  static const String widgetSpeedTotalKey = 'widget_speed_total';
  static const String widgetSpeedNetworkKey = 'widget_speed_network';

  static const String widgetTodayTotalKey = 'widget_today_total';
  static const String widgetTodayRxKey = 'widget_today_rx';
  static const String widgetTodayTxKey = 'widget_today_tx';

  static const String widgetPlanNameKey = 'widget_plan_name';
  static const String widgetPlanRemainingKey = 'widget_plan_remaining';
  static const String widgetPlanPercentKey = 'widget_plan_percent';
  static const String widgetPlanDaysLeftKey = 'widget_plan_days_left';
}
