import '../models/count_down.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String formatTime(DateTime d) {
  final hour = d.hour.toString().padLeft(2, '0');
  final minute = d.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}';

String _formatDuration(Duration d) {
  if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  return '${d.inMinutes}m';
}

String countdownText(Countdown c) => switch (c) {
  Upcoming(:final remaining) => 'Starts in ${_formatDuration(remaining)}',
  Started(:final elapsed) => 'Started ${_formatDuration(elapsed)} ago',
  Ended() => 'Ended',
};