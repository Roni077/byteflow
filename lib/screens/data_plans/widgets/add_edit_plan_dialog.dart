/// Dialog facilitating the creation and modification of data plan quotas and cycles.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/core/utils/time_utils.dart';
import 'package:byteflow/database/app_database.dart';
import 'package:byteflow/providers/data_plans_provider.dart';
import 'package:byteflow/providers/sim_provider.dart';

/// Interactive modal dialog for creating or updating a [DataPlan].
class AddEditPlanDialog extends ConsumerStatefulWidget {
  /// Creates an [AddEditPlanDialog].
  ///
  /// If [existingPlan] is provided, the dialog initializes with its values in edit mode.
  const AddEditPlanDialog({this.existingPlan, super.key});

  /// The plan to edit, or null to create a new plan.
  final DataPlan? existingPlan;

  /// Convenience method to display this dialog.
  static Future<bool?> show(BuildContext context, {DataPlan? plan}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddEditPlanDialog(existingPlan: plan),
    );
  }

  @override
  ConsumerState<AddEditPlanDialog> createState() => _AddEditPlanDialogState();
}

class _AddEditPlanDialogState extends ConsumerState<AddEditPlanDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _limitController;

  late String _selectedUnit;
  late String _cycleType;
  late DateTime _cycleStartDate;
  late int? _simSlot;
  late double _warningPercent;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final plan = widget.existingPlan;

    _nameController = TextEditingController(text: plan?.name ?? '');

    if (plan != null) {
      // Determine initial limit and unit from bytes
      const gigabyte = 1024 * 1024 * 1024;
      if (plan.limitBytes % gigabyte == 0 || plan.limitBytes >= gigabyte) {
        _selectedUnit = 'GB';
        final val = plan.limitBytes / gigabyte;
        _limitController = TextEditingController(
          text: val == val.roundToDouble() ? val.toInt().toString() : val.toStringAsFixed(1),
        );
      } else {
        _selectedUnit = 'MB';
        final val = plan.limitBytes / (1024 * 1024);
        _limitController = TextEditingController(
          text: val == val.roundToDouble() ? val.toInt().toString() : val.toStringAsFixed(1),
        );
      }

      _cycleType = plan.cycleType;
      _cycleStartDate = plan.cycleStartDate;
      _simSlot = plan.simSlot;
      _warningPercent = plan.warningPercent.toDouble();
    } else {
      _selectedUnit = 'GB';
      _limitController = TextEditingController(text: '10');
      _cycleType = 'monthly';
      _cycleStartDate = DateTime.now();
      _simSlot = null;
      _warningPercent = 80.0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: _cycleStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null && mounted) {
      setState(() {
        _cycleStartDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _cycleStartDate.hour,
          _cycleStartDate.minute,
        );
      });
    }
  }

  int _computeLimitBytes() {
    final numericValue = double.tryParse(_limitController.text.trim()) ?? 0.0;
    if (_selectedUnit == 'GB') {
      return (numericValue * 1024 * 1024 * 1024).round();
    }
    return (numericValue * 1024 * 1024).round();
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(dataPlanActionControllerProvider);
      final limitBytes = _computeLimitBytes();
      final planName = _nameController.text.trim();

      if (widget.existingPlan != null) {
        final updated = widget.existingPlan!.copyWith(
          name: planName,
          limitBytes: limitBytes,
          cycleStartDate: _cycleStartDate,
          cycleType: _cycleType,
          simSlot: drift.Value(_simSlot),
          warningPercent: _warningPercent.round(),
        );
        await controller.updatePlan(updated);
      } else {
        final companion = DataPlansCompanion.insert(
          name: planName,
          limitBytes: limitBytes,
          cycleStartDate: _cycleStartDate,
          cycleType: drift.Value(_cycleType),
          simSlot: drift.Value(_simSlot),
          warningPercent: drift.Value(_warningPercent.round()),
        );
        await controller.addPlan(companion);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving plan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.existingPlan != null;
    final simCards = ref.watch(simCardsProvider).value ?? [];

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      title: Text(isEditing ? 'Edit Data Plan' : 'New Data Plan'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Plan Name',
                  hintText: 'e.g. Primary SIM 10GB',
                  prefixIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedBookmark01,
                    size: 20,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name for the plan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quota Limit & Unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _limitController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Quota Limit',
                        hintText: '10',
                        prefixIcon: HugeIcon(
                          icon: HugeIcons.strokeRoundedDatabase01,
                          size: 20,
                        ),
                      ),
                      validator: (value) {
                        final val = double.tryParse(value?.trim() ?? '');
                        if (val == null || val <= 0) {
                          return 'Enter valid limit';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'GB', child: Text('GB')),
                        DropdownMenuItem(value: 'MB', child: Text('MB')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedUnit = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Billing Cycle Type
              Text('Billing Cycle Recurrence', style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'monthly', label: Text('Monthly')),
                  ButtonSegment(value: 'weekly', label: Text('Weekly')),
                  ButtonSegment(value: 'daily', label: Text('Daily')),
                ],
                selected: {_cycleType},
                onSelectionChanged: (set) {
                  HapticFeedback.selectionClick();
                  setState(() => _cycleType = set.first);
                },
              ),
              const SizedBox(height: 16),

              // Cycle Start Date Picker
              InkWell(
                onTap: _pickStartDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Billing Cycle Anchor Date',
                    prefixIcon: HugeIcon(
                      icon: HugeIcons.strokeRoundedCalendar03,
                      size: 20,
                    ),
                  ),
                  child: Text(
                    TimeUtils.formatDate(_cycleStartDate),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SIM Association Dropdown
              DropdownButtonFormField<int?>(
                initialValue: _simSlot,
                decoration: const InputDecoration(
                  labelText: 'SIM Card Slot',
                  prefixIcon: HugeIcon(
                    icon: HugeIcons.strokeRoundedSimcard01,
                    size: 20,
                  ),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Mobile Traffic'),
                  ),
                  if (simCards.isNotEmpty)
                    ...simCards.map((sim) {
                      return DropdownMenuItem<int?>(
                        value: sim.simSlotIndex,
                        child: Text(sim.formattedTitle),
                      );
                    })
                  else ...[
                    const DropdownMenuItem<int?>(
                      value: 0,
                      child: Text('SIM 1 (Default)'),
                    ),
                    const DropdownMenuItem<int?>(
                      value: 1,
                      child: Text('SIM 2'),
                    ),
                  ],
                ],
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() => _simSlot = val);
                },
              ),
              const SizedBox(height: 20),

              // Warning Threshold Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Warning Threshold', style: theme.textTheme.labelMedium),
                  Text(
                    '${_warningPercent.round()}%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _warningPercent,
                min: 50,
                max: 95,
                divisions: 9,
                label: '${_warningPercent.round()}%',
                onChanged: (val) {
                  setState(() => _warningPercent = val);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _savePlan,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update Plan' : 'Create Plan'),
        ),
      ],
    );
  }
}
