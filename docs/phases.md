# ByteFlow: Exhaustive Development Roadmap

This checklist serves as the authoritative, phase-by-phase execution plan for ByteFlow. Each phase integrates specialized Flutter Agent Skills and addresses specific native Android constraints discovered through research.

---

## Phase 1: Project Identity & Flutter Architecture Foundation
*Skills: `flutter-apply-architecture-best-practices`, `dart-run-static-analysis`*
- [x] Refactor Android package identity in `android/app/build.gradle.kts` (`applicationId` = `com.byteflow.network`, `namespace` = `com.byteflow.network`).
- [x] Move `MainActivity.kt` to `android/app/src/main/kotlin/com/byteflow/network/MainActivity.kt`.
- [x] Add all required Android permissions in `AndroidManifest.xml` (INTERNET, ACCESS_NETWORK_STATE, ACCESS_WIFI_STATE, POST_NOTIFICATIONS, FOREGROUND_SERVICE, FOREGROUND_SERVICE_DATA_SYNC, FOREGROUND_SERVICE_SPECIAL_USE, RECEIVE_BOOT_COMPLETED, READ_PHONE_STATE).
- [x] Register `ShizukuProvider` and declare Foreground Service properties in `AndroidManifest.xml`.
- [x] Install core dependencies in `pubspec.yaml` (`flutter_riverpod`, `go_router`, `fl_chart`, `drift`, `sqlite3_flutter_libs`, `path_provider`, `shared_preferences`, `permission_handler`, `home_widget`, `package_info_plus`, `intl`).
- [x] Establish directory structure: `core/`, `models/`, `services/`, `repositories/`, `database/`, `providers/`, `screens/`, `widgets/`.
- [x] Verify clean build baseline: `flutter pub get` and `dart analyze`.

## Phase 2: Native Android Core & Real-Time Speed Bridge
*Skills: `dart-use-pattern-matching`, `dart-write-documentation`*
- [x] Create `NetworkStatsPlugin.kt` registering `MethodChannel` (`com.byteflow.network/methods`) and `EventChannel` (`com.byteflow.network/speed`).
- [x] Implement `TrafficStats` counter polling with delta calculation ($\Delta \text{bytes} / \Delta t$).
- [x] Handle counter reset and device reboot anomalies cleanly (prevent negative or spiked values).
- [x] Create `ConnectivityManager` callbacks to emit active network type (Wi-Fi, Mobile, Ethernet, VPN, None) and SSID where permitted.
- [x] Implement `NativeBridge` in Dart with typed streams and automatic unit conversion (KB/s, MB/s, GB/s).
- [x] Verify speed stream with zero fake or hardcoded values.

## Phase 3: Material 3 Dashboard & Navigation
*Skills: `flutter-setup-declarative-routing`, `flutter-build-responsive-layout`, `flutter-add-widget-preview`*
- [x] Configure `go_router` with `StatefulShellRoute` for bottom navigation (Dashboard, History, Apps, Plans, Settings).
- [x] Implement Material 3 Theme with dynamic color palette and dark/light modes.
- [x] Build `DashboardScreen` displaying:
  - Current download & upload speeds with directional indicators (↓ / ↑).
  - Connection status badge (Wi-Fi with SSID / Mobile carrier / Ethernet / VPN).
  - Metered vs. unmetered network indicator.
  - Today's download, upload, and total usage counters.
  - Current month's aggregated usage.
- [x] Optimize UI with targeted Riverpod `Consumer` widgets so 1 Hz speed updates don't trigger full scaffold rebuilds.
- [x] Ensure responsive layout on tablets and phones (`flutter-build-responsive-layout`).

## Phase 4: Local Database & Usage History (Data Layer)
*Skills: `dart-use-primary-constructors`, `dart-migrate-to-checks-package`*
- [x] Define Drift (SQLite) tables: `UsageSnapshots`, `DataPlans`, and `UserSettings`.
- [x] Configure `NativeDatabase` with `sqlite3_flutter_libs`.
- [x] Generate Drift database code using `build_runner`.
- [x] Implement batched persistence in `UsageRepository`: write usage snapshots periodically (every 15–30 min or on app pause), never on every 1 Hz speed tick.
- [x] Build `HistoryScreen` featuring interactive `fl_chart` bar and line charts:
  - Time ranges: Today, Yesterday, Last 7 days, Last 30 days, Current month, Previous month, Custom.
  - Filter toggles: Download, Upload, Total, Wi-Fi, Mobile.
  - Interactive touch tooltips showing date and bytes used.

## Phase 5: Per-App Network Usage
*Skills: `flutter-add-widget-test`, `dart-add-unit-test`*
- [x] Implement `AppUsagePlugin.kt` using `NetworkStatsManager.queryDetailsForUid` on **Kotlin Coroutines (`Dispatchers.IO`)**.
- [x] Map UIDs to app labels and package names using Android `PackageManager`.
- [x] Implement lightweight data transfer over MethodChannel (metadata map per app).
- [x] Implement lazy loading or disk caching for app icons to prevent `TransactionTooLargeException`.
- [x] Build `AppsScreen` with search bar and sort options (Total, Download, Upload, App Name).
- [x] Handle `PACKAGE_USAGE_STATS` permission:
  - Detect when permission is missing.
  - Show an informative permission explanation card with a direct button to open Android Usage Access Settings.
  - Never crash or display fabricated statistics when denied.

## Phase 6: Multi-SIM Support & Data Plans
*Skills: `dart-add-unit-test`, `flutter-add-widget-test`*
- [x] Implement `SimManagerPlugin.kt` querying `SubscriptionManager.getActiveSubscriptionInfoList()`.
- [x] Extract SIM slot index, carrier name, display name, and default data subscription.
- [x] Handle Single SIM, Dual SIM, SIM swaps, and disabled SIMs gracefully without crashes.
- [x] Implement `DataPlansScreen`:
  - Create, edit, and delete plans (Name, Data Limit, Billing Cycle start date, SIM association).
  - Progress bar showing % used, data remaining, and days remaining in billing cycle.
  - Calculate recommended daily allowance based on remaining days.
  - Configure warning threshold (%) and alert indicators.
- [x] Write unit tests for data plan calculation math (`dart-add-unit-test`).

## Phase 7: Background Monitoring & Native Status Bar Speed Indicator
*Skills: `dart-fix-runtime-errors`, `dart-run-static-analysis`*
- [x] Implement `NetworkSpeedService.kt` as an Android Foreground Service complying with Android 14/15 (`dataSync` / `specialUse`).
- [x] Implement dynamic Canvas-based status bar icon:
  - Render formatted speed string onto an in-memory 24×24 or 48×48 transparent Bitmap.
  - Call `NotificationCompat.Builder.setSmallIcon(IconCompat.createWithBitmap(bitmap))` to show speed in the status bar.
  - Use `IMPORTANCE_LOW` notification channel to eliminate chime/vibration interruptions.
- [x] Implement custom notification content with real-time download/upload speeds and connection type.
- [x] Implement `ACTION_SCREEN_OFF` receiver to throttle polling when screen is off, preserving battery.
- [x] Implement `BootReceiver.kt` for optional auto-start on `BOOT_COMPLETED`.

## Phase 8: Home-Screen Widgets & Shizuku Integration
*Skills: `flutter-build-responsive-layout`*
- [x] Implement native Android AppWidgets (`WidgetProvider.kt` & XML layouts):
  - Speed Widget: Real-time download/upload speed.
  - Today's Usage Widget: Total data consumed today.
  - Data Plan Widget: Progress bar and remaining allowance.
- [x] Integrate `home_widget` package to update widget data from Flutter and background service.
- [x] Implement `ShizukuPlugin.kt`:
  - Check `Shizuku.pingBinder()` and detect Shizuku server status.
  - Request Shizuku permission for `READ_PRIVILEGED_PHONE_STATE`.
  - When active, query `NetworkStatsManager` with specific `subscriberId` for independent multi-SIM data tracking (The Traffic Light pattern).
  - Gracefully fallback to aggregate device tracking when Shizuku is unavailable.

## Phase 9: Settings Screen, Permissions Management & Polishing
*Skills: `flutter-fix-layout-issues`, `flutter-add-widget-preview`*
- [x] Build `SettingsScreen`:
  - Appearance: Theme mode (System / Light / Dark).
  - Units: Speed units (Auto / KB/s / MB/s / GB/s) & Data units (Auto / MB / GB).
  - Monitoring: Polling interval slider, background service toggle, persistent notification toggle.
  - Status Bar: Speed indicator toggle, display mode (Download only / Upload only / Combined).
  - Startup: "Start on Boot" toggle.
- [x] Build dedicated Permissions Status Screen:
  - Usage Access (Required for per-app stats & historical data).
  - Notification Permission (`POST_NOTIFICATIONS`).
  - Battery Optimization exemption status.
  - Shizuku connection status.
- [x] Build About section: dynamic version, build number (`package_info_plus`), open-source licenses, credits.

## Phase 10: Testing, Documentation & Final Build
*Skills: `dart-run-static-analysis`, `flutter-add-integration-test`, `dart-write-documentation`*
- [x] Run `dart analyze` and fix all static analysis warnings (Zero issues found).
- [x] Expand unit and widget test suites (added `settings_screen_test.dart` and `permissions_screen_test.dart`).
- [-] Verify release build compilation on ARM64 (`flutter build apk` skipped per explicit user instruction).
- [x] Complete comprehensive `README.md` documenting architecture, permissions setup, Shizuku usage, and build instructions.

