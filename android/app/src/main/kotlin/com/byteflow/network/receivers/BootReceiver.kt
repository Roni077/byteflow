package com.byteflow.network.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.byteflow.network.services.NetworkSpeedService

/**
 * BroadcastReceiver listening for device reboot completions to automatically resume
 * background network monitoring if the user has enabled "Start on Boot".
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            val prefs = context.getSharedPreferences(NetworkSpeedService.PREFS_NAME, Context.MODE_PRIVATE)
            val startOnBoot = prefs.getBoolean(NetworkSpeedService.KEY_START_ON_BOOT, false)
            val serviceEnabled = prefs.getBoolean(NetworkSpeedService.KEY_SERVICE_ENABLED, false)

            if (startOnBoot && serviceEnabled) {
                NetworkSpeedService.start(context)
            }
        }
    }
}
