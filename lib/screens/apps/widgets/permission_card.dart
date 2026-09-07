/// Informative permission card explaining Android Usage Access requirements.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';

/// Card widget prompting the user to grant the `PACKAGE_USAGE_STATS` permission.
class PermissionCard extends StatelessWidget {
  /// Creates a [PermissionCard] widget.
  const PermissionCard({
    required this.onGrantPressed,
    required this.onCheckPressed,
    super.key,
  });

  /// Callback executed when the user taps "Grant Usage Access".
  final VoidCallback onGrantPressed;

  /// Callback executed when the user taps "Check Again".
  final VoidCallback onCheckPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedShield02,
                    size: 44,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Usage Access Required',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Android requires Usage Access permission to read per-app network consumption from NetworkStatsManager.\n\n'
                  'ByteFlow processes all statistics locally on your device. Your data is 100% private and never transmitted anywhere.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onGrantPressed();
                    },
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedSettings02,
                      size: 18,
                    ),
                    label: const Text('Open Usage Access Settings'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      onCheckPressed();
                    },
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedRefresh,
                      size: 18,
                    ),
                    label: const Text('Check Permission Again'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
