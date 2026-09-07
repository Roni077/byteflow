package com.byteflow.network.services

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.Typeface
import androidx.core.graphics.drawable.IconCompat
import java.util.Locale

/**
 * Utility responsible for generating high-DPI dynamic status bar speed icon bitmaps.
 *
 * Renders formatted speed digits and units using an anti-aliased Canvas onto an
 * in-memory ARGB_8888 Bitmap. Android System UI treats notification small icons as
 * alpha masks and automatically tints [Color.WHITE] pixels according to light/dark themes.
 */
object SpeedIconRenderer {

    private const val BITMAP_SIZE = 96

    // Pre-allocated static objects to achieve zero-GC allocations during 1 Hz polling
    private val cachedBitmap: Bitmap = Bitmap.createBitmap(BITMAP_SIZE, BITMAP_SIZE, Bitmap.Config.ARGB_8888)
    private val cachedCanvas: Canvas = Canvas(cachedBitmap)

    private val valuePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        textAlign = Paint.Align.CENTER
        typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
    }

    private val unitPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        textAlign = Paint.Align.CENTER
        typeface = Typeface.create(Typeface.MONOSPACE, Typeface.BOLD)
    }

    private val valueMetrics = Paint.FontMetrics()
    private val unitMetrics = Paint.FontMetrics()

    /**
     * Formats bytes per second and renders a 2-line status bar icon.
     *
     * @param bytesPerSec Network throughput in bytes per second.
     * @param compactUnits If true, uses "K", "M", "G". If false, uses "K/s", "M/s", "G/s".
     * @return [IconCompat] wrapping the freshly rendered in-memory [Bitmap].
     */
    @Synchronized
    fun createSpeedIcon(bytesPerSec: Long, compactUnits: Boolean = false): IconCompat {
        val bitmap = renderSpeedBitmapLocked(bytesPerSec, compactUnits)
        return IconCompat.createWithBitmap(bitmap)
    }

    /**
     * Renders a 96x96 ARGB_8888 bitmap with speed number stacked above the unit.
     */
    @Synchronized
    fun createSpeedBitmap(bytesPerSec: Long, compactUnits: Boolean = false): Bitmap {
        return renderSpeedBitmapLocked(bytesPerSec, compactUnits)
    }

    private fun renderSpeedBitmapLocked(bytesPerSec: Long, compactUnits: Boolean): Bitmap {
        // Clear canvas with transparent pixels
        cachedCanvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR)

        val (valueStr, unitStr) = formatSpeedParts(bytesPerSec, compactUnits)

        // Adjust text size based on string length to avoid horizontal clipping
        valuePaint.textSize = when {
            valueStr.length >= 4 -> 36f
            valueStr.length == 3 -> 40f
            else -> 46f
        }

        unitPaint.textSize = if (compactUnits) 34f else 26f

        valuePaint.getFontMetrics(valueMetrics)
        unitPaint.getFontMetrics(unitMetrics)

        val valueHeight = valueMetrics.descent - valueMetrics.ascent
        val unitHeight = unitMetrics.descent - unitMetrics.ascent
        val gap = 4f

        val totalHeight = valueHeight + unitHeight + gap
        val startY = (BITMAP_SIZE - totalHeight) / 2f

        val valueBaseline = startY - valueMetrics.ascent
        val unitBaseline = valueBaseline + valueMetrics.descent + gap - unitMetrics.ascent

        val centerX = BITMAP_SIZE / 2f
        cachedCanvas.drawText(valueStr, centerX, valueBaseline, valuePaint)
        cachedCanvas.drawText(unitStr, centerX, unitBaseline, unitPaint)

        return cachedBitmap.copy(Bitmap.Config.ARGB_8888, false)
    }

    /**
     * Decomposes speed in bytes/sec into a pair of formatted numeric string and unit string.
     */
    fun formatSpeedParts(bytesPerSec: Long, compact: Boolean = false): Pair<String, String> {
        val safeBytes = if (bytesPerSec < 0L) 0L else bytesPerSec

        return when {
            safeBytes < 1000L -> {
                // Below 1 KB/s
                val unit = if (compact) "B" else "B/s"
                Pair(safeBytes.toString(), unit)
            }
            safeBytes < 1_000_000L -> {
                // Kilobytes per second (1 KB/s to 999 KB/s)
                val kb = safeBytes / 1024.0
                val unit = if (compact) "K" else "K/s"
                val formatted = if (kb < 10.0) {
                    String.format(Locale.US, "%.1f", kb)
                } else {
                    String.format(Locale.US, "%d", kb.toLong())
                }
                Pair(formatted, unit)
            }
            safeBytes < 1_000_000_000L -> {
                // Megabytes per second (1 MB/s to 999 MB/s)
                val mb = safeBytes / (1024.0 * 1024.0)
                val unit = if (compact) "M" else "M/s"
                val formatted = if (mb < 10.0) {
                    String.format(Locale.US, "%.1f", mb)
                } else {
                    String.format(Locale.US, "%d", mb.toLong())
                }
                Pair(formatted, unit)
            }
            else -> {
                // Gigabytes per second
                val gb = safeBytes / (1024.0 * 1024.0 * 1024.0)
                val unit = if (compact) "G" else "G/s"
                val formatted = String.format(Locale.US, "%.1f", gb)
                Pair(formatted, unit)
            }
        }
    }
}
