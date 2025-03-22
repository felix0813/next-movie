int durationStringToSeconds(String durationString) {
  int totalSeconds = 0;
  final parts = durationString.split(' ');

  for (int i = 0; i < parts.length; i += 2) {
    final value = int.parse(parts[i]);
    final unit = parts[i + 1];

    if (unit == 'h') {
      totalSeconds += value * 3600;
    } else if (unit == 'min') {
      totalSeconds += value * 60;
    } else if (unit == 's') {
      totalSeconds += value;
    }
  }

  return totalSeconds;
}

String secondsToDurationString(int totalSeconds) {
  int hours = totalSeconds ~/ 3600;
  int minutes = (totalSeconds % 3600) ~/ 60;
  int seconds = totalSeconds % 60;

  List<String> parts = [];

  if (hours > 0) {
    parts.add('$hours h');
  }
  if (minutes > 0) {
    parts.add('$minutes min');
  }
  if (seconds > 0 || (hours == 0 && minutes == 0)) {
    parts.add('$seconds s');
  }

  return parts.join(' ');
}