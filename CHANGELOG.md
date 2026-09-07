# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-09-07

### Added
- **Real-Time Network Speed Monitoring**:
  - Live 1 Hz download and upload transfer rates parsed directly from native Linux socket accounting via `TrafficStats`.
  - Automatic detection and compensation for device reboots and counter wraps.
  - Active network interface detection (Wi-Fi, Mobile Data, Ethernet, VPN) with SSID/carrier labeling.
- **Dynamic Status Bar Speed Indicator**:
  - Native Kotlin Foreground Service (`NetworkSpeedService`) running with `dataSync` and `specialUse` service types.
  - In-memory dynamic status-bar speed icon rendering using transparent 24×24 and 48×48 Canvas bitmaps via `SpeedIconRenderer`.
  - Non-intrusive `IMPORTANCE_LOW` Android notification channel eliminating sound, vibration, and popup interruptions.
  - Screen-off broadcast receiver throttling to pause bitmap generation while display is sleeping.
- **Material 3 UI & Responsive Design**:
  - Adaptive dual-column tablet layouts and single-column phone interfaces.
  - Full system, light, and dark theme support with high-contrast data visualization colors.
  - Expressive animated counters with `animated_flip_counter`.
  - Skeleton loading states via `skeletonizer` for fluid transitions.
- **Per-App Network Accounting**:
  - Coroutine-driven queries using `NetworkStatsManager` running asynchronously on `Dispatchers.IO`.
  - Lazy application icon loading with LRU memory caching to eliminate main-thread stutter.
  - Sorting by total bandwidth, download, upload, or alphabetical name.
  - System vs. user application filtering.
- **The Traffic Light Pattern (Shizuku Multi-SIM Support)**:
  - **Standard Mode (No Root / No Shizuku)**: Aggregates mobile cellular data across all SIMs using public Android APIs.
  - **Elevated Mode (With Shizuku)**: Dynamically binds to Shizuku IPC binder to query `NetworkStatsManager` with individual `subscriberId`s, unlocking independent SIM slot tracking on Android 10+.
  - **Graceful Fallback**: Dynamic binder connection lifecycle listeners preventing crashes when Shizuku service is disconnected or stopped.
- **Multi-SIM Data Plan Management**:
  - Dual SIM subscription detection (`SubscriptionManager`).
  - Monthly and customized billing cycle tracking with days remaining.
  - Dynamic recommended daily allowance calculation.
  - Configurable usage alert thresholds (e.g. 80% warning limit).
- **Home Screen Widgets**:
  - Android AppWidget implementations (`SpeedWidgetProvider`, `TodayUsageWidgetProvider`, `DataPlanWidgetProvider`) synchronized via `home_widget`.
- **Battery-First Local Data Storage**:
  - Drift ORM SQLite local database (`sqlite3_flutter_libs`).
  - In-memory delta buffering flushing to disk in 15-minute batches or on `AppLifecycleListener.onPause`.
  - Automatic historical usage aggregation for daily, weekly, and monthly charts via `fl_chart`.
- **CI/CD Automation & Open Source Standards**:
  - GitHub Actions fail-fast workflow compiling both debug and release APKs upon passing unit/widget tests and static analysis.
  - Full GitHub community health documentation (LICENSE, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, issue forms, and PR template).
