import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.icon,
    this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final IconData? icon;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null)
                Icon(
                  icon,
                  size: 72,
                  color: scheme.primary,
                  semanticLabel: 'Estado vacío',
                ),
              if (icon != null) const SizedBox(height: 20),
              Text(
                title ?? 'Sin información disponible',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (actionLabel != null && onAction != null) ...<Widget>[
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
