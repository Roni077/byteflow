package com.byteflow.network.plugins

import android.app.usage.NetworkStatsManager
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.os.Build
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import rikka.shizuku.Shizuku
import java.io.BufferedReader
import java.io.InputStreamReader

/**
 * Native Android plugin connecting to Shizuku IPC daemon for privileged Multi-SIM operations.
 *
 * Implements "The Traffic Light Pattern":
 * - Green: Shizuku active + permission granted -> Per-SIM tracking using subscriberId (IMSI).
 * - Amber: Shizuku active, permission required -> Prompts user for Shizuku authorization.
 * - Red / Fallback: Shizuku unavailable -> Seamlessly degrades to device-wide cellular tracking.
 */
class ShizukuPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var context: Context
    private var methodChannel: MethodChannel? = null
    private var subscriptionManager: SubscriptionManager? = null
    private var telephonyManager: TelephonyManager? = null
    private var networkStatsManager: NetworkStatsManager? = null

    private var pendingPermissionResult: MethodChannel.Result? = null

    private val binderReceivedListener = Shizuku.OnBinderReceivedListener {
        // Binder connection established
    }

    private val binderDeadListener = Shizuku.OnBinderDeadListener {
        // Binder connection severed
    }

    private val permissionResultListener = object : Shizuku.OnRequestPermissionResultListener {
        override fun onRequestPermissionResult(requestCode: Int, grantResult: Int) {
            if (requestCode == REQUEST_CODE_SHIZUKU_PERMISSION) {
                val granted = grantResult == PackageManager.PERMISSION_GRANTED
                if (granted) {
                    grantPrivilegedPermissionViaShell()
                }
                pendingPermissionResult?.success(granted)
                pendingPermissionResult = null
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
        telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
        networkStatsManager = context.getSystemService(Context.NETWORK_STATS_SERVICE) as? NetworkStatsManager

        methodChannel = MethodChannel(binding.binaryMessenger, "com.byteflow.network/shizuku")
        methodChannel?.setMethodCallHandler(this)

        try {
            Shizuku.addBinderReceivedListenerSticky(binderReceivedListener)
            Shizuku.addBinderDeadListener(binderDeadListener)
            Shizuku.addRequestPermissionResultListener(permissionResultListener)
        } catch (e: Throwable) {
            // Guard against environments where Shizuku IPC is unsupported
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        try {
            Shizuku.removeBinderReceivedListener(binderReceivedListener)
            Shizuku.removeBinderDeadListener(binderDeadListener)
            Shizuku.removeRequestPermissionResultListener(permissionResultListener)
        } catch (e: Throwable) {
            // Clean unregister guard
        }

        subscriptionManager = null
        telephonyManager = null
        networkStatsManager = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getShizukuStatus" -> {
                result.success(getShizukuStatus())
            }
            "requestShizukuPermission" -> {
                requestShizukuPermission(result)
            }
            "getSimSubscriberIds" -> {
                result.success(getSimSubscriberIds())
            }
            "querySimUsage" -> {
                val subId = call.argument<Int>("subId") ?: -1
                val subscriberId = call.argument<String>("subscriberId")
                val startTime = call.argument<Long>("startTime") ?: 0L
                val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                querySimUsage(subId, subscriberId, startTime, endTime, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun isBinderAlive(): Boolean {
        return try {
            Shizuku.pingBinder()
        } catch (e: Throwable) {
            false
        }
    }

    private fun checkPermission(): Boolean {
        if (!isBinderAlive()) return false
        return try {
            if (Shizuku.isPreV11()) {
                false
            } else {
                Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED
            }
        } catch (e: Throwable) {
            false
        }
    }

    private fun getShizukuStatus(): Map<String, Any?> {
        val available = isBinderAlive()
        val permission = if (available) checkPermission() else false
        val version = if (available) {
            try { Shizuku.getVersion() } catch (e: Throwable) { -1 }
        } else -1
        val uid = if (available) {
            try { Shizuku.getUid() } catch (e: Throwable) { -1 }
        } else -1

        return mapOf(
            "isAvailable" to available,
            "hasPermission" to permission,
            "version" to version,
            "uid" to uid
        )
    }

    private fun requestShizukuPermission(result: MethodChannel.Result) {
        if (!isBinderAlive()) {
            result.success(false)
            return
        }

        if (checkPermission()) {
            grantPrivilegedPermissionViaShell()
            result.success(true)
            return
        }

        try {
            if (Shizuku.isPreV11()) {
                result.success(false)
                return
            }

            pendingPermissionResult = result
            Shizuku.requestPermission(REQUEST_CODE_SHIZUKU_PERMISSION)
        } catch (e: Throwable) {
            result.success(false)
        }
    }

    /**
     * Executes a process via Shizuku shell using reflection.
     */
    private fun newShizukuProcess(cmd: Array<String>): Process? {
        return try {
            val method = Shizuku::class.java.getDeclaredMethod(
                "newProcess",
                Array<String>::class.java,
                Array<String>::class.java,
                String::class.java
            )
            method.isAccessible = true
            method.invoke(null, cmd, null, null) as? Process
        } catch (e: Throwable) {
            null
        }
    }

    /**
     * Attempts to grant READ_PRIVILEGED_PHONE_STATE to the application package using Shizuku's shell process.
     */
    private fun grantPrivilegedPermissionViaShell() {
        try {
            val process = newShizukuProcess(
                arrayOf("pm", "grant", context.packageName, "android.permission.READ_PRIVILEGED_PHONE_STATE")
            )
            process?.waitFor()
        } catch (e: Throwable) {
            // Ignore if pm grant is restricted
        }
    }

    /**
     * Resolves subscriber ID (IMSI) for active SIM subscriptions using telephony or shell.
     */
    private fun getSimSubscriberIds(): Map<String, String> {
        val resultMap = mutableMapOf<String, String>()
        val sm = subscriptionManager ?: return resultMap
        val tm = telephonyManager ?: return resultMap

        val subList: List<SubscriptionInfo>? = try {
            sm.activeSubscriptionInfoList
        } catch (e: Throwable) {
            null
        }

        if (subList.isNullOrEmpty()) {
            return resultMap
        }

        for (info in subList) {
            val subId = info.subscriptionId
            var imsi: String? = null

            // 1. Attempt standard Telephony query if permission is granted to process
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                try {
                    val subTelephony = tm.createForSubscriptionId(subId)
                    @Suppress("DEPRECATION")
                    imsi = subTelephony.subscriberId
                } catch (e: Throwable) {
                    // Restricted without privileged phone state
                }
            }

            // 2. Attempt Shizuku shell query if IMSI was restricted
            if (imsi.isNullOrBlank() && checkPermission()) {
                imsi = querySubscriberIdViaShell(subId)
            }

            if (!imsi.isNullOrBlank()) {
                resultMap[subId.toString()] = imsi
            }
        }

        return resultMap
    }

    private fun querySubscriberIdViaShell(subId: Int): String? {
        return try {
            val process = newShizukuProcess(
                arrayOf("sh", "-c", "cmd phone get-subscriber-id -s $subId")
            ) ?: return null
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val line = reader.readLine()?.trim()
            process.waitFor()
            if (!line.isNullOrBlank() && !line.contains("Error", ignoreCase = true)) {
                line
            } else {
                null
            }
        } catch (e: Throwable) {
            null
        }
    }

    /**
     * Queries network stats for a specific SIM card (subscriberId) or falls back to device-wide aggregate.
     */
    private fun querySimUsage(
        subId: Int,
        subscriberId: String?,
        startTime: Long,
        endTime: Long,
        result: MethodChannel.Result
    ) {
        val nsm = networkStatsManager
        if (nsm == null) {
            result.success(
                mapOf(
                    "rxBytes" to 0L,
                    "txBytes" to 0L,
                    "totalBytes" to 0L,
                    "isPrivileged" to false,
                    "subscriberId" to null
                )
            )
            return
        }

        // Try privileged per-SIM query if subscriberId is available
        val targetSubscriberId = subscriberId ?: if (checkPermission() && subId > 0) {
            querySubscriberIdViaShell(subId)
        } else {
            null
        }

        if (!targetSubscriberId.isNullOrBlank()) {
            try {
                val bucket = nsm.querySummaryForDevice(
                    ConnectivityManager.TYPE_MOBILE,
                    targetSubscriberId,
                    startTime,
                    endTime
                )
                val rx = bucket.rxBytes
                val tx = bucket.txBytes
                result.success(
                    mapOf(
                        "rxBytes" to rx,
                        "txBytes" to tx,
                        "totalBytes" to (rx + tx),
                        "isPrivileged" to true,
                        "subscriberId" to targetSubscriberId
                    )
                )
                return
            } catch (e: SecurityException) {
                // Privileged permission denied by OS -> Graceful fallback
            } catch (e: Throwable) {
                // Fallback to aggregate
            }
        }

        // Graceful fallback to aggregate mobile cellular statistics
        try {
            val bucket = nsm.querySummaryForDevice(
                ConnectivityManager.TYPE_MOBILE,
                null,
                startTime,
                endTime
            )
            val rx = bucket.rxBytes
            val tx = bucket.txBytes
            result.success(
                mapOf(
                    "rxBytes" to rx,
                    "txBytes" to tx,
                    "totalBytes" to (rx + tx),
                    "isPrivileged" to false,
                    "subscriberId" to null
                )
            )
        } catch (e: Throwable) {
            result.success(
                mapOf(
                    "rxBytes" to 0L,
                    "txBytes" to 0L,
                    "totalBytes" to 0L,
                    "isPrivileged" to false,
                    "subscriberId" to null
                )
            )
        }
    }

    companion object {
        private const val REQUEST_CODE_SHIZUKU_PERMISSION = 1002
    }
}
