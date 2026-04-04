package com.example.visainnovations.magic_ledger

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class MagicLedgerWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.magic_ledger_widget).apply {

                // ═══ HEADER ═══
                val month = widgetData.getString("month", "") ?: ""
                setTextViewText(R.id.tv_month, month.uppercase())

                // ═══ BALANCE ═══
                val balance = widgetData.getString("balance", "₹0") ?: "₹0"
                setTextViewText(R.id.tv_balance, balance)

                val isPositive = widgetData.getString("balance_positive", "true") == "true"
                setTextColor(
                    R.id.tv_balance,
                    if (isPositive) Color.parseColor("#15803d") else Color.parseColor("#dc2626")
                )

                // ═══ SAVINGS BADGE ═══
                val savingsRate = widgetData.getString("savings_rate", "0%") ?: "0%"
                setTextViewText(R.id.tv_savings_rate, savingsRate)

                // ═══ STAT CARDS ═══
                setTextViewText(R.id.tv_spent, widgetData.getString("spent", "₹0") ?: "₹0")
                setTextViewText(R.id.tv_earned, widgetData.getString("earned", "₹0") ?: "₹0")
                setTextViewText(R.id.tv_today, widgetData.getString("today_spent", "₹0") ?: "₹0")

                val dailyAvg = widgetData.getString("daily_avg", "₹0") ?: "₹0"
                setTextViewText(R.id.tv_daily_avg, "$dailyAvg/d")

                setTextViewText(R.id.tv_tx_count, widgetData.getString("tx_count", "0") ?: "0")
                setTextViewText(R.id.tv_account_balance, widgetData.getString("account_balance", "₹0") ?: "₹0")

                // ═══ FOOTER ═══
                val updated = widgetData.getString("last_updated", "") ?: ""
                setTextViewText(
                    R.id.tv_updated,
                    if (updated.isNotEmpty()) "Updated $updated" else "Tap to sync"
                )

                // ═══ TAP TO OPEN ═══
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    widgetId,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}