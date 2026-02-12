import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOffline;
  final DateTime? lastUpdated;
  final VoidCallback? onRetry;

  const OfflineBanner({
    super.key,
    required this.isOffline,
    required this.lastUpdated,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline || lastUpdated == null) return SizedBox.shrink();

    return MaterialBanner(content: Text('Offline - showing last update'), actions: [
      TextButton(
        onPressed: onRetry,
        child: Text('Retry'),
      )
    ]);
  }
}
