/// Formatting utilities for data volumes and network transfer speeds.
library;

/// Speed unit options for network throughput display.
enum SpeedUnit {
  /// Automatically picks the most readable unit (B/s, KB/s, MB/s, GB/s).
  auto('Auto'),

  /// Forces Kilobytes per second (KB/s).
  kbs('KB/s'),

  /// Forces Megabytes per second (MB/s).
  mbs('MB/s'),

  /// Forces Gigabytes per second (GB/s).
  gbs('GB/s');

  const SpeedUnit(this.label);

  /// User-friendly label for this speed unit.
  final String label;

  /// Parses a string key into a [SpeedUnit], defaulting to [SpeedUnit.auto].
  static SpeedUnit fromString(String? val) {
    return switch (val?.toLowerCase()) {
      'kbs' || 'kb/s' => SpeedUnit.kbs,
      'mbs' || 'mb/s' => SpeedUnit.mbs,
      'gbs' || 'gb/s' => SpeedUnit.gbs,
      _ => SpeedUnit.auto,
    };
  }
}

/// Data volume unit options for cumulative network transfer display.
enum DataUnit {
  /// Automatically picks the most readable unit (B, KB, MB, GB, TB).
  auto('Auto'),

  /// Forces Megabytes (MB).
  mb('MB'),

  /// Forces Gigabytes (GB).
  gb('GB');

  const DataUnit(this.label);

  /// User-friendly label for this data unit.
  final String label;

  /// Parses a string key into a [DataUnit], defaulting to [DataUnit.auto].
  static DataUnit fromString(String? val) {
    return switch (val?.toLowerCase()) {
      'mb' => DataUnit.mb,
      'gb' => DataUnit.gb,
      _ => DataUnit.auto,
    };
  }
}

/// Formats network rates and byte sizes into human-readable strings.
abstract final class Formatters {
  static const int _kilobyte = 1024;
  static const int _megabyte = 1024 * _kilobyte;
  static const int _gigabyte = 1024 * _megabyte;
  static const int _terabyte = 1024 * _gigabyte;

  /// Deconstructs a transfer rate into numerical value and speed unit.
  ///
  /// The [bytesPerSecond] input is converted according to binary prefixes
  /// or [preferredUnit]. Values less than or equal to zero resolve to
  /// `('0', 'B/s')` or `'0'` in the forced unit.
  ///
  /// The [decimals] parameter controls the fractional precision for
  /// converted scales.
  static (String value, String unit) formatSpeedParts(
    int bytesPerSecond, {
    int decimals = 1,
    SpeedUnit preferredUnit = SpeedUnit.auto,
  }) {
    if (preferredUnit == SpeedUnit.kbs) {
      final val = bytesPerSecond <= 0
          ? '0'
          : (bytesPerSecond / _kilobyte).toStringAsFixed(decimals);
      return (val, 'KB/s');
    } else if (preferredUnit == SpeedUnit.mbs) {
      final val = bytesPerSecond <= 0
          ? '0'
          : (bytesPerSecond / _megabyte).toStringAsFixed(decimals);
      return (val, 'MB/s');
    } else if (preferredUnit == SpeedUnit.gbs) {
      final val = bytesPerSecond <= 0
          ? '0'
          : (bytesPerSecond / _gigabyte).toStringAsFixed(decimals);
      return (val, 'GB/s');
    }

    return switch (bytesPerSecond) {
      <= 0 => ('0', 'B/s'),
      < _kilobyte => ('$bytesPerSecond', 'B/s'),
      < _megabyte => (
        (bytesPerSecond / _kilobyte).toStringAsFixed(decimals),
        'KB/s',
      ),
      < _gigabyte => (
        (bytesPerSecond / _megabyte).toStringAsFixed(decimals),
        'MB/s',
      ),
      _ => (
        (bytesPerSecond / _gigabyte).toStringAsFixed(decimals),
        'GB/s',
      ),
    };
  }

  /// Formats a transfer rate into a combined speed string.
  ///
  /// Examples include `450 B/s`, `12.4 KB/s`, `3.5 MB/s`, and `1.2 GB/s`.
  static String formatSpeed(
    int bytesPerSecond, {
    int decimals = 1,
    SpeedUnit preferredUnit = SpeedUnit.auto,
  }) {
    final (value, unit) = formatSpeedParts(
      bytesPerSecond,
      decimals: decimals,
      preferredUnit: preferredUnit,
    );
    return '$value $unit';
  }

  /// Deconstructs a cumulative byte count into numerical value and data unit.
  ///
  /// The [bytes] input is scaled using binary prefixes (B, KB, MB, GB, TB)
  /// or [preferredUnit]. Values less than or equal to zero resolve to `('0', 'B')`
  /// or `'0'` in the forced unit.
  ///
  /// The [decimals] parameter controls fractional precision.
  static (String value, String unit) formatBytesParts(
    int bytes, {
    int decimals = 1,
    DataUnit preferredUnit = DataUnit.auto,
  }) {
    if (preferredUnit == DataUnit.mb) {
      final val =
          bytes <= 0 ? '0' : (bytes / _megabyte).toStringAsFixed(decimals);
      return (val, 'MB');
    } else if (preferredUnit == DataUnit.gb) {
      final val =
          bytes <= 0 ? '0' : (bytes / _gigabyte).toStringAsFixed(decimals);
      return (val, 'GB');
    }

    return switch (bytes) {
      <= 0 => ('0', 'B'),
      < _kilobyte => ('$bytes', 'B'),
      < _megabyte => ((bytes / _kilobyte).toStringAsFixed(decimals), 'KB'),
      < _gigabyte => ((bytes / _megabyte).toStringAsFixed(decimals), 'MB'),
      < _terabyte => ((bytes / _gigabyte).toStringAsFixed(decimals), 'GB'),
      _ => ((bytes / _terabyte).toStringAsFixed(decimals), 'TB'),
    };
  }

  /// Formats a cumulative byte count into a combined size string.
  ///
  /// Examples include `500 B`, `150.2 KB`, `45.8 MB`, and `2.4 GB`.
  static String formatBytes(
    int bytes, {
    int decimals = 1,
    DataUnit preferredUnit = DataUnit.auto,
  }) {
    final (value, unit) = formatBytesParts(
      bytes,
      decimals: decimals,
      preferredUnit: preferredUnit,
    );
    return '$value $unit';
  }
}
