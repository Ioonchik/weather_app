import 'package:flutter/material.dart';

class WeatherSkeletonPage extends StatelessWidget {
  const WeatherSkeletonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _CurrentWeatherCardSkeleton(),
        SizedBox(height: 12),
        _StatsCardSkeleton(),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: _TitleSkeleton(),
        ),
        SizedBox(height: 12),
        _DetailsSkeleton(),
      ],
    );
  }
}

/// ---------- Building blocks ----------

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// ---------- Mirrors CurrentWeatherCard ----------

class _CurrentWeatherCardSkeleton extends StatelessWidget {
  const _CurrentWeatherCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Place / subtitle line
            const _SkeletonBox(width: 160, height: 16),
            const SizedBox(height: 16),

            Row(
              children: const [
                // Temp
                _SkeletonBox(width: 110, height: 52),
                Spacer(),
                // Icon circle
                _SkeletonBox(
                  width: 56,
                  height: 56,
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Description line
            const _SkeletonBox(width: 120, height: 14),
            const SizedBox(height: 18),

            // Small stats row (like feels-like / etc.)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _SkeletonBox(width: 64, height: 14),
                _SkeletonBox(width: 64, height: 14),
                _SkeletonBox(width: 64, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- Mirrors your Stats Card ----------

class _StatsCardSkeleton extends StatelessWidget {
  const _StatsCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final dividerColor = Theme.of(context).colorScheme.onSurface.withValues(
          alpha: 0.12,
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            const Expanded(child: _StatSkeleton()),
            Container(height: 36, width: 1, color: dividerColor),
            const Expanded(child: _StatSkeleton()),
            Container(height: 36, width: 1, color: dividerColor),
            const Expanded(child: _StatSkeleton()),
          ],
        ),
      ),
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _SkeletonBox(
          width: 24,
          height: 24,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBox(width: 56, height: 12),
              SizedBox(height: 8),
              _SkeletonBox(width: 72, height: 14),
            ],
          ),
        ),
      ],
    );
  }
}

/// ---------- Mirrors the "7-Day Forecast" title ----------

class _TitleSkeleton extends StatelessWidget {
  const _TitleSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _SkeletonBox(width: 120, height: 18);
  }
}

/// ---------- Mirrors Details() ----------
/// Since we don't know your exact layout, this imitates a list of rows.
/// Adjust row count/sizes later to match Details() precisely.

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(
            7,
            (index) => const _ForecastRowSkeleton(),
          ),
        ),
      ),
    );
  }
}

class _ForecastRowSkeleton extends StatelessWidget {
  const _ForecastRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: const [
          // Day label
          _SkeletonBox(width: 64, height: 14),
          Spacer(),
          // Icon
          _SkeletonBox(
            width: 22,
            height: 22,
            borderRadius: BorderRadius.all(Radius.circular(11)),
          ),
          SizedBox(width: 16),
          // Temp
          _SkeletonBox(width: 44, height: 14),
        ],
      ),
    );
  }
}
