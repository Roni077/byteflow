/// Date, time, and interval calculation utilities.
library;

import 'package:intl/intl.dart';

/// Utilities for date arithmetic, calendar boundaries, and timestamp formatting.
abstract final class TimeUtils {
  static final DateFormat _timeFormat = DateFormat.Hms();
  static final DateFormat _dateFormat = DateFormat.yMMMd();

  /// Returns the start of the day (00:00:00.000) for the specified [dateTime].
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Returns the end of the day (23:59:59.999) for the specified [dateTime].
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      23,
      59,
      59,
      999,
    );
  }

  /// Whether two timestamps represent the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns the start of the month (1st day 00:00:00.000) for the specified [dateTime].
  static DateTime startOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  /// Returns the end of the month for the specified [dateTime].
  static DateTime endOfMonth(DateTime dateTime) {
    final nextMonthFirstDay = (dateTime.month == 12)
        ? DateTime(dateTime.year + 1, 1, 1)
        : DateTime(dateTime.year, dateTime.month + 1, 1);
    return nextMonthFirstDay.subtract(const Duration(milliseconds: 1));
  }

  /// Range covering today from 00:00:00 to 23:59:59.
  static (DateTime start, DateTime end) todayRange([DateTime? now]) {
    final current = now ?? DateTime.now();
    return (startOfDay(current), endOfDay(current));
  }

  /// Range covering yesterday from 00:00:00 to 23:59:59.
  static (DateTime start, DateTime end) yesterdayRange([DateTime? now]) {
    final current = now ?? DateTime.now();
    final yesterday = current.subtract(const Duration(days: 1));
    return (startOfDay(yesterday), endOfDay(yesterday));
  }

  /// Range covering the past 7 full calendar days including today.
  static (DateTime start, DateTime end) last7DaysRange([DateTime? now]) {
    final current = now ?? DateTime.now();
    final sevenDaysAgo = current.subtract(const Duration(days: 6));
    return (startOfDay(sevenDaysAgo), endOfDay(current));
  }

  /// Range covering the past 30 full calendar days including today.
  static (DateTime start, DateTime end) last30DaysRange([DateTime? now]) {
    final current = now ?? DateTime.now();
    final thirtyDaysAgo = current.subtract(const Duration(days: 29));
    return (startOfDay(thirtyDaysAgo), endOfDay(current));
  }

  /// Range covering the current calendar month.
  static (DateTime start, DateTime end) currentMonthRange([DateTime? now]) {
    final current = now ?? DateTime.now();
    return (startOfMonth(current), endOfMonth(current));
  }

  /// Range covering the previous calendar month.
  static (DateTime start, DateTime end) previousMonthRange([DateTime? now]) {
    final current = now ?? DateTime.now();
    final previousMonthDate = (current.month == 1)
        ? DateTime(current.year - 1, 12, 1)
        : DateTime(current.year, current.month - 1, 1);
    return (startOfMonth(previousMonthDate), endOfMonth(previousMonthDate));
  }

  /// Formats a [time] as a 24-hour timestamp string (HH:mm:ss).
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  /// Formats a [date] as a localized abbreviated date string (e.g., Sep 5, 2026).
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formats a date into a short day/month label (e.g., "Sep 5" or "09/05").
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Formats an hour into a 2-digit 24h format (e.g., "14:00").
  static String formatHour(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
}
