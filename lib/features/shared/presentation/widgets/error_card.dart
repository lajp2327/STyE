import 'package:flutter/material.dart';

class ErrorCard extends StatelessWidget {
  const ErrorCard({
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.title,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextStyle? titleStyle = theme.textTheme.titleMedium?.copyWith(
      color: scheme.onErrorContainer,
      fontWeight: FontWeight.w700,
    );
    final TextStyle? bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onErrorContainer.withOpacity(0.92),
    );
    return Card(
      color: scheme.errorContainer,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.warning_amber_rounded,
              color: scheme.onErrorContainer,
              size: 32,
              semanticLabel: 'Error',
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title ?? 'Ocurrió un problema', style: titleStyle),
                  const SizedBox(height: 8),
                  Text(message, style: bodyStyle),
                  if (onRetry != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          FilledButton.tonal(
                            onPressed: onRetry,
                            child: const Text('Reintentar'),
                          ),
                          if (onDismiss != null)
                            TextButton(
                              onPressed: onDismiss,
                              child: const Text('Cerrar'),
                            ),
                        ],
                      ),
                    )
                  else if (onDismiss != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: onDismiss,
                        child: const Text('Cerrar'),
                      ),
                    ),
                ],
              ),
            ),
            if (onRetry == null && onDismiss != null)
              IconButton(
                tooltip: 'Cerrar',
                onPressed: onDismiss,
                icon: Icon(Icons.close, color: scheme.onErrorContainer),
              ),
          ],
        ),
      ),
    );
  }
}
