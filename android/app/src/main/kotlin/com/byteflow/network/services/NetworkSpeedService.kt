package com.byteflow.network.services

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.content.pm.ServiceInfo
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.TrafficStats
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.core.text.HtmlCompat
import com.byteflow.network.R
import com.byteflow.network.widgets.SpeedWidgetProvider
import java.util.Locale

/**
 * Android Foreground Service monitoring network throughput in the background and
 * dynamically rendering real-time speed in the status bar using [SpeedIconRenderer].
 *
 * Fully compliant with Android 14/15 Foreground Service types (dataSync | specialUse)
 * and incorporates battery-saving screen-off throttling.
 */
class NetworkSpeedService : Service() {

    companion object {
        const val NOTIFICATION_ID = 1001
        const val CHANNEL_ID = "byteflow_network_speed"
        const val CHANNEL_NAME = "Network Speed Monitor"

        const val PREFS_NAME = "byteflow_settings"
        const val KEY_SERVICE_ENABLED = "service_enabled"
        const val KEY_SHOW_STATUS_BAR_SPEED = "show_status_bar_speed"
        const val KEY_SPEED_DISPLAY_MODE = "speed_display_mode" // "combined", "download", "upload"
        const val KEY_START_ON_BOOT = "start_on_boot"
        const val KEY_POLLING_INTERVAL_MS = "polling_interval_ms"
        const val KEY_SHOW_NOTIFICATION = "show_notification"

        const val ACTION_START = "com.byteflow.network.action.START_SERVICE"
        const val ACTION_STOP = "com.byteflow.network.action.STOP_SERVICE"
        const val ACTION_UPDATE_CONFIG = "com.byteflow.network.action.UPDATE_CONFIG"

        @Volatile
        var isRunning: Boolean = false
            private set

        fun start(context: Context) {
            val intent = Intent(context, NetworkSpeedService::class.java).apply {
                action = ACTION_START
            }
            ContextCompat.startForegroundService(context, intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, NetworkSpeedService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }
    }

    private lateinit var notificationManager: NotificationManager
    private lateinit var connectivityManager: ConnectivityManager
    private var wifiManager: WifiManager? = null
    private lateinit var prefs: SharedPreferences

    // Dedicated background handler thread for polling
    private var handlerThread: HandlerThread? = null
    private var backgroundHandler: Handler? = null

    // Polling intervals
    private var activeIntervalMs = 1000L
    private val screenOffIntervalMs = 15000L

    @Volatile
    private var isScreenOn = true

    // TrafficStats baseline state
    private var lastRxBytes: Long = -1L
    private var lastTxBytes: Long = -1L
    private var lastTimestamp: Long = -1L

    // Current speeds
    @Volatile
    private var currentRxSpeed: Long = 0L
    @Volatile
    private var currentTxSpeed: Long = 0L

    // Network status
    @Volatile
    private var networkTypeString: String = "Detecting network..."
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    // Configuration
    private var showStatusBarSpeed: Boolean = true
    private var speedDisplayMode: String = "combined"
    private var showNotification: Boolean = true

    // Cached notification state to eliminate redundant rendering when speed is unchanged
    private var lastNotifiedDisplaySpeed: Long = -1L
    private var lastNotifiedRxSpeed: Long = -1L
    private var lastNotifiedTxSpeed: Long = -1L
    private var lastNotifiedNetworkType: String? = null

    // Screen state receiver
    private val screenStateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                Intent.ACTION_SCREEN_OFF -> {
                    isScreenOn = false
                    scheduleNextPoll(screenOffIntervalMs)
                }
                Intent.ACTION_SCREEN_ON, Intent.ACTION_USER_PRESENT -> {
                    isScreenOn = true
                    // Resume active 1s polling and refresh immediately
                    backgroundHandler?.removeCallbacks(pollRunnable)
                    backgroundHandler?.post(pollRunnable)
                }
            }
        }
    }

    private val pollRunnable = object : Runnable {
        override fun run() {
            if (!isRunning) return

            calculateSpeed()

            // When screen is on, update status bar notification
            if (isScreenOn) {
                updateNotification()
            }

            val nextInterval = if (isScreenOn) activeIntervalMs else screenOffIntervalMs
            scheduleNextPoll(nextInterval)
        }
    }

    override fun onCreate() {
        super.onCreate()
        isRunning = true

        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
        prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        loadPreferences()
        createNotificationChannel()

        // Register screen state receiver
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        registerReceiver(screenStateReceiver, filter)

        // Register network connectivity callback
        registerNetworkCallback()

        // Start background polling thread
        handlerThread = HandlerThread("ByteFlowSpeedServiceThread").apply {
            start()
            backgroundHandler = Handler(looper)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopSelf()
            return START_NOT_STICKY
        }

        if (intent?.action == ACTION_UPDATE_CONFIG) {
            loadPreferences()
            if (isScreenOn) {
                updateNotification(force = true)
            }
            backgroundHandler?.removeCallbacks(pollRunnable)
            backgroundHandler?.post(pollRunnable)
            return START_STICKY
        }

        // Persist enabled state in SharedPreferences
        prefs.edit().putBoolean(KEY_SERVICE_ENABLED, true).apply()

        // Build initial notification and start foreground
        val notification = buildNotification(0L, 0L)
        startForegroundCompat(notification)

        // Start polling loop
        backgroundHandler?.removeCallbacks(pollRunnable)
        backgroundHandler?.post(pollRunnable)

        return START_STICKY
    }

    override fun onDestroy() {
        isRunning = false
        prefs.edit().putBoolean(KEY_SERVICE_ENABLED, false).apply()

        try {
            unregisterReceiver(screenStateReceiver)
        } catch (e: Exception) {
            // Receiver might not have been registered
        }

        unregisterNetworkCallback()

        backgroundHandler?.removeCallbacks(pollRunnable)
        handlerThread?.quitSafely()
        handlerThread = null
        backgroundHandler = null

        stopForeground(STOP_FOREGROUND_REMOVE)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun loadPreferences() {
        showStatusBarSpeed = prefs.getBoolean(KEY_SHOW_STATUS_BAR_SPEED, true)
        speedDisplayMode = prefs.getString(KEY_SPEED_DISPLAY_MODE, "combined") ?: "combined"
        activeIntervalMs = prefs.getLong(KEY_POLLING_INTERVAL_MS, 1000L)
        showNotification = prefs.getBoolean(KEY_SHOW_NOTIFICATION, true)
    }

    private fun scheduleNextPoll(delayMs: Long) {
        backgroundHandler?.removeCallbacks(pollRunnable)
        backgroundHandler?.postDelayed(pollRunnable, delayMs)
    }

    private fun calculateSpeed() {
        val currentRx = TrafficStats.getTotalRxBytes()
        val currentTx = TrafficStats.getTotalTxBytes()
        val currentTime = System.currentTimeMillis()

        val safeRx = if (currentRx == TrafficStats.UNSUPPORTED.toLong()) 0L else currentRx
        val safeTx = if (currentTx == TrafficStats.UNSUPPORTED.toLong()) 0L else currentTx

        if (lastRxBytes == -1L || safeRx < lastRxBytes || safeTx < lastTxBytes) {
            // Initial baseline or reboot / rollover
            lastRxBytes = safeRx
            lastTxBytes = safeTx
            lastTimestamp = currentTime
            currentRxSpeed = 0L
            currentTxSpeed = 0L
        } else {
            val timeDeltaSec = (currentTime - lastTimestamp).toDouble() / 1000.0
            if (timeDeltaSec > 0.0) {
                currentRxSpeed = ((safeRx - lastRxBytes) / timeDeltaSec).toLong()
                currentTxSpeed = ((safeTx - lastTxBytes) / timeDeltaSec).toLong()
                lastRxBytes = safeRx
                lastTxBytes = safeTx
                lastTimestamp = currentTime
            }
        }
    }

    private fun updateNotification(force: Boolean = false) {
        val totalSpeed = currentRxSpeed + currentTxSpeed
        val displaySpeed = when (speedDisplayMode) {
            "download" -> currentRxSpeed
            "upload" -> currentTxSpeed
            else -> totalSpeed
        }

        // Avoid expensive bitmap rendering and system IPC if throughput and network status are identical
        if (!force &&
            displaySpeed == lastNotifiedDisplaySpeed &&
            currentRxSpeed == lastNotifiedRxSpeed &&
            currentTxSpeed == lastNotifiedTxSpeed &&
            networkTypeString == lastNotifiedNetworkType
        ) {
            return
        }

        lastNotifiedDisplaySpeed = displaySpeed
        lastNotifiedRxSpeed = currentRxSpeed
        lastNotifiedTxSpeed = currentTxSpeed
        lastNotifiedNetworkType = networkTypeString

        val rxFormatted = formatSpeed(currentRxSpeed)
        val txFormatted = formatSpeed(currentTxSpeed)
        val totalFormatted = formatSpeed(totalSpeed)

        // Dynamically update home screen speed widget if placed
        try {
            SpeedWidgetProvider.updateSpeed(
                applicationContext,
                rxFormatted,
                txFormatted,
                totalFormatted,
                networkTypeString
            )
        } catch (e: Exception) {
            // Safe guard against widget host anomalies
        }

        val notification = buildNotification(displaySpeed, totalSpeed)
        notificationManager.notify(NOTIFICATION_ID, notification)
    }

    private fun buildNotification(displaySpeed: Long, totalSpeed: Long): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val rxFormatted = formatSpeed(currentRxSpeed)
        val txFormatted = formatSpeed(currentTxSpeed)
        val totalFormatted = formatSpeed(totalSpeed)

        val htmlTitle = HtmlCompat.fromHtml(
            "↓ <font color='#00C853'><b>$rxFormatted</b></font>&nbsp;&nbsp;&nbsp;&nbsp;↑ <font color='#2979FF'><b>$txFormatted</b></font>",
            HtmlCompat.FROM_HTML_MODE_LEGACY
        )
        val contentText = "$networkTypeString • Total: $totalFormatted"

        val bigDetail = HtmlCompat.fromHtml(
            "↓ <b>Download:</b> <font color='#00C853'><b>$rxFormatted</b></font><br/>" +
            "↑ <b>Upload:</b> <font color='#2979FF'><b>$txFormatted</b></font><br/>" +
            "• <b>Combined Rate:</b> $totalFormatted<br/>" +
            "• <b>Active Connection:</b> $networkTypeString",
            HtmlCompat.FROM_HTML_MODE_LEGACY
        )

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(htmlTitle)
            .setContentText(contentText)
            .setSubText(networkTypeString)
            .setStyle(NotificationCompat.BigTextStyle().bigText(bigDetail))
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .setPriority(NotificationCompat.PRIORITY_LOW)

        if (showStatusBarSpeed) {
            val dynamicIcon = SpeedIconRenderer.createSpeedIcon(displaySpeed, compactUnits = false)
            builder.setSmallIcon(dynamicIcon)
        } else {
            // Standard static notification icon
            builder.setSmallIcon(android.R.drawable.stat_sys_download)
        }

        return builder.build()
    }

    private fun startForegroundCompat(notification: Notification) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            // Android 14+ requires explicit FGS type flags matching the manifest
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC or ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Displays real-time network download and upload speeds in the status bar"
                setShowBadge(false)
                enableLights(false)
                enableVibration(false)
                setSound(null, null)
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun registerNetworkCallback() {
        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                updateNetworkInfo()
            }

            override fun onLost(network: Network) {
                updateNetworkInfo()
            }

            override fun onCapabilitiesChanged(network: Network, networkCapabilities: NetworkCapabilities) {
                updateNetworkInfo()
            }
        }

        try {
            connectivityManager.registerDefaultNetworkCallback(networkCallback!!)
        } catch (e: Exception) {
            networkTypeString = "Connected"
        }
    }

    private fun unregisterNetworkCallback() {
        networkCallback?.let {
            try {
                connectivityManager.unregisterNetworkCallback(it)
            } catch (e: Exception) {
                // Ignore if already unregistered
            }
        }
        networkCallback = null
    }

    private fun updateNetworkInfo() {
        val activeNetwork = connectivityManager.activeNetwork
        val capabilities = if (activeNetwork != null) connectivityManager.getNetworkCapabilities(activeNetwork) else null

        if (capabilities == null || !capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)) {
            networkTypeString = "Offline"
            return
        }

        networkTypeString = when {
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> {
                val ssid = extractWifiSsid(capabilities)
                if (ssid != null) "Wi-Fi ($ssid)" else "Wi-Fi"
            }
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "Mobile Data"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "Ethernet"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN) -> "VPN Active"
            else -> "Connected"
        }

        if (isScreenOn) {
            backgroundHandler?.post { updateNotification() }
        }
    }

    private fun extractWifiSsid(capabilities: NetworkCapabilities): String? {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val transportInfo = capabilities.transportInfo
                if (transportInfo is WifiInfo) {
                    return cleanSsid(transportInfo.ssid)
                }
            }
            @Suppress("DEPRECATION")
            val info = wifiManager?.connectionInfo
            if (info != null) {
                return cleanSsid(info.ssid)
            }
        } catch (e: Exception) {
            // Ignore missing permissions
        }
        return null
    }

    private fun cleanSsid(raw: String?): String? {
        if (raw.isNullOrBlank() || raw == "<unknown ssid>" || raw == "\"<unknown ssid>\"") {
            return null
        }
        return raw.trim('\"')
    }

    private fun formatSpeed(bytesPerSec: Long): String {
        val safe = if (bytesPerSec < 0L) 0L else bytesPerSec
        return when {
            safe < 1000L -> "$safe B/s"
            safe < 1_000_000L -> {
                val kb = safe / 1024.0
                if (kb < 10.0) String.format(Locale.US, "%.1f KB/s", kb) else String.format(Locale.US, "%d KB/s", kb.toLong())
            }
            safe < 1_000_000_000L -> {
                val mb = safe / (1024.0 * 1024.0)
                if (mb < 10.0) String.format(Locale.US, "%.1f MB/s", mb) else String.format(Locale.US, "%d MB/s", mb.toLong())
            }
            else -> {
                val gb = safe / (1024.0 * 1024.0 * 1024.0)
                String.format(Locale.US, "%.2f GB/s", gb)
            }
        }
    }
}
