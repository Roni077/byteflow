# ByteFlow

[![Build APK & CI](https://github.com/Roni077/byteflow/actions/workflows/build-apk.yml/badge.svg)](https://github.com/Roni077/byteflow/actions/workflows/build-apk.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-API%2026%2B-3DDC84?logo=android)](https://developer.android.com)
[![Architecture](https://img.shields.io/badge/Architecture-Riverpod%20%2B%20Drift-FF6F00)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A modern, battery-efficient Android network monitoring application built with Flutter and Kotlin. ByteFlow delivers real-time throughput metrics, historical bandwidth analytics, per-app breakdown, multi-SIM data plan tracking, home-screen widgets, and an in-memory dynamic status-bar speed indicator—all engineered with privacy, zero tracking, and minimal battery overhead.

ByteFlow draws architectural inspiration from the open-source [Traffic Light](https://github.com/leekleak/traffic-light) project, implementing a dual-mode **Traffic Light Pattern** that operates completely without root while unlocking privileged per-SIM statistics via [Shizuku](https://shizuku.rikka.app/).

---

## Key Features

- **Real-Time Network Speed**: 1 Hz live download and upload metrics with directional transfer rates (↓ / ↑) computed from native Linux kernel network socket counters (`TrafficStats`).
- **Dynamic Status Bar Speed Indicator**: Native Android status bar speed display rendered in real-time onto an in-memory Canvas bitmap and delivered via an `IMPORTANCE_LOW` persistent notification—eliminating sound, vibration, and interruptions.
- **Material 3 UI & Responsive Layout**: Clean, expressive Material 3 design supporting system/light/dark modes, tablet dual-column layouts, and phone single-column views.
- **High-Performance Per-App Statistics**: Coroutine-powered queries across Android's `NetworkStatsManager` running asynchronously on `Dispatchers.IO`, with lazy app icon caching and protection against `TransactionTooLargeException`.
- **Multi-SIM Support & Data Plans**:
  - Automatic detection of Dual SIM subscriptions (carrier name, slot index, active data carrier).
  - Monthly and periodic billing cycles with remaining allowance and countdowns.
  - Recommended daily data allowances calculated dynamically from remaining days in cycle.
  - Configurable alert thresholds (e.g., warning at 80% capacity).
- **The Traffic Light Pattern (Shizuku Integration)**:
  - **Standard Mode (No Root / No Shizuku)**: Aggregates mobile data across the device using standard Android APIs.
  - **Elevated Mode (With Shizuku)**: Dynamically binds to Shizuku IPC to query `NetworkStatsManager` with specific `subscriberId`s (`READ_PRIVILEGED_PHONE_STATE`), enabling independent SIM slot data accounting on Android 10+.
  - **Graceful Fallback**: Dynamically detects Shizuku binder state with zero crashes when disconnected or uninstalled.
- **Home Screen Widgets**: Native Android AppWidgets (`SpeedWidgetProvider`, `TodayUsageWidgetProvider`, `DataPlanWidgetProvider`) powered by `home_widget` for quick at-a-glance monitoring.
- **Battery-First Data Layer**: Local SQLite database (via Drift ORM) with in-memory delta buffering and batched writes (every 15–30 minutes or upon app pause), eliminating flash wear and battery drain.
- **100% Local & Private**: No analytics, no telemetry, no network calls to external servers. All data remains exclusively on the local device.

---

## System Architecture

ByteFlow is engineered with strict separation of concerns across presentation, state management, local storage, and native platform services:

```
+-------------------------------------------------------------------------------+
|                                  FLUTTER UI                                   |
|  Material 3 • StatefulShellRoute (GoRouter) • Responsive Layouts (Phone/Tab)  |
|  [Dashboard]       [History]       [Apps]       [Data Plans]       [Settings] |
+-------------------------------------------------------------------------------+
                                       │
                                       ▼
+-------------------------------------------------------------------------------+
|                       APPLICATION & STATE LAYER (Riverpod)                    |
|  • speedStreamProvider            • usageHistoryProvider                      |
|  • networkInfoProvider            • appUsageProvider                          |
|  • dataPlansProvider              • foregroundServiceProvider                 |
|  • permissionsProvider            • userPreferencesProvider                   |
+-------------------------------------------------------------------------------+
                 │                                             │
                 ▼                                             ▼
+-----------------------------------+       +-----------------------------------+
|      LOCAL DATABASE (Drift)       |       |          PLATFORM BRIDGE          |
|  SQLite ORM (sqlite3_flutter_libs)|       |  MethodChannel / EventChannel     |
|  • UsageSnapshots (15-min batch)  |       +-----------------------------------+
|  • DataPlans Table                |                          │
|  • UserSettings Key-Value Table   |                          ▼
+-----------------------------------+       +-----------------------------------+
                                            |        ANDROID KOTLIN CORE        |
                                            |  • NetworkStatsPlugin             |
                                            |  • AppUsagePlugin (Coroutines)    |
                                            |  • SimManagerPlugin               |
                                            |  • ShizukuPlugin (IPC Binder)     |
                                            |  • NetworkSpeedService (FG Svc)   |
                                            |  • SpeedIconRenderer (Canvas)     |
                                            |  • AppWidget Providers            |
                                            |  • BootReceiver                   |
                                            +-----------------------------------+
```

### Component Breakdown

1. **Presentation Layer (`lib/screens/`, `lib/widgets/`)**:
   - Declarative navigation managed by `GoRouter` using `StatefulShellRoute` with an indexed bottom navigation bar.
   - Targeted Riverpod `Consumer` widgets ensure frequent 1 Hz speed updates isolate rebuilds solely to numerical widgets rather than re-rendering entire screen trees.
2. **Application & State Layer (`lib/providers/`)**:
   - Exposes reactive `AsyncNotifier` and `StreamProvider` controllers for speeds, data plans, per-app metrics, and hardware state.
3. **Data Layer (`lib/database/`, `lib/repositories/`)**:
   - Backed by Drift and `sqlite3_flutter_libs`.
   - `UsageRepository` collects traffic increments in memory and flushes in batches every 15 minutes, or whenever Android triggers `AppLifecycleListener.onPause`.
4. **Platform Bridge (`lib/services/native_bridge.dart`)**:
   - Coordinates two-way communication between Flutter and Android via typed channels (`MethodChannel` for commands, `EventChannel` for continuous streams).
5. **Android Core (`android/app/src/main/kotlin/com/byteflow/network/`)**:
   - **`NetworkStatsPlugin.kt`**: Reads raw bytes from `TrafficStats`, manages reboot anomalies, and monitors active connection interfaces with `ConnectivityManager`.
   - **`NetworkSpeedService.kt`**: Android Foreground Service (`dataSync` / `specialUse`) running persistent background loops. Uses `SpeedIconRenderer.kt` to draw crisp status-bar speed numbers on transparent 24×24 / 48×48 Canvas bitmaps.
   - **`AppUsagePlugin.kt`**: Gathers historical UID network statistics asynchronously on `Dispatchers.IO` using Kotlin Coroutines, avoiding main-thread frame drops.
   - **`SimManagerPlugin.kt`**: Interrogates `SubscriptionManager` for multi-SIM slots and carrier identities.
   - **`ShizukuPlugin.kt`**: Interfaces with the Shizuku IPC binder service to invoke `READ_PRIVILEGED_PHONE_STATE` queries for independent SIM subscriber tracking.
   - **`WidgetProvider.kt`**: Broadcasts data snapshots to Android AppWidgets.

---

## Android Permissions Breakdown

ByteFlow adheres to least-privilege principles, clearly communicating why each permission is required and providing graceful fallbacks when permissions are withheld:

| Permission | Type | Purpose | Fallback Behavior |
| :--- | :--- | :--- | :--- |
| `PACKAGE_USAGE_STATS` | Special Access | Enables `NetworkStatsManager` queries for granular per-app bandwidth accounting. | Shows permission explanation card in Apps tab; never crashes. |
| `POST_NOTIFICATIONS` | Runtime (API 33+) | Displays persistent Foreground Service notification and live status-bar speed. | Speed indicator operates inside the open Flutter app only. |
| `FOREGROUND_SERVICE` | Install-time | Keeps speed monitoring active while multitasking or device is locked. | App monitors throughput only while open in the foreground. |
| `FOREGROUND_SERVICE_DATA_SYNC` | Android 14+ Svc | Declares Foreground Service type for background network measurement. | Complies with Android 14/15 background service enforcement. |
| `FOREGROUND_SERVICE_SPECIAL_USE`| Android 14+ Svc | Declares status bar overlay use-case. | Complies with Android 14/15 background service enforcement. |
| `READ_PHONE_STATE` | Runtime | Detects SIM slot indices, carrier network names, and active data SIMs. | Uses generic "Mobile Carrier" label without carrier breakdown. |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | Special Access | Prevents Android OEM battery managers from abruptly terminating the background service. | User is guided to device battery settings. |
| `RECEIVE_BOOT_COMPLETED` | Install-time | Automatically starts speed monitoring upon device startup (if enabled in Settings). | Service only starts when the user opens the application. |
| `READ_PRIVILEGED_PHONE_STATE` | Shizuku IPC | Queries independent SIM data usage via `subscriberId` on Android 10+. | Gracefully falls back to aggregate device-wide mobile tracking. |

---

## Shizuku Setup Guide (The Traffic Light Pattern)

Starting in Android 10, Google restricted access to `TelephonyManager.getSubscriberId()`, preventing non-system apps from breaking down mobile data usage by physical SIM cards. ByteFlow overcomes this restriction safely via Shizuku without requiring root access.

### Prerequisites
1. Download and install [Shizuku](https://shizuku.rikka.app/) (available on GitHub or Google Play).
2. Android 11+ with Wireless Debugging, or any Android device connected via ADB.

### Method A: Wireless Debugging (Android 11+)
1. Connect your device to a Wi-Fi network.
2. Enable **Developer Options** (`Settings` → `About phone` → tap `Build number` 7 times).
3. In Developer Options, enable **Wireless debugging**.
4. Open **Shizuku**, tap **Pairing**, and enter the 6-digit Wi-Fi pairing code.
5. In Shizuku, tap **Start**.

### Method B: ADB via Computer
Connect your device to a computer with ADB installed and run:
```sh
adb shell sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh
```

### Authorizing ByteFlow
1. Open ByteFlow and navigate to **Settings** → **System Permissions & Hardware**.
2. Tap **Request Access** next to Shizuku Privileged Access.
3. In the Shizuku system prompt, select **Allow all the time**.
4. ByteFlow will automatically switch to independent per-SIM bandwidth accounting!

---

## Battery Optimization & Efficiency

Network monitors are notorious for draining battery when improperly implemented. ByteFlow incorporates several core optimizations to ensure near-zero battery overhead:

1. **In-Memory Buffering & Batched SQLite Writes**:
   Instead of writing to flash storage on every 1 Hz speed update, ByteFlow accumulates transfer deltas in-memory. Data is flushed to SQLite:
   - Once every 15 minutes.
   - When the user switches away from ByteFlow (`AppLifecycleListener.onPause`).
   - When the app process is terminated.
2. **Screen-Off Throttling**:
   `NetworkSpeedService` registers an Android `ACTION_SCREEN_OFF` broadcast receiver. When the display is powered off, polling is throttled and Canvas bitmap rendering is paused, conserving CPU cycles.
3. **Low-Impact Notification Channel**:
   Notifications use Android's `IMPORTANCE_LOW` channel. Updates happen without triggering notification sounds, screen wakeups, or vibration motors.
4. **Targeted Widget Rebuilds**:
   Fine-grained Riverpod selectors prevent rebuilds of parent scaffolds or unneeded widget subtrees when speeds fluctuate.

---

## Project Structure

```
byteflow/
├── android/
│   ├── app/src/main/
│   │   ├── AndroidManifest.xml          # Permissions & service declarations
│   │   ├── kotlin/com/byteflow/network/
│   │   │   ├── MainActivity.kt          # Flutter embedding entry
│   │   │   ├── plugins/                 # Platform channel implementations
│   │   │   │   ├── AppUsagePlugin.kt    # Coroutine-based NetworkStatsManager
│   │   │   │   ├── NetworkStatsPlugin.kt# TrafficStats 1 Hz speed & connectivity
│   │   │   │   ├── ShizukuPlugin.kt     # Shizuku IPC binder connection
│   │   │   │   └── SimManagerPlugin.kt  # SubscriptionManager SIM detection
│   │   │   ├── receivers/
│   │   │   │   └── BootReceiver.kt      # BOOT_COMPLETED auto-starter
│   │   │   ├── services/
│   │   │   │   ├── NetworkSpeedService.kt# Foreground service
│   │   │   │   └── SpeedIconRenderer.kt # Canvas dynamic status-bar bitmap
│   │   │   └── widgets/                 # Native Android AppWidget providers
│   │   │       ├── DataPlanWidgetProvider.kt
│   │   │       ├── SpeedWidgetProvider.kt
│   │   │       └── TodayUsageWidgetProvider.kt
│   │   └── res/layout/                  # AppWidget XML layouts
├── lib/
│   ├── app/                             # App setup, GoRouter, M3 themes
│   ├── core/                            # Formatters, calculators, constants
│   ├── database/                        # Drift SQLite tables and DAOs
│   ├── models/                          # Immutable data models
│   ├── providers/                       # Riverpod state providers
│   ├── repositories/                    # Batched usage repository
│   ├── screens/                         # Flutter screens
│   │   ├── apps/                        # Per-app network usage
│   │   ├── dashboard/                   # Real-time throughput dashboard
│   │   ├── data_plans/                  # Multi-SIM data plans
│   │   ├── history/                     # fl_chart historical analytics
│   │   └── settings/                    # Preferences & permissions status
│   ├── services/                        # Native bridge & widget sync
│   └── widgets/                         # Reusable UI components
├── test/
│   ├── unit/                            # Dart unit tests
│   └── widget/                          # Flutter widget tests
└── docs/                                # Roadmap, architectural plans
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.22.0 or newer)
- [Dart SDK](https://dart.dev/get-dart) (3.4.0 or newer)
- Android SDK (API Level 34+ recommended; minimum supported is API Level 26 / Android 8.0)

### Setup & Compilation

1. **Clone the repository**:
   ```sh
   git clone https://github.com/Roni077/byteflow.git
   cd byteflow
   ```

2. **Install Flutter dependencies**:
   ```sh
   flutter pub get
   ```

3. **Generate Drift Database code**:
   ```sh
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run Static Analysis**:
   ```sh
   flutter analyze
   ```

5. **Run Test Suite & Verification**:
   ```sh
   flutter test
   dart test/verify_all_phases.dart
   ```

6. **Run on an Android device**:
   ```sh
   flutter run
   ```

---

## Automated CI/CD & APK Builds

ByteFlow employs a strict **fail-fast** GitHub Actions workflow ([`.github/workflows/build-apk.yml`](.github/workflows/build-apk.yml)) triggered on pushes, pull requests, and manual triggers:

```
[ Push / PR ] ──► [ Run Tests ] ──► [ Static Analysis ] ──► [ Build Debug APK ] ──► [ Build Release APK ] ──► [ Upload Artifacts ]
                         │                    │                      │                     │
                         ▼ (if fails)         ▼ (if fails)           ▼ (if fails)          ▼ (if fails)
                     [ STOPS ]            [ STOPS ]              [ STOPS ]             [ STOPS ]
```

1. **Unit & Widget Tests**: Executes `flutter test` across all provider, model, and UI tests.
2. **Phase Verification**: Runs `dart test/verify_all_phases.dart` validating 92 cross-layer contracts.
3. **Static Analysis**: Runs `flutter analyze --fatal-infos --fatal-warnings`.
4. **Build Debug APK**: Compiles `app-debug.apk` using `flutter build apk --debug`.
5. **Build Release APK**: Compiles `app-release.apk` using `flutter build apk --release`.
6. **Artifact Distribution**: Uploads both debug and release APKs as build artifacts directly downloadable from the GitHub Actions run summary.

---

## Quality Assurance & Verification

ByteFlow adheres to strict Dart and Flutter lint rules configured via `flutter_lints`:
- **Static Analysis**: Verified with `flutter analyze` with 0 warnings and 0 errors across all production files and test suites.
- **Strict Typing**: Type-safe Dart 3 switch expressions, pattern matching, and record tuples throughout the codebase.
- **Unit & Widget Testing**: Comprehensive coverage spanning formatters, data plan calculators, Drift DAOs, Riverpod providers, native bridges, and UI screens.
- **All-Phases Test Runner**: Standalone validation harness (`test/verify_all_phases.dart`) verifying data conservation, buffer flush guarantees, and platform channel contracts.

---

## Contributing & Community

Contributions, issues, and feature requests are welcome!
- **Contributing Guidelines**: Review our [CONTRIBUTING.md](CONTRIBUTING.md) for environment setup, code style, and PR process.
- **Code of Conduct**: We adhere to the [Contributor Covenant v2.1](CODE_OF_CONDUCT.md).
- **Security Policy**: For responsible vulnerability disclosures, please review [SECURITY.md](SECURITY.md).
- **Changelog**: Release history and updates are documented in [CHANGELOG.md](CHANGELOG.md).

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

