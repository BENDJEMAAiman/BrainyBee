import 'package:flutter/material.dart';

import 'package:mobile_app_project/BrainyBee/timer/model/timer_model.dart';
import 'package:mobile_app_project/core/theme/app_colors.dart';

// Neutral background of an unselected chip.
const Color _chipBackground = Color(0xFFF6F1E7);

/// A length in minutes as text: "25 min", "1 h", "1 h 15 min".
String formatMinutes(int minutes) {
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '$hours h' : '$hours h $rest min';
}

/// The row of duration choices shown before a session starts: 25, 45 and 60
/// minutes, plus a "Custom" button.
class DurationPicker extends StatelessWidget {
  const DurationPicker({
    super.key,
    required this.minutes,
    required this.onChanged,
  });

  /// The currently chosen length.
  final int minutes;

  /// The user picked another length.
  final ValueChanged<int> onChanged;

  Future<void> _openCustom(BuildContext context) async {
    final result = await showCustomDurationSheet(
      context,
      initialMinutes: minutes,
    );
    if (result != null) {
      onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = !TimerPresets.focusMinutes.contains(minutes);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final preset in TimerPresets.focusMinutes)
          _DurationChip(
            label: '$preset min',
            selected: preset == minutes,
            onTap: () => onChanged(preset),
          ),
        _DurationChip(
          label: isCustom ? formatMinutes(minutes) : 'Custom',
          icon: Icons.tune_rounded,
          selected: isCustom,
          onTap: () => _openCustom(context),
        ),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.canyonSoft : _chipBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: AppColors.textPrimary),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the custom duration sheet. Returns the chosen minutes, or null if the
/// user closed the sheet without choosing.
Future<int?> showCustomDurationSheet(
  BuildContext context, {
  required int initialMinutes,
}) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CustomDurationSheet(initialMinutes: initialMinutes),
  );
}

class _CustomDurationSheet extends StatefulWidget {
  const _CustomDurationSheet({required this.initialMinutes});

  final int initialMinutes;

  @override
  State<_CustomDurationSheet> createState() => _CustomDurationSheetState();
}

class _CustomDurationSheetState extends State<_CustomDurationSheet> {
  late int _minutes;

  bool get _canDecrease => _minutes > TimerPresets.minCustomMinutes;
  bool get _canIncrease => _minutes < TimerPresets.maxCustomMinutes;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialMinutes.clamp(
      TimerPresets.minCustomMinutes,
      TimerPresets.maxCustomMinutes,
    );
  }

  void _change(int delta) {
    setState(() {
      _minutes = (_minutes + delta).clamp(
        TimerPresets.minCustomMinutes,
        TimerPresets.maxCustomMinutes,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Small grab handle at the top of the sheet.
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Custom duration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // ---- minus, the number, plus ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepButton(
                  icon: Icons.remove_rounded,
                  label: 'Decrease by ${TimerPresets.customStepMinutes} minutes',
                  onPressed: _canDecrease
                      ? () => _change(-TimerPresets.customStepMinutes)
                      : null,
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    formatMinutes(_minutes),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _StepButton(
                  icon: Icons.add_rounded,
                  label: 'Increase by ${TimerPresets.customStepMinutes} minutes',
                  onPressed: _canIncrease
                      ? () => _change(TimerPresets.customStepMinutes)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_minutes),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Set duration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A round "+" or "-" button. Greyed out when [onPressed] is null.
class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled ? AppColors.canyonSoft : _chipBackground,
          ),
          child: Icon(
            icon,
            size: 28,
            color: enabled ? AppColors.textPrimary : AppColors.border,
          ),
        ),
      ),
    );
  }
}