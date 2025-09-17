/// Utility helpers to render duration values in a friendly way.
String formatDuration(Duration? value) {
  if (value == null) {
    return 'N/A';
  }
  final int hours = value.inHours;
  final int minutes = value.inMinutes.remainder(60);
  final int seconds = value.inSeconds.remainder(60);
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  if (minutes > 0) {
    return '${minutes}m ${seconds}s';
  }
  return '${seconds}s';
}
