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
 * Native Android AppWidget displaying active cellular data plan progress.
 */
class DataPlanWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val name = prefs.getString(PREF_KEY_NAME, "No Active Plan") ?: "No Active Plan"
        val remaining = prefs.getString(PREF_KEY_REMAINING, "-- remaining") ?: "-- remaining"
        val percent = prefs.getInt(PREF_KEY_PERCENT, 0)
        val daysLeft = prefs.getString(PREF_KEY_DAYS_LEFT, "-- days left") ?: "-- days left"

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_data_plan).apply {
                setTextViewText(R.id.widget_plan_name, name)
                setTextViewText(R.id.widget_plan_remaining_text, remaining)
                setProgressBar(R.id.widget_plan_progress, 100, percent.coerceIn(0, 100), false)
                setTextViewText(R.id.widget_plan_days_left, daysLeft)
                setTextViewText(R.id.widget_plan_percent_text, "$percent% used")

                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_plan_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    companion object {
        const val PREF_KEY_NAME = "widget_plan_name"
        const val PREF_KEY_REMAINING = "widget_plan_remaining"
        const val PREF_KEY_PERCENT = "widget_plan_percent"
        const val PREF_KEY_DAYS_LEFT = "widget_plan_days_left"

        fun updatePlan(
            context: Context,
            name: String,
            remaining: String,
            percent: Int,
            daysLeft: String
        ) {
            val appWidgetManager = AppWidgetManager.getInstance(context) ?: return
            val ids = appWidgetManager.getAppWidgetIds(
                ComponentName(context, DataPlanWidgetProvider::class.java)
            )
            if (ids == null || ids.isEmpty()) return

            val clampedPercent = percent.coerceIn(0, 100)

            HomeWidgetPlugin.getData(context).edit()
                .putString(PREF_KEY_NAME, name)
                .putString(PREF_KEY_REMAINING, remaining)
                .putInt(PREF_KEY_PERCENT, clampedPercent)
                .putString(PREF_KEY_DAYS_LEFT, daysLeft)
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
                val views = RemoteViews(context.packageName, R.layout.widget_data_plan).apply {
                    setTextViewText(R.id.widget_plan_name, name)
                    setTextViewText(R.id.widget_plan_remaining_text, remaining)
                    setProgressBar(R.id.widget_plan_progress, 100, clampedPercent, false)
                    setTextViewText(R.id.widget_plan_days_left, daysLeft)
                    setTextViewText(R.id.widget_plan_percent_text, "$clampedPercent% used")
                    setOnClickPendingIntent(R.id.widget_plan_root, pendingIntent)
                }
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }
    }
}
