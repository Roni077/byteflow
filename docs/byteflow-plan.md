# ByteFlow: Comprehensive Technical Architecture Plan

ByteFlow is a modern, production-grade Android network monitoring application built with Flutter (UI & application logic) and Kotlin (native Android system APIs). It is inspired by the architectural patterns of the open-source [Traffic Light](https://github.com/leekleak/traffic-light) project, emphasizing user privacy, real Android data, battery efficiency, and graceful degradation without root.

---

## 1. System Architecture & Separation of Concerns

```
+-----------------------------------------------------------------------+
|                            FLUTTER UI                                 |
|  Material 3 • StatefulShellRoute (BottomNav) • Responsive Layouts     |
|  [Dashboard]      [History]      [Apps]      [Data Plans]  [Settings] |
+-----------------------------------------------------------------------+
                                  │
                                  ▼
+-----------------------------------------------------------------------+
|                    APPLICATION & STATE LAYER (Riverpod)              |
|  SpeedNotifier (Stream) • UsageRepository • PlanNotifier              |
+-----------------------------------------------------------------------+
            │                                             │
            ▼                                             ▼
+-----------------------+                    +--------------------------+
|  LOCAL DATABASE (Drift)|                    |  PLATFORM BRIDGE         |
|  SQLite (Drift ORM)   |                    |  MethodChannel / Event   |
|  • Usage Snapshots    |                    +--------------------------+
|  • Data Plans / SIMs  |                                 │
|  • Settings           |                                 ▼
+-----------------------+                    +--------------------------+
                                             |  ANDROID KOTLIN CORE     |
                                             |  • NetworkStatsPlugin    |
                                             |  • AppUsagePlugin        |
                                             |  • SimManagerPlugin      |
                                             |  • ShizukuPlugin         |
                                             |  • NetworkSpeedService   |
                                             |  • StatusBarSpeedService |
                                             |  • WidgetProvider        |
                                             +--------------------------+
```

---

## 2. Native Android Implementation Strategies

### A. Real-Time Network Speed & Status Bar Indicator
1. **TrafficStats Counter Difference**:
   * Poll `TrafficStats.getTotalRxBytes()` and `TrafficStats.getTotalTxBytes()` every $T$ seconds (default 1s).
   * $\text{Download Speed} = \frac{\text{RxBytes}_t - \text{RxBytes}_{t-1}}{\Delta t}$, $\text{Upload Speed} = \frac{\text{TxBytes}_t - \text{TxBytes}_{t-1}}{\Delta t}$.
   * Handle device reboots and counter resets: if $\text{RxBytes}_t < \text{RxBytes}_{t-1}$, reset baseline without reporting negative or spiked values.
2. **Native Status Bar Indicator (Dynamic Icon Rendering)**:
   * Standard Android has no open status bar overlay API. Like Traffic Light, ByteFlow implements this via a **Foreground Service Persistent Notification**:
   * Generate an in-memory 24×24 or 48×48 transparent `Bitmap`.
   * Draw the formatted speed string (e.g. `4.2M` or `420K` or stacked arrows/digits) using an anti-aliased `Paint` and `Canvas`.
   * Set the notification's small icon via `NotificationCompat.Builder.setSmallIcon(IconCompat.createWithBitmap(bitmap))`. Android renders this small icon directly in the status bar!
   * Use an `IMPORTANCE_LOW` notification channel (no sound, no vibration, no popup).
   * Update the notification only when the speed changes, conserving CPU and battery.

### B. High-Performance Per-App Statistics (`AppUsagePlugin.kt`)
1. **Thread Offloading**: Querying `NetworkStatsManager` across 200+ apps is executed using **Kotlin Coroutines (`Dispatchers.IO`)** to avoid blocking the main thread.
2. **Lightweight Channel Serialization**:
   * The plugin aggregates usage per UID and returns metadata maps: `[uid, packageName, appName, rxBytes, txBytes, wifiBytes, mobileBytes]`.
   * App icons are NOT serialized as bulk byte arrays over the `MethodChannel` (which would risk `TransactionTooLargeException`). Instead, icons are lazily loaded on demand via a dedicated `getAppIcon(packageName)` method or cached locally as PNG files.

### C. Multi-SIM Support & Shizuku Integration (`SimManagerPlugin.kt` & `ShizukuPlugin.kt`)
1. **The Android 10+ Privacy Constraint**: On Android 10+, `TelephonyManager.getSubscriberId()` is restricted. Normal apps cannot query `NetworkStatsManager` with a non-null `subscriberId`.
2. **Dual-Mode Operation (The Traffic Light Pattern)**:
   * **Standard Mode (No Root / No Shizuku)**: Query mobile data device-wide (`subscriberId = null`), and use `SubscriptionManager.getActiveSubscriptionInfoList()` to display carrier names, slot indices, and active data SIMs.
   * **Advanced Mode (With Shizuku)**: If the user enables Shizuku, ByteFlow binds to the Shizuku IPC service and obtains `READ_PRIVILEGED_PHONE_STATE`. This enables querying `NetworkStatsManager` with specific subscriber IDs, allowing per-SIM data plan tracking.
   * **Zero Crashing**: The app dynamically checks `Shizuku.pingBinder()` and gracefully degrades if Shizuku is not installed or permissions are revoked.

### D. Background Integrity & Battery Efficiency
1. **Foreground Service Types (Android 14/15 Compliance)**:
   * Declare `dataSync` and `specialUse` in `AndroidManifest.xml`.
   * Request `FOREGROUND_SERVICE_DATA_SYNC` and `FOREGROUND_SERVICE_SPECIAL_USE`.
   * Pass the proper service type in `startForeground()`.
2. **Screen-Off Optimization**:
   * Register a `BroadcastReceiver` for `ACTION_SCREEN_OFF` and `ACTION_SCREEN_ON`.
   * When the screen turns off, throttle polling or suspend status bar rendering if configured, drastically reducing battery drain.
3. **Boot Startup**:
   * `BootReceiver.kt` listens for `ACTION_BOOT_COMPLETED` and starts `NetworkSpeedService` if the user enabled "Start on Boot" in Settings.

---

## 3. Flutter Architecture & Key Components

### A. State Management with Riverpod
* `speedStreamProvider`: Exposes real-time download/upload speed from native `EventChannel`. Consumed only by speed display widgets to avoid rebuilding parent scaffolds.
* `networkInfoProvider`: Listens to `ConnectivityManager` changes (Wi-Fi, Mobile, Ethernet, VPN, None, SSID).
* `usageHistoryProvider`: Queries Drift database for daily, weekly, and monthly totals.
* `appUsageProvider`: Manages per-app usage list, sorting states, and search filters.
* `dataPlanNotifier`: Manages data plans, calculation of billing cycles, warnings, and daily recommended allowances.

### B. Declarative Routing with GoRouter
* `StatefulShellRoute.indexedStack` hosts the 5 primary tabs:
  1. `/dashboard`
  2. `/history`
  3. `/apps`
  4. `/plans`
  5. `/settings`
* Deep links and dialog routes:
  * `/settings/permissions`
  * `/plans/add`
  * `/plans/edit/:id`

### C. Local Database with Drift (SQLite)
* **Tables**:
  * `UsageSnapshots`: Date, downloadBytes, uploadBytes, wifiBytes, mobileBytes. (Batched writes every 15–30 minutes or on app pause, never every second!).
  * `DataPlans`: id, name, limitBytes, cycleStartDate, cycleType, simSlot, warningPercent.
  * `UserSettings`: Key-value cache for preferences.

---

## 4. Verification & Testing Strategy

1. **Unit Tests (Dart)**:
   * Speed unit conversion (`formatSpeed(bytesPerSec)` -> KB/s, MB/s, GB/s).
   * Data plan cycle calculations (days remaining, recommended daily allowance, warning thresholds).
   * Riverpod provider state transitions.
2. **Native Android Compatibility**:
   * Verify compilation on ARM64 (`flutter build apk --target-platform android-arm64`).
   * Test service lifecycle, notification dismissal prevention, and graceful permission checks without crashes.
3. **Static Analysis**: Run `dart analyze` to ensure 0 lint errors and strict type safety.
