# ByteFlow: Project Tree Structure

```text
byteflow/
├── android/
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/
│   │       └── main/
│   │           ├── AndroidManifest.xml
│   │           ├── kotlin/
│   │           │   └── com/
│   │           │       └── byteflow/
│   │           │           └── network/
│   │           │               ├── MainActivity.kt
│   │           │               ├── plugins/
│   │           │               │   ├── NetworkStatsPlugin.kt      # TrafficStats & ConnectivityManager
│   │           │               │   ├── AppUsagePlugin.kt          # NetworkStatsManager & UID mapping (Coroutines)
│   │           │               │   ├── SimManagerPlugin.kt        # SubscriptionManager & SIM slot info
│   │           │               │   └── ShizukuPlugin.kt           # Shizuku IPC for privileged SIM stats
│   │           │               ├── services/
│   │           │               │   ├── NetworkSpeedService.kt     # Foreground Service + Canvas status-bar icon
│   │           │               │   └── ScreenStateReceiver.kt     # Throttles polling when screen is off
│   │           │               ├── receivers/
│   │           │               │   └── BootReceiver.kt            # Handles BOOT_COMPLETED auto-start
│   │           │               └── widgets/
│   │           │                   ├── SpeedWidgetProvider.kt     # AppWidget: Real-time speed
│   │           │                   ├── UsageWidgetProvider.kt     # AppWidget: Today's usage
│   │           │                   └── PlanWidgetProvider.kt      # AppWidget: Data plan progress
│   │           └── res/
│   │               ├── drawable/
│   │               │   ├── ic_stat_speed.xml                      # Fallback notification icon
│   │               │   └── ic_launcher_foreground.xml
│   │               ├── layout/
│   │               │   ├── widget_speed.xml                       # AppWidget remote views
│   │               │   ├── widget_usage.xml
│   │               │   └── widget_plan.xml
│   │               └── xml/
│   │                   ├── speed_widget_info.xml                  # AppWidgetProviderInfo
│   │                   ├── usage_widget_info.xml
│   │                   └── plan_widget_info.xml
│   └── build.gradle.kts
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart                                               # App widget & Riverpod scope
│   │   ├── router.dart                                            # GoRouter StatefulShellRoute
│   │   └── theme.dart                                             # Material 3 dynamic color theme
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   ├── utils/
│   │   │   ├── formatters.dart                                    # Byte & speed formatting (KB/s, MB/s)
│   │   │   └── time_utils.dart                                    # Date ranges & billing cycle calculations
│   │   └── extensions/
│   ├── models/
│   │   ├── network_speed.dart                                     # Rx/Tx speed, combined, timestamp
│   │   ├── network_info.dart                                      # ConnectionType (WiFi, Mobile, etc.), SSID, metered
│   │   ├── app_network_usage.dart                                 # UID, package, label, wifi/mobile usage
│   │   ├── data_plan_model.dart                                   # Plan name, limit, cycle, simSlot
│   │   └── sim_card_info.dart                                     # Slot index, carrier name, active data SIM
│   ├── services/
│   │   ├── native_bridge.dart                                     # MethodChannel & EventChannel wrapper
│   │   ├── network_service.dart                                   # High-level stream controller
│   │   └── widget_sync_service.dart                               # home_widget bridge to AppWidgets
│   ├── database/
│   │   ├── app_database.dart                                      # Drift database definition
│   │   ├── tables/
│   │   │   ├── usage_snapshots.dart                               # Time-series usage aggregates
│   │   │   └── data_plans_table.dart                              # Persistent plans
│   │   └── daos/
│   │       ├── usage_dao.dart
│   │       └── plans_dao.dart
│   ├── providers/
│   │   ├── speed_provider.dart                                    # Real-time speed stream provider
│   │   ├── network_info_provider.dart                             # Active network state provider
│   │   ├── usage_history_provider.dart                            # Historical chart data provider
│   │   ├── app_usage_provider.dart                                # Per-app usage & sorting state
│   │   ├── data_plan_provider.dart                                # Plans & remaining daily allowance
│   │   └── settings_provider.dart                                 # SharedPreferences state notifier
│   ├── screens/
│   │   ├── shell_scaffold.dart                                    # Material 3 NavigationBar container
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart                              # Speed meters, connection state, today stats
│   │   ├── history/
│   │   │   └── history_screen.dart                                # fl_chart daily/weekly/monthly charts
│   │   ├── apps/
│   │   │   ├── apps_screen.dart                                   # Per-app usage list & sort
│   │   │   └── widgets/
│   │   │       └── app_usage_item.dart
│   │   ├── data_plans/
│   │   │   ├── data_plans_screen.dart                             # Multi-SIM plan progress & creation
│   │   │   └── plan_dialog.dart
│   │   └── settings/
│   │       ├── settings_screen.dart                               # Preferences, status bar toggles, about
│   │       └── permissions_screen.dart                            # Usage access & notification status
│   └── widgets/
│       ├── speed_card.dart                                        # Real-time animated speed card
│       ├── connection_badge.dart                                  # Wi-Fi SSID / Mobile badge
│       ├── usage_summary_card.dart                                # Today's downloaded / uploaded card
│       └── period_selector.dart                                   # Chips for Day / Week / Month
├── test/
│   ├── unit/
│   │   ├── formatters_test.dart                                   # Speed and byte unit conversion tests
│   │   └── data_plan_test.dart                                    # Allowance & billing cycle calculation tests
│   └── widget/
│       └── speed_card_test.dart
├── docs/
│   ├── byteflow-plan.md                                           # Comprehensive technical architecture
│   ├── phases.md                                                  # 10-phase execution checklist
│   ├── treeview.md                                                # Project file tree
│   └── packages.md                                                # Verified dependencies & libraries
├── pubspec.yaml
└── README.md
```
