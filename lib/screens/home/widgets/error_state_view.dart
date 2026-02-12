import 'package:flutter/material.dart';

class ErrorStateView extends StatelessWidget {
  final String errorMessage;
  final bool canRetry;
  final bool isRetrying;
  final VoidCallback? onRetry;

  const ErrorStateView({
    super.key,
    required this.errorMessage,
    required this.canRetry,
    required this.isRetrying,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Icon(Icons.error_outline_rounded, size: 64),
            const SizedBox(height: 10),
            Text('Error loading weather'),
            const SizedBox(height: 6),
            Text(errorMessage),
            const SizedBox(height: 12),
            if (canRetry)
              FilledButton(
                onPressed: isRetrying ? null : onRetry,
                child: isRetrying ? Text('Retrying...') : Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
