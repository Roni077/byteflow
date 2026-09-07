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
 * Native Android AppWidget displaying today's aggregate data usage.
 */
class TodayUsageWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val total = prefs.getString(PREF_KEY_TOTAL, "0.00 MB") ?: "0.00 MB"
        val rx = prefs.getString(PREF_KEY_RX, "↓ 0.00 MB") ?: "↓ 0.00 MB"
        val tx = prefs.getString(PREF_KEY_TX, "↑ 0.00 MB") ?: "↑ 0.00 MB"

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_today_usage).apply {
                setTextViewText(R.id.widget_today_total_text, total)
                setTextViewText(R.id.widget_today_rx_text, rx)
                setTextViewText(R.id.widget_today_tx_text, tx)

                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_today_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    companion object {
        const val PREF_KEY_TOTAL = "widget_today_total"
        const val PREF_KEY_RX = "widget_today_rx"
        const val PREF_KEY_TX = "widget_today_tx"

        fun updateUsage(
            context: Context,
            total: String,
            rx: String,
            tx: String
        ) {
            val appWidgetManager = AppWidgetManager.getInstance(context) ?: return
            val ids = appWidgetManager.getAppWidgetIds(
                ComponentName(context, TodayUsageWidgetProvider::class.java)
            )
            if (ids == null || ids.isEmpty()) return

            val rxFormatted = if (rx.startsWith("↓")) rx else "↓ $rx"
            val txFormatted = if (tx.startsWith("↑")) tx else "↑ $tx"

            HomeWidgetPlugin.getData(context).edit()
                .putString(PREF_KEY_TOTAL, total)
                .putString(PREF_KEY_RX, rxFormatted)
                .putString(PREF_KEY_TX, txFormatted)
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
                val views = RemoteViews(context.packageName, R.layout.widget_today_usage).apply {
                    setTextViewText(R.id.widget_today_total_text, total)
                    setTextViewText(R.id.widget_today_rx_text, rxFormatted)
                    setTextViewText(R.id.widget_today_tx_text, txFormatted)
                    setOnClickPendingIntent(R.id.widget_today_root, pendingIntent)
                }
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }
    }
}
