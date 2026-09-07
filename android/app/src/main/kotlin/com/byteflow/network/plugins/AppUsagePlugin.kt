package com.byteflow.network.plugins

import android.app.AppOpsManager
import android.app.usage.NetworkStats
import android.app.usage.NetworkStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.ConnectivityManager
import android.os.Build
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

/**
 * Native Android plugin querying per-app data usage statistics through [NetworkStatsManager]
 * and [PackageManager] on asynchronous Kotlin Coroutines ([Dispatchers.IO]).
 */
class AppUsagePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var context: Context
    private var methodChannel: MethodChannel? = null
    private val pluginScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    private class UidUsageAccumulator {
        var wifiRx: Long = 0L
        var wifiTx: Long = 0L
        var mobileRx: Long = 0L
        var mobileTx: Long = 0L
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "com.byteflow.network/app_usage")
        methodChannel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        pluginScope.cancel()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasUsagePermission" -> {
                result.success(checkUsagePermission())
            }
            "openUsageSettings" -> {
                openUsageSettings()
                result.success(true)
            }
            "getAppUsage" -> {
                val startTime = (call.argument<Number>("startTime"))?.toLong() ?: 0L
                val endTime = (call.argument<Number>("endTime"))?.toLong() ?: System.currentTimeMillis()

                pluginScope.launch {
                    try {
                        val usageList = withContext(Dispatchers.IO) {
                            fetchAppUsageData(startTime, endTime)
                        }
                        result.success(usageList)
                    } catch (e: Exception) {
                        result.error("APP_USAGE_ERROR", e.message, null)
                    }
                }
            }
            "getAppIcon" -> {
                val packageName = call.argument<String>("packageName")
                if (packageName.isNullOrBlank()) {
                    result.success(null)
                    return
                }

                pluginScope.launch {
                    try {
                        val iconBytes = withContext(Dispatchers.IO) {
                            fetchAppIconPng(packageName)
                        }
                        result.success(iconBytes)
                    } catch (e: Exception) {
                        result.success(null)
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun checkUsagePermission(): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager ?: return false
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageSettings() {
        try {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            try {
                val fallback = Intent(Settings.ACTION_SETTINGS).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(fallback)
            } catch (_: Exception) {
                // Ignore if device has neither settings activity
            }
        }
    }

    private fun fetchAppUsageData(startTime: Long, endTime: Long): List<Map<String, Any>> {
        val networkStatsManager = context.getSystemService(Context.NETWORK_STATS_SERVICE) as? NetworkStatsManager
            ?: return emptyList()

        if (!checkUsagePermission()) {
            return emptyList()
        }

        val usageMap = mutableMapOf<Int, UidUsageAccumulator>()

        // 1. Accumulate Wi-Fi usage by UID
        try {
            val wifiStats = networkStatsManager.querySummary(
                ConnectivityManager.TYPE_WIFI,
                null,
                startTime,
                endTime
            )
            val bucket = NetworkStats.Bucket()
            while (wifiStats.hasNextBucket()) {
                wifiStats.getNextBucket(bucket)
                val uid = bucket.uid
                val acc = usageMap.getOrPut(uid) { UidUsageAccumulator() }
                acc.wifiRx += bucket.rxBytes
                acc.wifiTx += bucket.txBytes
            }
            wifiStats.close()
        } catch (e: Exception) {
            // Wi-Fi query may fail if unsupported or unpermitted
        }

        // 2. Accumulate Mobile usage by UID
        try {
            val mobileStats = networkStatsManager.querySummary(
                ConnectivityManager.TYPE_MOBILE,
                null,
                startTime,
                endTime
            )
            val bucket = NetworkStats.Bucket()
            while (mobileStats.hasNextBucket()) {
                mobileStats.getNextBucket(bucket)
                val uid = bucket.uid
                val acc = usageMap.getOrPut(uid) { UidUsageAccumulator() }
                acc.mobileRx += bucket.rxBytes
                acc.mobileTx += bucket.txBytes
            }
            mobileStats.close()
        } catch (e: Exception) {
            // Mobile query may fail if unsupported or unpermitted
        }

        val packageManager = context.packageManager
        val resultList = mutableListOf<Map<String, Any>>()

        for ((uid, usage) in usageMap) {
            val totalRx = usage.wifiRx + usage.mobileRx
            val totalTx = usage.wifiTx + usage.mobileTx
            val totalBytes = totalRx + totalTx

            // Skip entries that consumed zero bytes
            if (totalBytes <= 0) continue

            val (packageName, appName, isSystemApp) = resolveAppIdentity(packageManager, uid)

            val item = mapOf(
                "uid" to uid,
                "packageName" to packageName,
                "appName" to appName,
                "rxBytes" to totalRx,
                "txBytes" to totalTx,
                "wifiRxBytes" to usage.wifiRx,
                "wifiTxBytes" to usage.wifiTx,
                "mobileRxBytes" to usage.mobileRx,
                "mobileTxBytes" to usage.mobileTx,
                "totalBytes" to totalBytes,
                "isSystemApp" to isSystemApp
            )
            resultList.add(item)
        }

        // Sort descending by total data usage
        resultList.sortByDescending { it["totalBytes"] as Long }
        return resultList
    }

    private fun resolveAppIdentity(pm: PackageManager, uid: Int): Triple<String, String, Boolean> {
        // Handle special Android system UIDs
        when (uid) {
            Process.SYSTEM_UID -> return Triple("android", "Android System", true)
            0 -> return Triple("root", "Root / Kernel", true)
            -4 -> return Triple("removed_apps", "Removed Apps", true)
            -5 -> return Triple("tethering", "Tethering & Hotspot", true)
            1051 -> return Triple("media_provider", "Media Storage", true)
            1068 -> return Triple("dns_resolver", "DNS & Network Services", true)
        }

        val packages = pm.getPackagesForUid(uid)
        if (packages.isNullOrEmpty()) {
            return Triple("uid_$uid", "Application ($uid)", false)
        }

        val primaryPackage = packages[0]
        try {
            val appInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getApplicationInfo(primaryPackage, PackageManager.ApplicationInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                pm.getApplicationInfo(primaryPackage, 0)
            }

            val appLabel = pm.getApplicationLabel(appInfo).toString()
            val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0 ||
                    (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
            return Triple(primaryPackage, appLabel, isSystem)
        } catch (e: PackageManager.NameNotFoundException) {
            return Triple(primaryPackage, primaryPackage, false)
        }
    }

    private fun fetchAppIconPng(packageName: String): ByteArray? {
        val pm = context.packageManager
        val drawable: Drawable = try {
            if (packageName == "android") {
                pm.getDefaultActivityIcon()
            } else {
                pm.getApplicationIcon(packageName)
            }
        } catch (e: Exception) {
            return null
        }

        val bitmap = drawableToBitmap(drawable)
        val outputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
        return outputStream.toByteArray()
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable && drawable.bitmap != null) {
            return Bitmap.createScaledBitmap(drawable.bitmap, 96, 96, true)
        }

        val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth.coerceIn(48, 144) else 96
        val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight.coerceIn(48, 144) else 96

        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }
}
