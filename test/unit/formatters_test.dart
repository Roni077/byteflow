import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/core/utils/formatters.dart';

void main() {
  group('Formatters - Speed', () {
    test('formats zero and negative speeds correctly', () {
      expect(Formatters.formatSpeed(0), equals('0 B/s'));
      expect(Formatters.formatSpeed(-100), equals('0 B/s'));

      final (valZero, unitZero) = Formatters.formatSpeedParts(0);
      expect(valZero, equals('0'));
      expect(unitZero, equals('B/s'));

      final (valNeg, unitNeg) = Formatters.formatSpeedParts(-42);
      expect(valNeg, equals('0'));
      expect(unitNeg, equals('B/s'));
    });

    test('formats byte rates (< 1024 B/s)', () {
      expect(Formatters.formatSpeed(512), equals('512 B/s'));
      expect(Formatters.formatSpeed(1023), equals('1023 B/s'));

      final (val, unit) = Formatters.formatSpeedParts(800);
      expect(val, equals('800'));
      expect(unit, equals('B/s'));
    });

    test('formats kilobyte rates (>= 1 KB/s and < 1 MB/s)', () {
      expect(Formatters.formatSpeed(1024), equals('1.0 KB/s'));
      expect(Formatters.formatSpeed(1536), equals('1.5 KB/s'));
      expect(Formatters.formatSpeed(1024 * 500), equals('500.0 KB/s'));

      final (val, unit) = Formatters.formatSpeedParts(2048);
      expect(val, equals('2.0'));
      expect(unit, equals('KB/s'));
    });

    test('formats megabyte rates (>= 1 MB/s and < 1 GB/s)', () {
      expect(Formatters.formatSpeed(1024 * 1024), equals('1.0 MB/s'));
      expect(Formatters.formatSpeed(1024 * 1024 * 5 + 1024 * 512), equals('5.5 MB/s'));

      final (val, unit) = Formatters.formatSpeedParts(1024 * 1024 * 25);
      expect(val, equals('25.0'));
      expect(unit, equals('MB/s'));
    });

    test('formats gigabyte rates (>= 1 GB/s)', () {
      expect(Formatters.formatSpeed(1024 * 1024 * 1024), equals('1.0 GB/s'));
      expect(Formatters.formatSpeed(1024 * 1024 * 1024 * 2), equals('2.0 GB/s'));

      final (val, unit) = Formatters.formatSpeedParts(1024 * 1024 * 1024 * 3);
      expect(val, equals('3.0'));
      expect(unit, equals('GB/s'));
    });

    test('respects custom decimal places', () {
      expect(Formatters.formatSpeed(1536, decimals: 2), equals('1.50 KB/s'));
      expect(Formatters.formatSpeed(1536, decimals: 0), equals('2 KB/s'));
    });
  });

  group('Formatters - Byte Volumes', () {
    test('formats zero and negative byte counts', () {
      expect(Formatters.formatBytes(0), equals('0 B'));
      expect(Formatters.formatBytes(-50), equals('0 B'));

      final (val, unit) = Formatters.formatBytesParts(0);
      expect(val, equals('0'));
      expect(unit, equals('B'));
    });

    test('formats bytes, kilobytes, megabytes, gigabytes, terabytes', () {
      expect(Formatters.formatBytes(500), equals('500 B'));
      expect(Formatters.formatBytes(1024), equals('1.0 KB'));
      expect(Formatters.formatBytes(1024 * 1024), equals('1.0 MB'));
      expect(Formatters.formatBytes(1024 * 1024 * 1024), equals('1.0 GB'));
      expect(Formatters.formatBytes(1024 * 1024 * 1024 * 1024), equals('1.0 TB'));
    });
  });

  group('Formatters - Preferred Units', () {
    test('formats speed with forced SpeedUnit', () {
      expect(
        Formatters.formatSpeed(1024 * 1024 * 10, preferredUnit: SpeedUnit.kbs),
        equals('10240.0 KB/s'),
      );
      expect(
        Formatters.formatSpeed(1024 * 1024 * 10, preferredUnit: SpeedUnit.mbs),
        equals('10.0 MB/s'),
      );
      expect(
        Formatters.formatSpeed(1024 * 1024 * 10, preferredUnit: SpeedUnit.gbs),
        equals('0.0 GB/s'),
      );
      expect(
        Formatters.formatSpeed(0, preferredUnit: SpeedUnit.mbs),
        equals('0 MB/s'),
      );
    });

    test('formats data with forced DataUnit', () {
      expect(
        Formatters.formatBytes(1024 * 1024 * 500, preferredUnit: DataUnit.mb),
        equals('500.0 MB'),
      );
      expect(
        Formatters.formatBytes(1024 * 1024 * 1024 * 2, preferredUnit: DataUnit.mb),
        equals('2048.0 MB'),
      );
      expect(
        Formatters.formatBytes(1024 * 1024 * 1024 * 2, preferredUnit: DataUnit.gb),
        equals('2.0 GB'),
      );
      expect(
        Formatters.formatBytes(0, preferredUnit: DataUnit.gb),
        equals('0 GB'),
      );
    });

    test('parses SpeedUnit and DataUnit from string', () {
      expect(SpeedUnit.fromString('kbs'), equals(SpeedUnit.kbs));
      expect(SpeedUnit.fromString('mbs'), equals(SpeedUnit.mbs));
      expect(SpeedUnit.fromString('gbs'), equals(SpeedUnit.gbs));
      expect(SpeedUnit.fromString('invalid'), equals(SpeedUnit.auto));

      expect(DataUnit.fromString('mb'), equals(DataUnit.mb));
      expect(DataUnit.fromString('gb'), equals(DataUnit.gb));
      expect(DataUnit.fromString('invalid'), equals(DataUnit.auto));
    });
  });
}
