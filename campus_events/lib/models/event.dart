import 'event_category.dart';

class Event {
  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.starts,
    required this.place,
    required this.capacity,
    required this.isOnline,
    this.description,
    this.isFavourite = false,
    List<String> attendees = const [],
  }) : _attendees = attendees;

  Event.empty()
      : this(
    id: '',
    title: '',
    category: EventCategory.tech,
    starts: DateTime.now().add(const Duration(days: 1)),
    place: '',
    capacity: 20,
    isOnline: false,
  );

  final String id;
  final String title;
  final EventCategory category;
  final DateTime starts;
  final String place;
  final int capacity;
  final bool isOnline;
  final String? description;
  final bool isFavourite;
  final List<String> _attendees;

  List<String> get attendees => List.unmodifiable(_attendees);
  int get count => _attendees.length;

  int get freePlaces => capacity - count;

  bool get isFull => count >= capacity;

  bool get isPast => starts.isBefore(DateTime.now());

  bool contains(String name) => _attendees.contains(name);

  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Event copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? starts,
    String? place,
    int? capacity,
    bool? isOnline,
    String? description,
    bool? isFavourite,
    List<String>? attendees,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      starts: starts ?? this.starts,
      place: place ?? this.place,
      capacity: capacity ?? this.capacity,
      isOnline: isOnline ?? this.isOnline,
      description: description ?? this.description,
      isFavourite: isFavourite ?? this.isFavourite,
      attendees: attendees ?? _attendees,
    );
  }
}