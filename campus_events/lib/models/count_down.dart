const _eventLength = Duration(hours: 2);

sealed class Countdown {
  const Countdown();

  factory Countdown.of(DateTime starts, DateTime now) {
    final diff = starts.difference(now);
    if (diff > Duration.zero) return Upcoming(diff);
    final elapsed = -diff;
    if (elapsed < _eventLength) return Started(elapsed);
    return const Ended();
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.remaining);

  final Duration remaining;
}

final class Started extends Countdown {
  const Started(this.elapsed);

  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}