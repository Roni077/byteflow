package com.byteflow.network.widgets

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.byteflow.network.MainActivity
import com.byteflow.network.R
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Native Android AppWidget displaying live download and upload network speeds.
 *
 * Dynamically updated by [HomeWidgetPlugin] and directly by
 * [com.byteflow.network.services.NetworkSpeedService] when active.
 */
class SpeedWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val rxSpeed = prefs.getString(PREF_KEY_RX, "↓ 0 B/s") ?: "↓ 0 B/s"
        val txSpeed = prefs.getString(PREF_KEY_TX, "↑ 0 B/s") ?: "↑ 0 B/s"
        val totalSpeed = prefs.getString(PREF_KEY_TOTAL, "0 B/s") ?: "0 B/s"
        val networkName = prefs.getString(PREF_KEY_NETWORK, "Offline") ?: "Offline"

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_speed).apply {
                setTextViewText(R.id.widget_speed_rx_text, rxSpeed)
                setTextViewText(R.id.widget_speed_tx_text, txSpeed)
                setTextViewText(R.id.widget_speed_total_text, totalSpeed)
                setTextViewText(R.id.widget_network_name, networkName)

                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_speed_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    companion object {
        const val PREF_KEY_RX = "widget_speed_rx"
        const val PREF_KEY_TX = "widget_speed_tx"
        const val PREF_KEY_TOTAL = "widget_speed_total"
        const val PREF_KEY_NETWORK = "widget_speed_network"

        /**
         * Fast direct update called from [NetworkSpeedService] without waking the Flutter engine.
         */
        fun updateSpeed(
            context: Context,
            rxFormatted: String,
            txFormatted: String,
            totalFormatted: String,
            networkName: String
        ) {
            val appWidgetManager = AppWidgetManager.getInstance(context) ?: return
            val ids = appWidgetManager.getAppWidgetIds(
                ComponentName(context, SpeedWidgetProvider::class.java)
            )
            if (ids == null || ids.isEmpty()) return

            val rxText = "↓ $rxFormatted"
            val txText = "↑ $txFormatted"

            // Persist latest values
            HomeWidgetPlugin.getData(context).edit()
                .putString(PREF_KEY_RX, rxText)
                .putString(PREF_KEY_TX, txText)
                .putString(PREF_KEY_TOTAL, totalFormatted)
                .putString(PREF_KEY_NETWORK, networkName)
                .apply()

            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            for (appWidgetId in ids) {
                val views = RemoteViews(context.packageName, R.layout.widget_speed).apply {
                    setTextViewText(R.id.widget_speed_rx_text, rxText)
                    setTextViewText(R.id.widget_speed_tx_text, txText)
                    setTextViewText(R.id.widget_speed_total_text, totalFormatted)
                    setTextViewText(R.id.widget_network_name, networkName)
                    setOnClickPendingIntent(R.id.widget_speed_root, pendingIntent)
                }
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }
    }
}
