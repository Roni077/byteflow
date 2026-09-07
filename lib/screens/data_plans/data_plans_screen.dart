/// Production screen managing Multi-SIM allowances, billing cycles, and data plans.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/database/app_database.dart';
import 'package:byteflow/providers/data_plans_provider.dart';
import 'package:byteflow/providers/sim_provider.dart';
import 'package:byteflow/screens/data_plans/widgets/add_edit_plan_dialog.dart';
import 'package:byteflow/screens/data_plans/widgets/data_plan_card.dart';
import 'package:byteflow/screens/data_plans/widgets/sim_status_card.dart';

/// Screen displaying and configuring Multi-SIM data allowances and cycles.
class DataPlansScreen extends ConsumerWidget {
  /// Creates a [DataPlansScreen] widget.
  const DataPlansScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DataPlan plan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: const Text('Delete Plan?'),
        content: Text(
          'Are you sure you want to delete "${plan.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(dataPlanActionControllerProvider).deletePlan(plan.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final plansUsageAsync = ref.watch(dataPlansWithUsageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Plans'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.selectionClick();
          AddEditPlanDialog.show(context);
        },
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedAdd01,
          size: 20,
        ),
        label: const Text('Add Plan'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.selectionClick();
          ref.invalidate(dataPlansWithUsageProvider);
          await ref.read(simCardsProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // SIM Status Card Header
            const SimStatusCard(),
            const SizedBox(height: 16),

            // Plans Section
            plansUsageAsync.when(
              data: (plansList) {
                if (plansList.isEmpty) {
                  return _buildEmptyState(context, theme, colorScheme);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Text(
                        'Configured Plans (${plansList.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    ...plansList.map((info) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DataPlanCard(
                          info: info,
                          onEdit: () => AddEditPlanDialog.show(
                            context,
                            plan: info.plan,
                          ),
                          onDelete: () =>
                              _confirmDelete(context, ref, info.plan),
                          onToggleActive: () => ref
                              .read(dataPlanActionControllerProvider)
                              .toggleActive(info.plan),
                        ),
                      );
                    }),
                    const SizedBox(height: 72), // Fab padding
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(48.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedAlertCircle,
                        color: AppColors.errorRed,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text('Failed to load data plans: $err'),
                      const SizedBox(height: 12),
                      FilledButton.tonal(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.invalidate(dataPlansWithUsageProvider);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedDatabase01,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Data Plans Configured',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your mobile data allowances, calculate daily recommended limits, and receive quota alerts.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                AddEditPlanDialog.show(context);
              },
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedAdd01,
                size: 18,
              ),
              label: const Text('Create First Plan'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
