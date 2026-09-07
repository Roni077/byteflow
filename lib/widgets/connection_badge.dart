/// Connection status badge displaying active transport type, SSID, and metered indicators.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/models/network_info.dart';
import 'package:byteflow/providers/network_info_provider.dart';

/// Renders a Material 3 status badge depicting the active network interface.
class ConnectionBadge extends ConsumerWidget {
  /// Creates a [ConnectionBadge] widget.
  const ConnectionBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkAsync = ref.watch(networkInfoStreamProvider);
    final networkInfo = networkAsync.value ?? NetworkInfo.disconnected();
    final theme = Theme.of(context);
    final isConnected = networkInfo.isConnected;

    final iconData = _getNetworkIcon(networkInfo.type);
    final iconColor = isConnected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onErrorContainer;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isConnected
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: iconData,
                size: 22,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          isConnected ? networkInfo.type.label : 'Offline',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnected ? AppTheme.rxColor : AppTheme.errorColor,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scaleXY(
                            begin: 0.8,
                            end: 1.25,
                            duration: 1000.ms,
                            curve: Curves.easeInOut,
                          ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isConnected
                        ? (networkInfo.ssid != null && networkInfo.ssid!.isNotEmpty
                            ? networkInfo.ssid!
                            : 'Active Connection')
                        : 'No active connection',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Metered / Unmetered chip
            if (isConnected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: networkInfo.isMetered
                      ? theme.colorScheme.tertiaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  networkInfo.isMetered ? 'Metered' : 'Unmetered',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: networkInfo.isMetered
                        ? theme.colorScheme.onTertiaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static dynamic _getNetworkIcon(NetworkType type) {
    return switch (type) {
      NetworkType.wifi => HugeIcons.strokeRoundedWifi01,
      NetworkType.mobile => HugeIcons.strokeRoundedCellularNetwork,
      NetworkType.ethernet => HugeIcons.strokeRoundedRouter,
      NetworkType.vpn => HugeIcons.strokeRoundedSecuredNetwork,
      NetworkType.bluetooth => HugeIcons.strokeRoundedBluetooth,
      NetworkType.none || NetworkType.unknown => HugeIcons.strokeRoundedWifiDisconnected01,
    };
  }
}
