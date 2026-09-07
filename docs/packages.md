# ByteFlow: Packages & Dependencies

This document details the selected packages and native libraries for ByteFlow, verified against pub.dev and modern Android 10–15 standards, following architectural patterns from open-source network monitors like [Traffic Light](https://github.com/leekleak/traffic-light).

---

## 1. Flutter Dependencies (`pubspec.yaml`)

### State Management & Architecture
* **`flutter_riverpod: ^2.5.1`**
  * *Purpose*: Predictable, compile-time-safe state management and dependency injection.
  * *Why*: Handles real-time streams (1 Hz speed ticker) efficiently without triggering unnecessary full-page rebuilds.

### Navigation & Routing
* **`go_router: ^14.2.0`**
  * *Purpose*: Declarative routing supporting deep linking.
  * *Why*: Supports `StatefulShellRoute` to maintain bottom navigation tab states (Dashboard, History, Apps, Plans, Settings) without losing scroll positions or re-fetching data when switching tabs.

### Data Visualization
* **`fl_chart: ^0.68.0`**
  * *Purpose*: Hardware-accelerated, customizable line and bar charts.
  * *Why*: Industry standard for interactive network usage graphs (daily, weekly, monthly) with touch tooltips, smooth animations, and minimal memory overhead.

### Local Database & Persistence
* **`drift: ^2.18.0`**
  * *Purpose*: Type-safe, reactive SQLite ORM.
  * *Why*: Provides relational schemas (ideal for mapping Data Plans to SIM slots and historical usage), migrations, and query streams.
* **`sqlite3_flutter_libs: ^0.5.24`**
  * *Purpose*: Precompiled SQLite native C-binaries for Android (arm64-v8a, armeabi-v7a, x86_64).
* **`path_provider: ^2.1.3`**
  * *Purpose*: Locates platform-specific directories (app documents, cache) for database storage and cached app icons.
* **`shared_preferences: ^2.3.0`**
  * *Purpose*: Fast key-value store for user preferences (refresh rates, speed units, theme modes, monitoring toggles).

### Android System & Widgets
* **`home_widget: ^0.7.0`**
  * *Purpose*: Manages data communication between Flutter and native Android AppWidgets.
  * *Why*: Synchronizes current speed, daily usage, and data plan percentages into shared preferences accessible by Android's `AppWidgetProvider`.
* **`permission_handler: ^11.3.1`**
  * *Purpose*: Unified runtime permission handling.
  * *Why*: Handles `POST_NOTIFICATIONS`, `READ_PHONE_STATE`, and simplifies opening `Settings.ACTION_USAGE_ACCESS_SETTINGS` and `ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS`.
* **`package_info_plus: ^8.0.0`**
  * *Purpose*: Reads app metadata (name, version, build number) dynamically for the Settings/About screen.

### Utilities
* **`intl: ^0.19.0`**
  * *Purpose*: Date formatting for historical charts, billing cycles, and numeric formatting.

### Development & Code Generation
* **`drift_dev: ^2.18.0`**: Code generator for Drift tables and DAOs.
* **`build_runner: ^2.4.9`**: Runner for code generation.
* **`flutter_lints: ^3.0.0`**: Recommended lint rules for high code quality.
* **`flutter_test` / `integration_test`**: Unit, widget, and integration testing frameworks.

---

## 2. Android Dependencies (`android/app/build.gradle.kts`)

### AndroidX & Kotlin Extensions
* **`androidx.core:core-ktx:1.13.1`**: Modern Kotlin extensions for system services and notifications.
* **`org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.0`**: Background thread pooling (`Dispatchers.IO`) for heavy `NetworkStatsManager` queries and icon rendering without UI jank.

### Built-in Android Framework APIs
* **`android.net.TrafficStats`**: Real-time per-second packet/byte counters.
* **`android.app.usage.NetworkStatsManager`**: System network usage queries by UID, time range, and network type (requires `PACKAGE_USAGE_STATS`).
* **`android.net.ConnectivityManager`**: Real-time network state detection (Wi-Fi, Mobile, Ethernet, VPN, None).
* **`android.telephony.SubscriptionManager`**: Carrier information, SIM display names, and active data SIM detection.

### Advanced Features & Shizuku Integration
* **`dev.rikka.shizuku:api:13.1.5`**: Inter-Process Communication (IPC) client for Shizuku server.
* **`dev.rikka.shizuku:provider:13.1.5`**: Shizuku content provider binding (`rikka.shizuku.ShizukuProvider`).
  * *Why*: On Android 10+, `subscriberId` is restricted. Shizuku grants `READ_PRIVILEGED_PHONE_STATE` without root, enabling independent per-SIM mobile tracking for multi-SIM data plans. On devices without Shizuku, ByteFlow gracefully falls back to aggregate device mobile tracking.
