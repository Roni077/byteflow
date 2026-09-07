package com.byteflow.network.plugins

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Native Android plugin querying multi-SIM and cellular subscription details
 * via [SubscriptionManager] with graceful fallback when permissions or hardware are absent.
 */
class SimManagerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var context: Context
    private var methodChannel: MethodChannel? = null
    private var subscriptionManager: SubscriptionManager? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
        methodChannel = MethodChannel(binding.binaryMessenger, "com.byteflow.network/sim")
        methodChannel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        subscriptionManager = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasPhonePermission" -> {
                result.success(hasPhonePermission())
            }
            "getSimCards" -> {
                result.success(getSimCards())
            }
            "getDefaultDataSubId" -> {
                result.success(getDefaultDataSubId())
            }
            else -> result.notImplemented()
        }
    }

    private fun hasPhonePermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.READ_PHONE_STATE
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun getDefaultDataSubId(): Int? {
        val sm = subscriptionManager ?: return null
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            SubscriptionManager.getDefaultDataSubscriptionId()
        } else {
            null
        }
    }

    private fun getSimCards(): List<Map<String, Any?>> {
        val sm = subscriptionManager ?: return emptyList()
        if (!hasPhonePermission()) {
            return emptyList()
        }

        return try {
            val list: List<SubscriptionInfo>? = sm.activeSubscriptionInfoList
            if (list.isNullOrEmpty()) {
                emptyList()
            } else {
                val defaultDataSubId = getDefaultDataSubId()
                list.map { info ->
                    mapOf(
                        "subscriptionId" to info.subscriptionId,
                        "simSlotIndex" to info.simSlotIndex,
                        "carrierName" to (info.carrierName?.toString() ?: ""),
                        "displayName" to (info.displayName?.toString() ?: ""),
                        "countryIso" to (info.countryIso ?: ""),
                        "isDefaultData" to (defaultDataSubId != null && info.subscriptionId == defaultDataSubId)
                    )
                }
            }
        } catch (e: SecurityException) {
            emptyList()
        } catch (e: Exception) {
            emptyList()
        }
    }
}
