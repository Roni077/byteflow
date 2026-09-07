package com.byteflow.network.plugins

import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.TrafficStats
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.byteflow.network.services.NetworkSpeedService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Native Android plugin providing real-time network speed polling via [TrafficStats]
 * and active network connectivity state updates via [ConnectivityManager].
 */
class NetworkStatsPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var context: Context
    private var methodChannel: MethodChannel? = null
    private var speedEventChannel: EventChannel? = null
    private var networkEventChannel: EventChannel? = null

    private var connectivityManager: ConnectivityManager? = null
    private var wifiManager: WifiManager? = null

    // Handler and state for 1-second TrafficStats speed polling
    private val mainHandler = Handler(Looper.getMainLooper())
    private var speedEventSink: EventChannel.EventSink? = null
    private var isSpeedPolling = false

    private var lastRxBytes: Long = -1L
    private var lastTxBytes: Long = -1L
    private var lastTimestamp: Long = -1L
    private var pollingIntervalMs: Long = 1000L

    private val speedPollingRunnable = object : Runnable {
        override fun run() {
            if (!isSpeedPolling) return

            val currentRx = TrafficStats.getTotalRxBytes()
            val currentTx = TrafficStats.getTotalTxBytes()
            val currentTime = System.currentTimeMillis()

            // Normalize unsupported device returns (-1L)
            val safeRx = if (currentRx == TrafficStats.UNSUPPORTED.toLong()) 0L else currentRx
            val safeTx = if (currentTx == TrafficStats.UNSUPPORTED.toLong()) 0L else currentTx

            if (lastRxBytes == -1L || safeRx < lastRxBytes || safeTx < lastTxBytes) {
                // Initial baseline or reboot / 32-bit counter rollover anomaly detected
                lastRxBytes = safeRx
                lastTxBytes = safeTx
                lastTimestamp = currentTime

                speedEventSink?.success(
                    mapOf(
                        "rxSpeed" to 0L,
                        "txSpeed" to 0L,
                        "totalSpeed" to 0L,
                        "timestamp" to currentTime
                    )
                )
            } else {
                val timeDeltaSeconds = (currentTime - lastTimestamp).toDouble() / 1000.0
                if (timeDeltaSeconds > 0.0) {
                    val rxDelta = safeRx - lastRxBytes
                    val txDelta = safeTx - lastTxBytes

                    val rxSpeed = (rxDelta / timeDeltaSeconds).toLong()
                    val txSpeed = (txDelta / timeDeltaSeconds).toLong()
                    val totalSpeed = rxSpeed + txSpeed

                    lastRxBytes = safeRx
                    lastTxBytes = safeTx
                    lastTimestamp = currentTime

                    speedEventSink?.success(
                        mapOf(
                            "rxSpeed" to rxSpeed,
                            "txSpeed" to txSpeed,
                            "totalSpeed" to totalSpeed,
                            "timestamp" to currentTime
                        )
                    )
                }
            }

            mainHandler.postDelayed(this, pollingIntervalMs)
        }
    }

    // ConnectivityManager callback for network changes
    private var networkEventSink: EventChannel.EventSink? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
        wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager

        methodChannel = MethodChannel(binding.binaryMessenger, "com.byteflow.network/methods")
        methodChannel?.setMethodCallHandler(this)

        speedEventChannel = EventChannel(binding.binaryMessenger, "com.byteflow.network/speed")
        speedEventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                speedEventSink = events
                isSpeedPolling = true
                lastRxBytes = -1L
                lastTxBytes = -1L
                lastTimestamp = -1L
                mainHandler.post(speedPollingRunnable)
            }

            override fun onCancel(arguments: Any?) {
                isSpeedPolling = false
                speedEventSink = null
                mainHandler.removeCallbacks(speedPollingRunnable)
            }
        })

        networkEventChannel = EventChannel(binding.binaryMessenger, "com.byteflow.network/network")
        networkEventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                networkEventSink = events
                registerNetworkCallback()
                // Emit current state immediately
                events?.success(getNetworkInfoMap())
            }

            override fun onCancel(arguments: Any?) {
                unregisterNetworkCallback()
                networkEventSink = null
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        speedEventChannel?.setStreamHandler(null)
        speedEventChannel = null

        networkEventChannel?.setStreamHandler(null)
        networkEventChannel = null

        isSpeedPolling = false
        mainHandler.removeCallbacks(speedPollingRunnable)
        unregisterNetworkCallback()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getNetworkInfo" -> {
                result.success(getNetworkInfoMap())
            }
            "getTrafficStats" -> {
                val rx = TrafficStats.getTotalRxBytes()
                val tx = TrafficStats.getTotalTxBytes()
                val safeRx = if (rx == TrafficStats.UNSUPPORTED.toLong()) 0L else rx
                val safeTx = if (tx == TrafficStats.UNSUPPORTED.toLong()) 0L else tx
                result.success(
                    mapOf(
                        "rxTotalBytes" to safeRx,
                        "txTotalBytes" to safeTx,
                        "timestamp" to System.currentTimeMillis()
                    )
                )
            }
            "startForegroundService" -> {
                val showStatusBar = call.argument<Boolean>("showStatusBarSpeed") ?: true
                val displayMode = call.argument<String>("speedDisplayMode") ?: "combined"
                val startOnBoot = call.argument<Boolean>("startOnBoot") ?: false
                val pollingInterval = call.argument<Int>("pollingIntervalMs")?.toLong() ?: 1000L
                val showNotif = call.argument<Boolean>("showPersistentNotification") ?: true

                val prefs = context.getSharedPreferences(NetworkSpeedService.PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit()
                    .putBoolean(NetworkSpeedService.KEY_SHOW_STATUS_BAR_SPEED, showStatusBar)
                    .putString(NetworkSpeedService.KEY_SPEED_DISPLAY_MODE, displayMode)
                    .putBoolean(NetworkSpeedService.KEY_START_ON_BOOT, startOnBoot)
                    .putLong(NetworkSpeedService.KEY_POLLING_INTERVAL_MS, pollingInterval)
                    .putBoolean(NetworkSpeedService.KEY_SHOW_NOTIFICATION, showNotif)
                    .putBoolean(NetworkSpeedService.KEY_SERVICE_ENABLED, true)
                    .apply()

                NetworkSpeedService.start(context)
                result.success(true)
            }
            "stopForegroundService" -> {
                NetworkSpeedService.stop(context)
                val prefs = context.getSharedPreferences(NetworkSpeedService.PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit().putBoolean(NetworkSpeedService.KEY_SERVICE_ENABLED, false).apply()
                result.success(true)
            }
            "isForegroundServiceRunning" -> {
                result.success(NetworkSpeedService.isRunning)
            }
            "updateServiceConfig" -> {
                val showStatusBar = call.argument<Boolean>("showStatusBarSpeed")
                val displayMode = call.argument<String>("speedDisplayMode")
                val startOnBoot = call.argument<Boolean>("startOnBoot")
                val pollingInterval = call.argument<Int>("pollingIntervalMs")?.toLong()
                val showNotif = call.argument<Boolean>("showPersistentNotification")

                val prefs = context.getSharedPreferences(NetworkSpeedService.PREFS_NAME, Context.MODE_PRIVATE)
                val editor = prefs.edit()
                if (showStatusBar != null) editor.putBoolean(NetworkSpeedService.KEY_SHOW_STATUS_BAR_SPEED, showStatusBar)
                if (displayMode != null) editor.putString(NetworkSpeedService.KEY_SPEED_DISPLAY_MODE, displayMode)
                if (startOnBoot != null) editor.putBoolean(NetworkSpeedService.KEY_START_ON_BOOT, startOnBoot)
                if (pollingInterval != null) editor.putLong(NetworkSpeedService.KEY_POLLING_INTERVAL_MS, pollingInterval)
                if (showNotif != null) editor.putBoolean(NetworkSpeedService.KEY_SHOW_NOTIFICATION, showNotif)
                editor.apply()

                if (NetworkSpeedService.isRunning) {
                    val intent = Intent(context, NetworkSpeedService::class.java).apply {
                        action = NetworkSpeedService.ACTION_UPDATE_CONFIG
                    }
                    context.startService(intent)
                }
                result.success(true)
            }
            "getServiceConfig" -> {
                val prefs = context.getSharedPreferences(NetworkSpeedService.PREFS_NAME, Context.MODE_PRIVATE)
                result.success(
                    mapOf(
                        "isRunning" to NetworkSpeedService.isRunning,
                        "showStatusBarSpeed" to prefs.getBoolean(NetworkSpeedService.KEY_SHOW_STATUS_BAR_SPEED, true),
                        "speedDisplayMode" to (prefs.getString(NetworkSpeedService.KEY_SPEED_DISPLAY_MODE, "combined") ?: "combined"),
                        "startOnBoot" to prefs.getBoolean(NetworkSpeedService.KEY_START_ON_BOOT, false),
                        "pollingIntervalMs" to prefs.getLong(NetworkSpeedService.KEY_POLLING_INTERVAL_MS, 1000L).toInt(),
                        "showPersistentNotification" to prefs.getBoolean(NetworkSpeedService.KEY_SHOW_NOTIFICATION, true)
                    )
                )
            }
            "setPollingInterval" -> {
                val interval = call.argument<Int>("pollingIntervalMs")?.toLong() ?: 1000L
                pollingIntervalMs = interval
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun registerNetworkCallback() {
        val cm = connectivityManager ?: return
        if (networkCallback != null) return

        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                notifyNetworkChange()
            }

            override fun onLost(network: Network) {
                notifyNetworkChange()
            }

            override fun onCapabilitiesChanged(network: Network, networkCapabilities: NetworkCapabilities) {
                notifyNetworkChange()
            }
        }

        try {
            cm.registerDefaultNetworkCallback(networkCallback!!)
        } catch (e: Exception) {
            // Fallback gracefully if permission or device restriction occurs
        }
    }

    private fun unregisterNetworkCallback() {
        val cm = connectivityManager ?: return
        val cb = networkCallback ?: return
        try {
            cm.unregisterNetworkCallback(cb)
        } catch (e: Exception) {
            // Callback might already be unregistered
        }
        networkCallback = null
    }

    private fun notifyNetworkChange() {
        mainHandler.post {
            networkEventSink?.success(getNetworkInfoMap())
        }
    }

    private fun getNetworkInfoMap(): Map<String, Any?> {
        val cm = connectivityManager
        val activeNetwork = cm?.activeNetwork
        val capabilities = if (cm != null && activeNetwork != null) cm.getNetworkCapabilities(activeNetwork) else null

        if (capabilities == null || !capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)) {
            return mapOf(
                "type" to "none",
                "isConnected" to false,
                "isMetered" to false,
                "ssid" to null
            )
        }

        val type = when {
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "mobile"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET) -> "ethernet"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_VPN) -> "vpn"
            capabilities.hasTransport(NetworkCapabilities.TRANSPORT_BLUETOOTH) -> "bluetooth"
            else -> "unknown"
        }

        val isMetered = !capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED)
        var ssid: String? = null

        if (type == "wifi") {
            ssid = extractWifiSsid(capabilities)
        }

        return mapOf(
            "type" to type,
            "isConnected" to true,
            "isMetered" to isMetered,
            "ssid" to ssid
        )
    }

    private fun extractWifiSsid(capabilities: NetworkCapabilities): String? {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val transportInfo = capabilities.transportInfo
                if (transportInfo is WifiInfo) {
                    val rawSsid = transportInfo.ssid
                    return cleanSsid(rawSsid)
                }
            }

            @Suppress("DEPRECATION")
            val connectionInfo = wifiManager?.connectionInfo
            if (connectionInfo != null) {
                return cleanSsid(connectionInfo.ssid)
            }
        } catch (e: Exception) {
            // Ignore security exception or missing fine location permission
        }
        return null
    }

    private fun cleanSsid(raw: String?): String? {
        if (raw.isNullOrBlank() || raw == "<unknown ssid>" || raw == "\"<unknown ssid>\"") {
            return null
        }
        return raw.trim('\"')
    }
}
