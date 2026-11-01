import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mobile_app_project/core/theme/app_colors.dart';

// The pale background behind every bar and the donut. (We will move shades
// like this into AppColors when we polish the UI.)
const Color _track = Color(0xFFF6F1E7);

// ---------------------------------------------------------------------------
// Vertical bars
// ---------------------------------------------------------------------------

/// One bar of a [StatsBarChart].
class BarChartItem {
  const BarChartItem({
    required this.label,
    required this.value,
    required this.valueLabel,
    this.highlight = false,
  });

  /// The text under the bar (for example a weekday letter).
  final String label;

  /// The bar's size, from 0 up to the chart's `maxValue`.
  final double value;

  /// The text above the bar (for example "60%").
  final String valueLabel;

  /// True for the bar that should stand out (today).
  final bool highlight;
}

/// A row of vertical bars, each with a label above and below it.
class StatsBarChart extends StatelessWidget {
  const StatsBarChart({
    super.key,
    required this.items,
    required this.maxValue,
    required this.barColor,
    this.barHeight = 90,
  });

  final List<BarChartItem> items;

  /// The value at which a bar is completely full.
  final double maxValue;
  final Color barColor;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final item in items)
          Expanded(
            child: _Bar(
              item: item,
              fraction: maxValue <= 0
                  ? 0
                  : (item.value / maxValue).clamp(0.0, 1.0),
              color: barColor,
              height: barHeight,
            ),
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.item,
    required this.fraction,
    required this.color,
    required this.height,
  });

  final BarChartItem item;
  final double fraction;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${item.label}: ${item.valueLabel}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.valueLabel,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: _track,
                  alignment: Alignment.bottomCenter,
                  child: TweenAnimationBuilder<double>(
                    // The bar glides to its new height instead of jumping.
                    tween: Tween<double>(end: fraction),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    builder: (context, value, _) {
                      return FractionallySizedBox(
                        widthFactor: 1,
                        heightFactor: value,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: color),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: item.highlight ? FontWeight.w800 : FontWeight.w500,
                color: item.highlight
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Horizontal bars
// ---------------------------------------------------------------------------

/// One row of a [StatsRateBars].
class RateBarItem {
  const RateBarItem({
    required this.label,
    required this.fraction,
    required this.valueLabel,
  });

  /// The name on the left.
  final String label;

  /// How full the bar is, from 0.0 to 1.0.
  final double fraction;

  /// The text on the right (for example "86%").
  final String valueLabel;
}

/// A list of horizontal bars: a name, a bar and a percentage on each row.
class StatsRateBars extends StatelessWidget {
  const StatsRateBars({super.key, required this.items, required this.barColor});

  final List<RateBarItem> items;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Semantics(
            label: '${items[i].label}: ${items[i].valueLabel}',
            excludeSemantics: true,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    items[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        end: items[i].fraction.clamp(0.0, 1.0),
                      ),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 10,
                          backgroundColor: _track,
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 40,
                  child: Text(
                    items[i].valueLabel,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (i < items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Donut
// ---------------------------------------------------------------------------

/// One colored slice of a [StatsDonut].
class DonutSegment {
  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

/// A donut chart with a number in the middle and a legend on the right.
class StatsDonut extends StatelessWidget {
  const StatsDonut({
    super.key,
    required this.segments,
    required this.centerValue,
    required this.centerLabel,
  });

  final List<DonutSegment> segments;

  /// The big text in the middle (for example "7").
  final String centerValue;

  /// The small text under it (for example "tasks").
  final String centerLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: TweenAnimationBuilder<double>(
            // The slices draw themselves in once, when the card first shows.
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) {
              return CustomPaint(
                painter: _DonutPainter(segments: segments, progress: progress),
                child: child,
              );
            },
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerValue,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    centerLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              for (var i = 0; i < segments.length; i++) ...[
                _LegendRow(segment: segments[i]),
                if (i < segments.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.segment});

  final DonutSegment segment;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${segment.label}: ${segment.value}',
      excludeSemantics: true,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: segment.color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              segment.label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '${segment.value}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws the pale ring and the colored slices on top of it.
class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.progress});

  final List<DonutSegment> segments;

  /// From 0.0 to 1.0: how much of each slice is drawn (for the intro motion).
  final double progress;

  static const double _strokeWidth = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - _strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = _track
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    canvas.drawCircle(center, radius, track);

    final total = segments.fold<int>(0, (sum, segment) => sum + segment.value);
    if (total <= 0) return;

    // A small gap between slices, only when there is more than one.
    final visible = segments.where((segment) => segment.value > 0).length;
    final gap = visible > 1 ? 0.07 : 0.0;

    var start = -math.pi / 2; // the top
    for (final segment in segments) {
      if (segment.value <= 0) continue;

      final sweep = segment.value / total * 2 * math.pi;
      final drawn = (sweep - gap).clamp(0.0, sweep) * progress;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth;
      canvas.drawArc(rect, start + gap / 2, drawn, false, paint);

      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.segments != segments;
  }
}